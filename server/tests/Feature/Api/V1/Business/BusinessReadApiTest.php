<?php

/*
|--------------------------------------------------------------------------
| اختبارات قراءة الأنشطة التجارية
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التأكد أن المستخدم يرى الأنشطة التي لديه عضوية active فيها فقط.
| - منع تسريب أنشطة المستخدمين الآخرين.
| - منع suspended و left من الوصول الإداري للنشاط.
| - إعادة 404 عند محاولة قراءة نشاط بدون عضوية نشطة.
| - التأكد أن BusinessResource يعرض عضوية المستخدم الحالي فقط.
|
*/

namespace Tests\Feature\Api\V1\Business;

use App\Models\Business;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class BusinessReadApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * المستخدم المصادق يرى فقط الأنشطة
     * التي لديه عضوية active فيها.
     */
    public function test_user_can_list_only_businesses_with_active_membership(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $otherUser = User::factory()->create([
            'status' => 'active',
        ]);

        $activeBusiness = $this->createBusinessWithMembership(
            user: $user,
            businessName: 'نشاط نشط',
            membershipStatus: 'active',
        );

        $suspendedBusiness = $this->createBusinessWithMembership(
            user: $user,
            businessName: 'نشاط معلق العضوية',
            membershipStatus: 'suspended',
        );

        $leftBusiness = $this->createBusinessWithMembership(
            user: $user,
            businessName: 'نشاط تمت مغادرته',
            membershipStatus: 'left',
        );

        $otherBusiness = $this->createBusinessWithMembership(
            user: $otherUser,
            businessName: 'نشاط مستخدم آخر',
            membershipStatus: 'active',
        );

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/businesses');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonFragment([
                'id' => $activeBusiness->id,
                'name' => 'نشاط نشط',
            ])
            ->assertJsonMissing([
                'id' => $suspendedBusiness->id,
            ])
            ->assertJsonMissing([
                'id' => $leftBusiness->id,
            ])
            ->assertJsonMissing([
                'id' => $otherBusiness->id,
            ]);
    }

    /**
     * المستخدم يستطيع قراءة تفاصيل نشاط
     * إذا كانت لديه عضوية active فيه.
     */
    public function test_user_can_read_business_with_active_membership(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithMembership(
            user: $user,
            businessName: 'الجعدبي فون',
            membershipStatus: 'active',
        );

        Sanctum::actingAs($user);

        $this
            ->getJson("/api/v1/businesses/{$business->id}")
            ->assertOk()
            ->assertJsonPath('data.id', $business->id)
            ->assertJsonPath('data.name', 'الجعدبي فون')
            ->assertJsonPath('data.membership.status', 'active');
    }

    /**
     * مستخدم آخر لا يجب أن يستطيع معرفة
     * تفاصيل نشاط لا يملك عضوية فيه.
     *
     * نعيد 404 بدل 403 حتى لا نكشف وجود النشاط.
     */
    public function test_user_receives_not_found_for_business_without_membership(): void
    {
        $owner = User::factory()->create([
            'status' => 'active',
        ]);

        $otherUser = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithMembership(
            user: $owner,
            businessName: 'نشاط خاص',
            membershipStatus: 'active',
        );

        Sanctum::actingAs($otherUser);

        $this
            ->getJson("/api/v1/businesses/{$business->id}")
            ->assertNotFound();
    }

    /**
     * العضوية suspended لا تمنح الوصول
     * إلى تفاصيل النشاط.
     */
    public function test_suspended_membership_cannot_read_business(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithMembership(
            user: $user,
            businessName: 'نشاط بعضوية معلقة',
            membershipStatus: 'suspended',
        );

        Sanctum::actingAs($user);

        $this
            ->getJson("/api/v1/businesses/{$business->id}")
            ->assertNotFound();
    }

    /**
     * العضوية left لا تمنح الوصول
     * بعد مغادرة النشاط.
     */
    public function test_left_membership_cannot_read_business(): void
    {
        $user = User::factory()->create([
            'status' => 'active',
        ]);

        $business = $this->createBusinessWithMembership(
            user: $user,
            businessName: 'نشاط تمت مغادرته',
            membershipStatus: 'left',
        );

        Sanctum::actingAs($user);

        $this
            ->getJson("/api/v1/businesses/{$business->id}")
            ->assertNotFound();
    }

    /**
     * إذا كان للنشاط أعضاء متعددون،
     * يجب أن تعرض الاستجابة عضوية المستخدم الحالي فقط.
     */
    public function test_business_response_contains_current_user_membership_only(): void
    {
        $otherUser = User::factory()->create([
            'status' => 'active',
        ]);

        $currentUser = User::factory()->create([
            'status' => 'active',
        ]);

        $business = Business::create([
            'name' => 'نشاط متعدد الأعضاء',
            'status' => 'active',
        ]);

        /*
         * ننشئ عضوية المستخدم الآخر أولًا عمدًا.
         *
         * لو كانت BusinessResource تستخدم أول عضوية
         * بدون تصفية، سيظهر ID هذه العضوية بالخطأ.
         */
        $otherMembership = $business->memberships()->create([
            'user_id' => $otherUser->id,
            'status' => 'active',
            'joined_at' => now()->subDay(),
            'left_at' => null,
        ]);

        $currentMembership = $business->memberships()->create([
            'user_id' => $currentUser->id,
            'status' => 'active',
            'joined_at' => now(),
            'left_at' => null,
        ]);

        Sanctum::actingAs($currentUser);

        $this
            ->getJson("/api/v1/businesses/{$business->id}")
            ->assertOk()
            ->assertJsonPath(
                'data.membership.id',
                $currentMembership->id,
            )
            ->assertJsonMissing([
                'membership' => [
                    'id' => $otherMembership->id,
                ],
            ]);
    }

    /**
     * الزائر غير المسجل لا يستطيع
     * قراءة قائمة الأنشطة.
     */
    public function test_guest_cannot_list_businesses(): void
    {
        $this
            ->getJson('/api/v1/businesses')
            ->assertUnauthorized();
    }

    /**
     * إنشاء نشاط وعضوية لاستخدامهما داخل الاختبارات.
     */
    private function createBusinessWithMembership(
        User $user,
        string $businessName,
        string $membershipStatus,
    ): Business {
        $business = Business::create([
            'name' => $businessName,
            'status' => 'active',
        ]);

        $business->memberships()->create([
            'user_id' => $user->id,
            'status' => $membershipStatus,
            'joined_at' => now(),

            /*
             * قاعدة البيانات تشترط left_at
             * عندما تصبح حالة العضوية left.
             */
            'left_at' => $membershipStatus === 'left'
                ? now()
                : null,
        ]);

        return $business;
    }
}
