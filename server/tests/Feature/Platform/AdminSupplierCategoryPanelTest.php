<?php

namespace Tests\Feature\Platform;

use App\Filament\Resources\Verifications\Pages\ManageVerifications;
use App\Models\Business;
use App\Models\BusinessCategory;
use App\Models\User;
use Database\Seeders\BusinessCapabilitySeeder;
use Database\Seeders\BusinessRoleSeeder;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Livewire\Livewire;
use Tests\TestCase;

class AdminSupplierCategoryPanelTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        if (
            DB::connection()->getDatabaseName() !== 'talbatiyk_testing'
            || DB::selectOne('SELECT current_database() AS name')->name !== 'talbatiyk_testing'
        ) {
            throw new \RuntimeException('Unsafe test database.');
        }

        Filament::setCurrentPanel(Filament::getPanel('admin'));

        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);
    }

    public function test_admin_can_create_supplier_with_one_leaf_category(): void
    {
        $this->loginAdmin();

        $parent = $this->category('panel_parent');
        $leaf = $this->category('panel_leaf', $parent->id);

        Livewire::test(ManageVerifications::class)
            ->assertActionExists('createSupplierUser')
            ->callAction(
                'createSupplierUser',
                data: $this->payload($leaf->id)
            )
            ->assertHasNoActionErrors();

        $business = Business::query()
            ->where('name', 'Panel Category Supplier')
            ->sole();

        $this->assertSame(
            [$leaf->id],
            $business->categories()
                ->pluck('business_categories.id')
                ->all()
        );

        $this->assertDatabaseHas('users', [
            'username' => 'panel_category_supplier',
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
    }

    public function test_admin_cannot_create_supplier_without_category(): void
    {
        $this->loginAdmin();

        Livewire::test(ManageVerifications::class)
            ->callAction(
                'createSupplierUser',
                data: $this->payload(null)
            )
            ->assertHasActionErrors(['category_id']);

        $this->assertDatabaseMissing('users', [
            'username' => 'panel_category_supplier',
        ]);

        $this->assertDatabaseMissing('businesses', [
            'name' => 'Panel Category Supplier',
        ]);
    }

    private function loginAdmin(): User
    {
        $admin = User::factory()->create([
            'status' => 'active',
        ]);

        DB::table('platform_role_assignments')->insert([
            'user_id' => $admin->id,
            'role_code' => 'platform_admin',
            'granted_at' => now()->subMinute(),
        ]);

        $this->actingAs($admin, 'web');

        return $admin;
    }

    private function category(
        string $code,
        ?string $parentId = null
    ): BusinessCategory {
        return BusinessCategory::query()->create([
            'code' => $code,
            'name_ar' => $code,
            'parent_id' => $parentId,
            'is_active' => true,
            'sort_order' => 0,
        ]);
    }

    private function payload(?string $categoryId): array
    {
        return [
            'username' => 'panel_category_supplier',
            'display_name' => 'Panel Category User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'email',
            'contact_value' => 'panel-category@example.com',
            'category_id' => $categoryId,
            'name' => 'Panel Category Supplier',
            'legal_name' => null,
            'description' => null,
            'location_name' => 'Main Branch',
            'location_type' => 'office',
            'timezone' => 'Asia/Aden',
            'country_code' => 'YE',
            'business_contact_type' => 'email',
            'business_contact_value' => 'panel-business@example.com',
        ];
    }
}
