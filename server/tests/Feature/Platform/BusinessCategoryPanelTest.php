<?php

namespace Tests\Feature\Platform;

use App\Filament\Resources\BusinessCategories\BusinessCategoryResource;
use App\Filament\Resources\BusinessCategories\Pages\ManageBusinessCategories;
use App\Models\BusinessCategory;
use App\Models\User;
use Filament\Actions\Testing\TestAction;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Support\Facades\DB;
use Livewire\Livewire;
use Tests\TestCase;

final class BusinessCategoryPanelTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();

        if (
            DB::connection()->getDatabaseName() !== 'talbatiyk_testing'
            || DB::selectOne('SELECT current_database() AS db')->db
                !== 'talbatiyk_testing'
        ) {
            throw new \RuntimeException('Unsafe test database.');
        }

        Filament::setCurrentPanel(Filament::getPanel('admin'));
    }

    public function test_admin_can_open_category_management(): void
    {
        $this->loginAdmin();

        $this->get(BusinessCategoryResource::getUrl())
            ->assertOk();

        Livewire::test(ManageBusinessCategories::class)
            ->assertSuccessful()
            ->assertActionExists('createCategory');
    }

    public function test_regular_user_cannot_open_category_management(): void
    {
        $user = User::factory()->create(['status' => 'active']);

        $this->actingAs($user, 'web')
            ->get(BusinessCategoryResource::getUrl())
            ->assertForbidden();
    }

    public function test_admin_can_create_category_through_filament(): void
    {
        $this->loginAdmin();

        Livewire::test(ManageBusinessCategories::class)
            ->callAction('createCategory', data: [
                'code' => 'panel_electronics',
                'name_ar' => 'إلكترونيات تجريبية',
                'parent_id' => null,
                'is_active' => true,
                'sort_order' => 5,
            ])
            ->assertHasNoActionErrors();

        $this->assertDatabaseHas('business_categories', [
            'code' => 'panel_electronics',
            'name_ar' => 'إلكترونيات تجريبية',
            'parent_id' => null,
            'is_active' => true,
            'sort_order' => 5,
        ]);
    }

    public function test_admin_can_edit_category_through_filament(): void
    {
        $this->loginAdmin();
        $category = $this->category('panel_edit_category');

        Livewire::test(ManageBusinessCategories::class)
            ->callAction(
                TestAction::make('editCategory')->table($category),
                data: [
                    'name_ar' => 'فئة محدثة',
                    'sort_order' => 12,
                    'is_active' => true,
                ]
            )
            ->assertHasNoActionErrors();

        $this->assertDatabaseHas('business_categories', [
            'id' => $category->id,
            'name_ar' => 'فئة محدثة',
            'sort_order' => 12,
        ]);
    }

    public function test_admin_can_move_unused_category_through_filament(): void
    {
        $this->loginAdmin();

        $source = $this->category('panel_move_source');
        $destination = $this->category('panel_move_destination');
        $leaf = $this->category('panel_move_leaf', $source->id);

        Livewire::test(ManageBusinessCategories::class)
            ->callAction(
                TestAction::make('moveCategory')->table($leaf),
                data: [
                    'parent_id' => $destination->id,
                ]
            )
            ->assertHasNoActionErrors();

        $this->assertDatabaseHas('business_categories', [
            'id' => $leaf->id,
            'parent_id' => $destination->id,
        ]);
    }

    private function loginAdmin(): User
    {
        $admin = User::factory()->create(['status' => 'active']);

        DB::table('platform_role_assignments')->insert([
            'user_id' => $admin->id,
            'role_code' => 'platform_admin',
            'granted_at' => now(),
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
            'name_ar' => 'فئة اختبار',
            'parent_id' => $parentId,
            'is_active' => true,
            'sort_order' => 0,
        ]);
    }
}
