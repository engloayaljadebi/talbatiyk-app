<?php

/*
|--------------------------------------------------------------------------
| اختبارات قيود وسائل اتصال المستخدم
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - التأكد من إنشاء وسيلة الاتصال وربطها بالمستخدم.
| - منع تكرار البريد حتى مع اختلاف الأحرف الكبيرة والصغيرة.
| - منع وجود أكثر من وسيلة رئيسية من النوع نفسه للمستخدم.
| - السماح بهاتف رئيسي وبريد رئيسي لنفس المستخدم.
| - التأكد من أن الحذف المنطقي يسمح بإعادة استخدام الوسيلة.
|
*/

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserContact;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserContactConstraintsTest extends TestCase
{
    use RefreshDatabase;

    /**
     * يمكن إنشاء وسيلة اتصال مرتبطة بالمستخدم.
     */
    public function test_user_can_have_a_contact(): void
    {
        $user = User::factory()->create();

        $contact = UserContact::factory()
            ->for($user)
            ->create();

        $this->assertTrue($contact->user->is($user));
        $this->assertTrue($user->contacts()->whereKey($contact->id)->exists());
    }

    /**
     * يمنع تكرار البريد الإلكتروني حتى عند اختلاف حالة الأحرف.
     */
    public function test_duplicate_email_is_rejected_case_insensitively(): void
    {
        UserContact::factory()->create([
            'type' => 'email',
            'value' => 'sales@example.test',
        ]);

        $this->expectException(QueryException::class);

        UserContact::factory()->create([
            'type' => 'email',
            'value' => 'SALES@example.test',
        ]);
    }

    /**
     * يمنع أكثر من بريد رئيسي لنفس المستخدم.
     */
    public function test_user_cannot_have_two_primary_emails(): void
    {
        $user = User::factory()->create();

        UserContact::factory()
            ->for($user)
            ->primary()
            ->create();

        $this->expectException(QueryException::class);

        UserContact::factory()
            ->for($user)
            ->primary()
            ->create();
    }

    /**
     * يمكن للمستخدم امتلاك بريد رئيسي وهاتف رئيسي معًا.
     */
    public function test_user_can_have_primary_email_and_primary_phone(): void
    {
        $user = User::factory()->create();

        $email = UserContact::factory()
            ->for($user)
            ->primary()
            ->create();

        $phone = UserContact::factory()
            ->for($user)
            ->phone()
            ->primary()
            ->create();

        $this->assertTrue($email->is_primary);
        $this->assertTrue($phone->is_primary);

        $this->assertSame(
            2,
            $user->contacts()->where('is_primary', true)->count(),
        );
    }

    /**
     * بعد الحذف المنطقي يمكن إعادة استخدام البريد نفسه.
     */
    public function test_soft_deleted_contact_value_can_be_reused(): void
    {
        $contact = UserContact::factory()->create([
            'type' => 'email',
            'value' => 'reuse@example.test',
        ]);

        $contact->delete();

        $replacement = UserContact::factory()->create([
            'type' => 'email',
            'value' => 'reuse@example.test',
        ]);

        $this->assertNotSame($contact->id, $replacement->id);
    }
}
