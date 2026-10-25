<?php

declare(strict_types=1);

namespace Tests\Feature\Platform;

use App\Filament\Resources\Users\Pages\ManageUsers;
use App\Filament\Resources\Verifications\Pages\ManageVerifications;
use App\Filament\Resources\Verifications\VerificationResource;
use App\Models\Business;
use App\Models\BusinessCategory;
use App\Models\User;
use App\Models\Verification;
use App\Services\Business\BusinessOnboardingService;
use App\Services\Platform\AdminUserCreationService;
use App\Services\User\PrivateUserAssetStorage;
use Database\Seeders\BusinessCapabilitySeeder;
use Database\Seeders\BusinessRoleSeeder;
use Filament\Facades\Filament;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;
use Livewire\Livewire;
use RuntimeException;
use Tests\TestCase;

final class UnifiedUserCreationFilamentTest extends TestCase
{
    use DatabaseTransactions;

    private string $categoryId;

    protected function setUp(): void
    {
        parent::setUp();

        $actual = DB::selectOne('SELECT current_database() AS name')->name;

        if (
            DB::connection()->getDatabaseName() !== 'talbatiyk_testing'
            || $actual !== 'talbatiyk_testing'
        ) {
            throw new RuntimeException('Unsafe database.');
        }

        Storage::fake('talbatiyk_private');

        $this->seed(BusinessRoleSeeder::class);
        $this->seed(BusinessCapabilitySeeder::class);

        Filament::setCurrentPanel(Filament::getPanel('admin'));

        $category = BusinessCategory::query()->create([
            'code' => 'unified_user_'.Str::lower(Str::random(10)),
            'name_ar' => 'فئة اختبار الشاشة الموحدة',
            'parent_id' => null,
            'is_active' => true,
            'sort_order' => 999,
        ]);

        $this->categoryId = $category->id;
    }

    public function test_creation_form_declares_only_the_approved_input_fields(): void
    {
        $source = file_get_contents(app_path('Filament/Resources/Users/Pages/ManageUsers.php'));

        foreach ([
            "Select::make('account_type')",
            "TextInput::make('username')",
            "TextInput::make('display_name')",
            "TextInput::make('password')",
            "TextInput::make('password_confirmation')",
            "Select::make('contact_type')",
            "TextInput::make('contact_value')",
            "Select::make('nationality_country_code')",
            "DatePicker::make('birth_date')",
            "FileUpload::make('profile_photo')",
            "Select::make('identity_document_type')",
            "TextInput::make('identity_document_number')",
            "FileUpload::make('identity_document_front')",
            "FileUpload::make('identity_document_back')",
            "TextInput::make('name')",
            "Select::make('category_id')",
            "Textarea::make('description')",
            "FileUpload::make('business_logo')",
            "TextInput::make('location_name')",
            "TextInput::make('administrative_area')",
            "TextInput::make('locality')",
        ] as $field) {
            $this->assertStringContainsString($field, $source);
        }

        foreach ([
            "additional_contact_type",
            "legal_name",
            "location_type",
            "business_contact_type",
            "additional_business_contact_type",
            "street_address",
            "latitude",
            "longitude",
        ] as $forbiddenField) {
            $this->assertStringNotContainsString($forbiddenField, $source);
        }
    }

    public function test_shop_can_be_created_from_user_management_with_pending_approval(): void
    {
        $this->loginAdmin();
        $payload = $this->payload('shop');

        Livewire::test(ManageUsers::class)
            ->assertSuccessful()
            ->assertActionExists('createUser')
            ->callAction('createUser', data: $payload)
            ->assertHasNoActionErrors();

        $this->assertCreatedBusinessAndPendingApproval($payload, 'shop', 'shop_approval');
    }

    public function test_supplier_can_be_created_from_the_same_user_management_action(): void
    {
        $this->loginAdmin();
        $payload = $this->payload('supplier');

        Livewire::test(ManageUsers::class)
            ->assertSuccessful()
            ->assertActionExists('createUser')
            ->callAction('createUser', data: $payload)
            ->assertHasNoActionErrors();

        $this->assertCreatedBusinessAndPendingApproval($payload, 'supplier', 'supplier_approval');
    }

    public function test_supplier_creation_still_requires_supplier_review_permission(): void
    {
        $admin = $this->loginAdmin();
        $payload = $this->payload('supplier');

        Gate::define(
            'reviewSupplierApprovals',
            fn (User $user): bool => false,
        );

        try {
            app(AdminUserCreationService::class)->create($admin, $payload);
            $this->fail('Supplier creation succeeded without review permission.');
        } catch (AuthorizationException) {
            // Expected: the unified form must preserve the previous permission boundary.
        }

        $this->assertDatabaseMissing('users', [
            'username' => $payload['username'],
        ]);
    }

    public function test_verifications_page_no_longer_has_a_separate_supplier_creation_action(): void
    {
        $this->loginAdmin();

        Livewire::test(ManageVerifications::class)
            ->assertSuccessful()
            ->assertActionDoesNotExist('createSupplierUser');
    }

    public function test_unified_creation_rolls_back_account_and_contacts_when_onboarding_fails(): void
    {
        $admin = $this->loginAdmin();
        $payload = $this->payload('shop');

        $usersBefore = DB::table('users')->count();
        $userContactsBefore = DB::table('user_contacts')->count();
        $businessesBefore = DB::table('businesses')->count();
        $businessContactsBefore = DB::table('business_contacts')->count();
        $locationsBefore = DB::table('business_locations')->count();
        $membershipsBefore = DB::table('business_memberships')->count();
        $verificationsBefore = DB::table('verifications')->count();

        $this->mock(BusinessOnboardingService::class, function ($mock): void {
            $mock->shouldReceive('create')
                ->once()
                ->andThrow(new RuntimeException('Onboarding failed for rollback test.'));
        });

        try {
            app(AdminUserCreationService::class)->create($admin, $payload);
            $this->fail('Expected onboarding failure.');
        } catch (RuntimeException $exception) {
            $this->assertSame('Onboarding failed for rollback test.', $exception->getMessage());
        }

        $this->assertSame($usersBefore, DB::table('users')->count());
        $this->assertSame($userContactsBefore, DB::table('user_contacts')->count());
        $this->assertSame($businessesBefore, DB::table('businesses')->count());
        $this->assertSame($businessContactsBefore, DB::table('business_contacts')->count());
        $this->assertSame($locationsBefore, DB::table('business_locations')->count());
        $this->assertSame($membershipsBefore, DB::table('business_memberships')->count());
        $this->assertSame($verificationsBefore, DB::table('verifications')->count());
        $this->assertDatabaseMissing('users', ['username' => $payload['username']]);
    }

    public function test_private_assets_and_identity_data_are_saved_without_database_columns(): void
    {
        $admin = $this->loginAdmin();
        $payload = $this->payload('shop');
        $disk = Storage::disk('talbatiyk_private');

        $disk->putFileAs('staging/admin-user-creation', UploadedFile::fake()->image('profile.png'), 'profile.png');
        $disk->putFileAs('staging/admin-user-creation', UploadedFile::fake()->image('front.png'), 'front.png');
        $disk->putFileAs('staging/admin-user-creation', UploadedFile::fake()->image('back.png'), 'back.png');
        $disk->putFileAs('staging/admin-user-creation', UploadedFile::fake()->image('logo.png'), 'logo.png');

        $payload['profile_photo'] = 'staging/admin-user-creation/profile.png';
        $payload['identity_document_type'] = 'national_id';
        $payload['identity_document_number'] = 'TEST-12345';
        $payload['identity_document_front'] = 'staging/admin-user-creation/front.png';
        $payload['identity_document_back'] = 'staging/admin-user-creation/back.png';
        $payload['business_logo'] = 'staging/admin-user-creation/logo.png';

        $user = app(AdminUserCreationService::class)->create($admin, $payload);
        $businessId = DB::table('business_memberships')
            ->where('user_id', $user->id)
            ->value('business_id');
        $business = Business::query()->findOrFail($businessId);
        $assets = app(PrivateUserAssetStorage::class);

        $this->assertNotNull($assets->profilePhotoPath($user));
        $this->assertNotNull($assets->businessLogoPath($business));

        $identity = $assets->readIdentityDocument($user);
        $this->assertNotNull($identity);
        $this->assertSame('national_id', $identity['type']);
        $this->assertSame('TEST-12345', $identity['number']);
        $this->assertNotNull($assets->readIdentityDocumentImage($user, 'front'));
        $this->assertNotNull($assets->readIdentityDocumentImage($user, 'back'));

        $encryptedMetadata = $disk->get('users/'.$user->id.'/identity-document.enc');
        $this->assertStringNotContainsString('TEST-12345', $encryptedMetadata);
        $this->assertFalse($disk->exists('staging/admin-user-creation/profile.png'));
        $this->assertDatabaseHas('business_locations', [
            'business_id' => $businessId,
            'administrative_area' => 'Amanat Al Asimah',
            'locality' => 'Sanaa',
        ]);
    }

    private function assertCreatedBusinessAndPendingApproval(
        array $payload,
        string $capability,
        string $verificationType,
    ): void {
        $user = User::query()
            ->where('username', $payload['username'])
            ->firstOrFail();

        $this->assertSame('active', $user->status);

        $this->assertDatabaseHas('user_contacts', [
            'user_id' => $user->id,
            'type' => $payload['contact_type'],
            'value' => $payload['contact_value'],
            'is_primary' => true,
        ]);

        $this->assertDatabaseHas('user_profiles', [
            'user_id' => $user->id,
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-15',
        ]);

        $membership = DB::table('business_memberships')
            ->where('user_id', $user->id)
            ->first();

        $this->assertNotNull($membership);

        $businessId = $membership->business_id;

        $this->assertDatabaseHas('businesses', [
            'id' => $businessId,
            'name' => $payload['name'],
            'legal_name' => null,
            'status' => 'active',
        ]);

        $this->assertDatabaseHas('business_category_assignments', [
            'business_id' => $businessId,
            'category_id' => $this->categoryId,
        ]);

        $this->assertSame(
            1,
            DB::table('business_category_assignments')
                ->where('business_id', $businessId)
                ->count(),
        );

        $this->assertDatabaseHas('business_locations', [
            'business_id' => $businessId,
            'name' => $payload['location_name'],
            'country_code' => 'YE',
            'administrative_area' => $payload['administrative_area'],
            'locality' => $payload['locality'],
            'is_primary' => true,
        ]);

        $this->assertDatabaseMissing('business_contacts', [
            'business_id' => $businessId,
        ]);

        $this->assertSame(
            1,
            Verification::query()
                ->where('business_id', $businessId)
                ->where('verification_type_code', $verificationType)
                ->where('status', 'pending')
                ->count(),
        );

        $this->assertDatabaseMissing('business_capability_assignments', [
            'business_id' => $businessId,
            'capability_code' => $capability,
            'disabled_at' => null,
        ]);

        $verification = Verification::query()
            ->where('business_id', $businessId)
            ->where('verification_type_code', $verificationType)
            ->firstOrFail();

        $this->assertTrue(
            VerificationResource::getEloquentQuery()
                ->whereKey($verification->id)
                ->exists(),
        );
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

    private function payload(string $accountType): array
    {
        $suffix = Str::lower(Str::random(8));

        return [
            'account_type' => $accountType,
            'username' => 'unified_'.$accountType.'_'.$suffix,
            'display_name' => 'Unified '.ucfirst($accountType).' User',
            'password' => 'StrongPass123!',
            'password_confirmation' => 'StrongPass123!',
            'contact_type' => 'phone',
            'contact_value' => '+9677'.random_int(10000000, 99999999),
            'nationality_country_code' => 'YE',
            'birth_date' => '2000-01-15',
            'name' => 'Unified '.ucfirst($accountType).' Business',
            'category_id' => $this->categoryId,
            'description' => 'Unified user creation test.',
            'location_name' => 'Main location',
            'administrative_area' => 'Amanat Al Asimah',
            'locality' => 'Sanaa',
        ];
    }
}

