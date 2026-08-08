<?php

/*
|--------------------------------------------------------------------------
| مصنع وسائل اتصال المستخدم - UserContactFactory
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إنشاء وسائل اتصال وهمية للاختبارات.
| - إنشاء بريد إلكتروني افتراضيًا.
| - دعم إنشاء هاتف بصيغة موحدة.
| - دعم الوسيلة الرئيسية والموثقة.
|
*/

namespace Database\Factories;

use App\Models\User;
use App\Models\UserContact;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<UserContact>
 */
class UserContactFactory extends Factory
{
    /**
     * النموذج المرتبط بهذا المصنع.
     *
     * @var class-string<UserContact>
     */
    protected $model = UserContact::class;

    /**
     * البيانات الافتراضية لوسيلة الاتصال.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            // إنشاء مستخدم تلقائيًا إذا لم يتم تمرير مستخدم موجود.
            'user_id' => User::factory(),

            // البريد هو النوع الافتراضي للمصنع.
            'type' => 'email',

            // نخزن البريد بصيغة lowercase موحدة.
            'value' => Str::lower(fake()->unique()->safeEmail()),

            'is_primary' => false,
            'verified_at' => null,
        ];
    }

    /**
     * إنشاء رقم هاتف بصيغة دولية موحدة.
     */
    public function phone(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'phone',
            'value' => '+967'.fake()->unique()->numerify('7########'),
        ]);
    }

    /**
     * جعل وسيلة الاتصال رئيسية.
     */
    public function primary(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_primary' => true,
        ]);
    }

    /**
     * جعل وسيلة الاتصال موثقة.
     */
    public function verified(): static
    {
        return $this->state(fn (array $attributes) => [
            'verified_at' => now(),
        ]);
    }
}
