<?php

declare(strict_types=1);

namespace Tests\Feature\Platform;

use App\Models\BusinessCategory;
use App\Models\User;
use App\Services\Business\BusinessOnboardingService;
use App\Services\Platform\AdminSupplierCreationService;
use Database\Seeders\BusinessCapabilitySeeder;
use Database\Seeders\BusinessRoleSeeder;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Mockery\MockInterface;
use Tests\TestCase;

final class AdminSupplierCreationIntegrationTest extends TestCase
{
    use DatabaseTransactions;

    private string $testCategoryId;

    protected function setUp(): void
    {
        parent::setUp();

        $database = DB::selectOne(
            'SELECT current_database() AS name'
        )->name;

        if (
            DB::connection()->getDatabaseName() !== 'talbatiyk_testing' ||
            $database !== 'talbatiyk_testing'
        ) {
            throw new \RuntimeException('Unsafe test database.');
        }

        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);

        $category = BusinessCategory::query()->create([
            'code' => 'supplier_integration_category',
            'name_ar' => 'فئة اختبار المورد',
            'parent_id' => null,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $this->testCategoryId = $category->id;
    }

    public function test_admin_creates_pending_supplier(): void
    {
        $admin = $this->admin();

        $business = app(AdminSupplierCreationService::class)
            ->create($admin, $this->payload());

        $this->assertDatabaseHas('users', [
            'username' => 'supplierintegrationuser',
        ]);

        $this->assertDatabaseHas('businesses', [
            'id' => $business->id,

            'name' => 'Integration Supplier',
        ]);

        $this->assertDatabaseHas('verifications', [
            'business_id' => $business->id,
            'verification_type_code' => 'supplier_approval',
            'status' => 'pending',
        ]);

        $this->assertFalse(
            $business->capabilities()
                ->where('business_capabilities.code', 'supplier')
                ->exists()
        );

        $this->assertDatabaseHas('business_category_assignments', [
            'business_id' => $business->id,
            'category_id' => $this->testCategoryId,
        ]);
        $this->assertCount(1, $business->memberships);
        $this->assertCount(1, $business->locations);
        $this->assertCount(1, $business->contacts);
    }

    public function test_regular_user_cannot_create_supplier(): void
    {
        $user = User::factory()->create();

        $this->expectException(AuthorizationException::class);

        app(AdminSupplierCreationService::class)
            ->create($user, $this->payload());
    }

    public function test_duplicate_username_is_rejected(): void
    {
        $admin = $this->admin();

        User::factory()->create([
            'username' => 'supplierintegrationuser',
        ]);

        $this->expectException(ValidationException::class);

        app(AdminSupplierCreationService::class)
            ->create($admin, $this->payload());
    }

    public function test_duplicate_contact_is_rejected(): void
    {
        $admin = $this->admin();

        $admin->contacts()->create([
            'type' => 'email',
            'value' => 'supplier-integration@example.com',
            'is_primary' => true,
        ]);

        try {
            app(AdminSupplierCreationService::class)
                ->create($admin, $this->payload());

            $this->fail('Duplicate contact must be rejected.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'contact_value',
                $exception->errors()
            );
        }

        $this->assertDatabaseMissing('users', [
            'username' => 'supplierintegrationuser',
        ]);

        $this->assertDatabaseMissing('businesses', [
            'name' => 'Integration Supplier',
        ]);
    }

    public function test_onboarding_failure_rolls_back_identity(): void
    {
        $admin = $this->admin();

        $usersBefore = DB::table('users')->count();
        $contactsBefore = DB::table('user_contacts')->count();
        $businessesBefore = DB::table('businesses')->count();

        $this->mock(
            BusinessOnboardingService::class,
            function (MockInterface $mock): void {
                $mock->shouldReceive('create')
                    ->once()
                    ->andThrow(
                        new \RuntimeException(
                            'Simulated onboarding failure'
                        )
                    );
            }
        );

        try {
            app(AdminSupplierCreationService::class)
                ->create($admin, $this->payload());

            $this->fail('Onboarding failure was not propagated.');
        } catch (\RuntimeException $exception) {
            $this->assertSame(
                'Simulated onboarding failure',
                $exception->getMessage()
            );
        }

        $this->assertSame(
            $usersBefore,
            DB::table('users')->count()
        );

        $this->assertSame(
            $contactsBefore,
            DB::table('user_contacts')->count()
        );

        $this->assertSame(
            $businessesBefore,
            DB::table('businesses')->count()
        );

        $this->assertDatabaseMissing('users', [
            'username' => 'supplierintegrationuser',
        ]);

        $this->assertDatabaseMissing('user_contacts', [
            'type' => 'email',
            'value' => 'supplier-integration@example.com',
        ]);
    }

    private function admin(): User
    {
        $admin = User::factory()->create([
            'status' => 'active',
        ]);

        DB::table('platform_role_assignments')->insert([
            'user_id' => $admin->id,
            'role_code' => 'platform_admin',
            'granted_by_user_id' => null,
            'granted_at' => now(),
            'revoked_at' => null,
        ]);

        return $admin;
    }

    private function payload(): array
    {
        return [
            'username' => 'supplierintegrationuser',
            'display_name' => 'Integration Supplier User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'supplier-integration@example.com',
            'category_ids' => [$this->testCategoryId],
            'name' => 'Integration Supplier',
            'legal_name' => null,
            'description' => null,
            'location_name' => 'Main Branch',
            'location_type' => 'office',
            'timezone' => 'Asia/Riyadh',
            'country_code' => 'SA',
            'business_contact_type' => 'email',
            'business_contact_value' => 'business-integration@example.com',
        ];
    }
}
