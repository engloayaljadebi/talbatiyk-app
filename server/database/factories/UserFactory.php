<?php

/*
|--------------------------------------------------------------------------
| مصنع بيانات المستخدم - UserFactory
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إنشاء مستخدمين وهميين للاختبارات والتطوير.
| - مطابقة الحقول الجديدة في جدول users.
| - إنشاء username فريد وآمن للاختبارات.
| - إنشاء حالات مختلفة للمستخدم عند اختبار النظام.
|
| ملاحظات:
| - البريد والهاتف لا ينشآن هنا؛ مكانهما user_contacts.
| - التوثيق لا يخزن في users؛ مكانه verifications.
|
*/

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * كلمة مرور مشفرة يعاد استخدامها أثناء الاختبارات
     * لتجنب إعادة عملية التشفير لكل مستخدم.
     */
    protected static ?string $password;

    /**
     * القيم الافتراضية للمستخدم التجريبي.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            /*
             * اسم مستخدم فريد للاختبارات.
             *
             * نستخدم أحرفًا صغيرة لتجنب أي تعارض
             * مع الفهرس غير الحساس لحالة الأحرف.
             */
            'username' => 'user_'.Str::lower(Str::random(16)),

            // الاسم الظاهر في واجهة التطبيق.
            'display_name' => fake()->name(),

            /*
             * كلمة المرور الافتراضية في الاختبارات هي:
             * password
             *
             * لكن القيمة المخزنة في PostgreSQL مشفرة.
             */
            'password' => static::$password ??= Hash::make('password'),

            // المستخدم يعمل بشكل طبيعي افتراضيًا.
            'status' => 'active',

            // لم يسجل دخولًا بعد.
            'last_login_at' => null,

            // يستخدمه Laravel عند الحاجة لجلسات الويب.
            'remember_token' => Str::random(10),
        ];
    }

    /**
     * إنشاء مستخدم موقوف مؤقتًا.
     */
    public function suspended(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'suspended',
        ]);
    }

    /**
     * إنشاء مستخدم معطل.
     */
    public function disabled(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'disabled',
        ]);
    }
}
