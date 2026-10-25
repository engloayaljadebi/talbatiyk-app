<?php

namespace Tests\Feature\Platform;

use App\Filament\Resources\Users\Pages\ManageUsers;
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

        Livewire::test(ManageUsers::class)
            ->assertActionExists('createUser')
            ->callAction(
                'createUser',
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

        Livewire::test(ManageUsers::class)
            ->callAction(
                'createUser',
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
            'account_type' => 'supplier',
            'username' => 'panel_category_supplier',
            'display_name' => 'Panel Category User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'phone',
            'contact_value' => '+9677'.random_int(10000000, 99999999),
            'additional_contact_type' => 'email',
            'additional_contact_value' => 'panel-secondary@example.com',
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-15',
            'name' => 'Panel Category Supplier',
            'legal_name' => null,
            'description' => 'Panel category integration test',
            'category_id' => $categoryId,
            'location_name' => 'Main Branch',
            'location_type' => 'warehouse',
            'timezone' => 'Asia/Aden',
            'country_code' => 'YE',
            'administrative_area' => 'Amanat Al Asimah',
            'locality' => 'Sanaa',
            'district' => 'Test District',
            'street_address' => 'Test Street',
            'address_notes' => 'Test address',
            'latitude' => '15.3694',
            'longitude' => '44.1910',
            'business_contact_type' => 'whatsapp',
            'business_contact_value' => '+9677'.random_int(10000000, 99999999),
            'business_contact_label' => 'Main WhatsApp',
            'additional_business_contact_type' => 'email',
            'additional_business_contact_value' => 'panel-business@example.com',
            'additional_business_contact_label' => 'Business email',
        ];
    }
}
