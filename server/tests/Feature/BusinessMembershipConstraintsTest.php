<?php

/*
|--------------------------------------------------------------------------
| اختبارات عضويات الأنشطة التجارية
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التأكد من ربط المستخدم بالنشاط بشكل صحيح.
| - منع تكرار عضوية نفس المستخدم في نفس النشاط.
| - السماح للمستخدم بالانضمام إلى أكثر من نشاط.
| - السماح للعضوية بالحصول على أكثر من دور.
| - منع تكرار نفس الدور داخل العضوية نفسها.
|
*/

namespace Tests\Feature;

use App\Models\Business;
use App\Models\BusinessMembership;
use App\Models\BusinessRole;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BusinessMembershipConstraintsTest extends TestCase
{
    use RefreshDatabase;

    /**
     * يمكن ربط مستخدم بنشاط من خلال عضوية.
     */
    public function test_user_can_join_a_business(): void
    {
        $user = User::factory()->create();

        $business = Business::create([
            'name' => 'نشاط اختبار',
        ]);

        $membership = $user->memberships()->create([
            'business_id' => $business->id,
            'status' => 'active',
        ]);

        $this->assertTrue($membership->user->is($user));
        $this->assertTrue($membership->business->is($business));

        $this->assertTrue(
            $business->memberships()
                ->whereKey($membership->id)
                ->exists(),
        );
    }

    /**
     * لا يسمح للمستخدم بامتلاك عضويتين
     * في النشاط نفسه.
     */
    public function test_user_cannot_have_duplicate_membership_in_same_business(): void
    {
        $user = User::factory()->create();

        $business = Business::create([
            'name' => 'نشاط واحد',
        ]);

        BusinessMembership::create([
            'user_id' => $user->id,
            'business_id' => $business->id,
            'status' => 'active',
        ]);

        $this->expectException(QueryException::class);

        BusinessMembership::create([
            'user_id' => $user->id,
            'business_id' => $business->id,
            'status' => 'active',
        ]);
    }

    /**
     * يمكن للمستخدم الانضمام إلى أكثر من نشاط.
     */
    public function test_user_can_join_multiple_businesses(): void
    {
        $user = User::factory()->create();

        $firstBusiness = Business::create([
            'name' => 'النشاط الأول',
        ]);

        $secondBusiness = Business::create([
            'name' => 'النشاط الثاني',
        ]);

        $user->memberships()->create([
            'business_id' => $firstBusiness->id,
            'status' => 'active',
        ]);

        $user->memberships()->create([
            'business_id' => $secondBusiness->id,
            'status' => 'active',
        ]);

        $this->assertSame(
            2,
            $user->memberships()->count(),
        );
    }

    /**
     * يمكن للعضوية امتلاك أكثر من دور.
     *
     * مثال:
     * owner + manager
     */
    public function test_membership_can_have_multiple_roles(): void
    {
        $user = User::factory()->create();

        $business = Business::create([
            'name' => 'نشاط متعدد الأدوار',
        ]);

        $membership = $user->memberships()->create([
            'business_id' => $business->id,
            'status' => 'active',
        ]);

        $owner = BusinessRole::create([
            'code' => 'owner',
            'is_active' => true,
        ]);

        $manager = BusinessRole::create([
            'code' => 'manager',
            'is_active' => true,
        ]);

        $membership->roles()->attach($owner->code, [
            'assigned_at' => now(),
        ]);

        $membership->roles()->attach($manager->code, [
            'assigned_at' => now(),
        ]);

        $this->assertTrue(
            $membership->roles()->where('code', 'owner')->exists(),
        );

        $this->assertTrue(
            $membership->roles()->where('code', 'manager')->exists(),
        );

        $this->assertSame(
            2,
            $membership->roles()->count(),
        );
    }

    /**
     * لا يسمح بتكرار نفس الدور للعضوية نفسها.
     */
    public function test_same_role_cannot_be_assigned_twice_to_membership(): void
    {
        $user = User::factory()->create();

        $business = Business::create([
            'name' => 'نشاط اختبار الدور',
        ]);

        $membership = $user->memberships()->create([
            'business_id' => $business->id,
            'status' => 'active',
        ]);

        $role = BusinessRole::create([
            'code' => 'staff',
            'is_active' => true,
        ]);

        $membership->roles()->attach($role->code, [
            'assigned_at' => now(),
        ]);

        $this->expectException(QueryException::class);

        $membership->roles()->attach($role->code, [
            'assigned_at' => now(),
        ]);
    }
}
