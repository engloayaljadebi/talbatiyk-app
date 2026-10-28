<?php

declare(strict_types=1);

namespace Tests\Feature\Platform;

use App\Filament\Resources\Users\UserResource;
use App\Models\BusinessCategory;
use App\Models\User;
use App\Services\Platform\AdminUserCreationService;
use App\Services\User\UserProfileService;
use Database\Seeders\BusinessCapabilitySeeder;
use Database\Seeders\BusinessRoleSeeder;
use Filament\Facades\Filament;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class AdminUserManagementTest extends TestCase
{
    use DatabaseTransactions;

    private string $categoryId;

    protected function setUp(): void
    {
        parent::setUp();

        $actual = DB::selectOne(
            'SELECT current_database() AS name'
        )->name;

        if (
            DB::connection()->getDatabaseName() !== 'talbatiyk_testing'
            || $actual !== 'talbatiyk_testing'
        ) {
            throw new \RuntimeException('Unsafe database.');
        }

        Storage::fake('talbatiyk_private');

        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);

        $category = BusinessCategory::query()->create([
            'code' => 'admin_user_'.Str::lower(Str::random(10)),
            'name_ar' => 'فئة اختبار إدارة المستخدم',
            'parent_id' => null,
            'is_active' => true,
            'sort_order' => 999,
        ]);

        $this->categoryId = $category->id;

        Filament::setCurrentPanel(
            Filament::getPanel('admin')
        );
    }

    public function test_admin_can_create_shop_account_with_business_and_pending_approval(): void
    {
        $admin = $this->loginAdmin();

        app(AdminUserCreationService::class)
            ->create($admin, $this->payload());

        $created = User::query()
            ->where('username', 'generalusertest')
            ->firstOrFail();

        $this->assertSame('active', $created->status);

        $this->assertTrue(
            Hash::check('StrongPass123!', $created->password)
        );

        $this->assertDatabaseHas('user_contacts', [
            'user_id' => $created->id,
            'type' => 'email',
            'value' => 'general-user@example.com',
            'is_primary' => true,
        ]);

        $this->assertDatabaseHas('user_profiles', [
            'user_id' => $created->id,
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-15',
        ]);

        $this->assertDatabaseMissing('platform_role_assignments', [
            'user_id' => $created->id,
        ]);

        $membership = DB::table('business_memberships')
            ->where('user_id', $created->id)
            ->first();

        $this->assertNotNull($membership);
        $businessId = $membership->business_id;

        $this->assertDatabaseHas('businesses', [
            'id' => $businessId,
            'name' => 'Test Business',
            'status' => 'active',
        ]);

        $this->assertSame(
            1,
            DB::table('business_category_assignments')
                ->where('business_id', $businessId)
                ->count()
        );

        $this->assertDatabaseHas('business_locations', [
            'business_id' => $businessId,
            'name' => 'Main location',
            'country_code' => 'YE',
            'administrative_area' => 'Amanat Al Asimah',
            'locality' => 'Sanaa',
            'is_primary' => true,
        ]);

        $this->assertDatabaseHas('verifications', [
            'business_id' => $businessId,
            'verification_type_code' => 'shop_approval',
            'status' => 'pending',
        ]);
    }

    public function test_admin_can_create_general_user_with_personal_profile(): void
    {
        $admin = $this->loginAdmin();

        $payload = $this->payload();
        $payload['nationality_country_code'] = 'YE';
        $payload['birth_date'] = '2000-01-15';

        app(AdminUserCreationService::class)
            ->create($admin, $payload);

        $created = User::query()
            ->where('username', 'generalusertest')
            ->firstOrFail();

        $this->assertDatabaseHas('user_profiles', [
            'user_id' => $created->id,
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-15',
        ]);
    }

    public function test_future_birth_date_is_rejected_without_creating_user_or_contact(): void
    {
        $admin = $this->loginAdmin();

        $payload = $this->payload();
        $payload['birth_date'] = now()->addDays(2)->format('Y-m-d');

        try {
            app(AdminUserCreationService::class)->create($admin, $payload);
            $this->fail('A future birth date was accepted.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'birth_date',
                $exception->errors()
            );
        }

        $this->assertDatabaseMissing('users', [
            'username' => 'generalusertest',
        ]);

        $this->assertDatabaseMissing('user_contacts', [
            'value' => 'general-user@example.com',
        ]);
    }

    public function test_profile_persistence_failure_rolls_back_user_and_contact(): void
    {
        $admin = $this->loginAdmin();

        $usersBefore = DB::table('users')->count();
        $contactsBefore = DB::table('user_contacts')->count();
        $profilesBefore = DB::table('user_profiles')->count();

        $payload = $this->payload();
        $payload['nationality_country_code'] = 'YE';
        $payload['birth_date'] = '2000-01-15';

        $this->mock(UserProfileService::class, function ($mock): void {
            $mock->shouldReceive('savePersonalDetails')
                ->once()
                ->andThrow(new \RuntimeException('Profile persistence failed.'));
        });

        try {
            app(AdminUserCreationService::class)->create($admin, $payload);
            $this->fail('Expected profile persistence failure.');
        } catch (\RuntimeException $exception) {
            $this->assertSame(
                'Profile persistence failed.',
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
            $profilesBefore,
            DB::table('user_profiles')->count()
        );
    }

    public function test_regular_user_cannot_open_user_management(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $this->actingAs($user, 'web')
            ->get(UserResource::getUrl())
            ->assertForbidden();
    }

    public function test_duplicate_username_is_rejected(): void
    {
        $admin = $this->loginAdmin();

        User::factory()->create([
            'username' => 'generalusertest',
        ]);

        try {
            app(AdminUserCreationService::class)
                ->create($admin, $this->payload());

            $this->fail('Duplicate username was accepted.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'username',
                $exception->errors()
            );
        }

        $this->assertDatabaseMissing('user_contacts', [
            'value' => 'general-user@example.com',
        ]);
    }

    public function test_duplicate_contact_is_rejected(): void
    {
        $admin = $this->loginAdmin();

        $admin->contacts()->create([
            'type' => 'email',
            'value' => 'general-user@example.com',
            'is_primary' => true,
        ]);

        try {
            app(AdminUserCreationService::class)
                ->create($admin, $this->payload());

            $this->fail('Duplicate contact was accepted.');
        } catch (ValidationException $exception) {
            $this->assertArrayHasKey(
                'contact_value',
                $exception->errors()
            );
        }

        $this->assertDatabaseMissing('users', [
            'username' => 'generalusertest',
        ]);
    }

    public function test_revoked_admin_cannot_create_user(): void
    {
        $admin = $this->loginAdmin();

        DB::table('platform_role_assignments')
            ->where('user_id', $admin->id)
            ->where('role_code', 'platform_admin')
            ->update([
                'revoked_at' => now(),
            ]);

        $this->expectException(
            AuthorizationException::class
        );

        app(AdminUserCreationService::class)
            ->create($admin, $this->payload());
    }

    private function loginAdmin(): User
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

        $this->actingAs($admin, 'web');

        return $admin;
    }

    private function payload(): array
    {
        return [
            'account_type' => 'shop',
            'username' => 'generalusertest',
            'display_name' => 'General Test User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'general-user@example.com',
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-15',
            'name' => 'Test Business',
            'category_id' => $this->categoryId,
            'description' => 'Admin user management test.',
            'location_name' => 'Main location',
            'administrative_area' => 'Amanat Al Asimah',
            'locality' => 'Sanaa',
        ];
    }
}
