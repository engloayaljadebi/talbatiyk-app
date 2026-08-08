<?php

/*
|--------------------------------------------------------------------------
| توحيد بيانات الدخول ووسائل الاتصال
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - توحيد اسم المستخدم قبل التخزين والبحث.
| - تحويل البريد إلى lowercase.
| - تنظيف القيم النصية من المسافات الخارجية.
| - إبقاء الهاتف بصيغة E.164 كما تم إدخاله.
|
*/

namespace App\Support;

use Illuminate\Support\Str;

class ContactValueNormalizer
{
    /**
     * توحيد اسم المستخدم.
     */
    public static function username(?string $value): string
    {
        return Str::lower(trim((string) $value));
    }

    /**
     * توحيد قيمة وسيلة الاتصال.
     */
    public static function contact(string $type, ?string $value): string
    {
        $value = trim((string) $value);

        return $type === 'email'
            ? Str::lower($value)
            : $value;
    }

    /**
     * توحيد معرف تسجيل الدخول.
     *
     * يفيد مع:
     * - username
     * - email
     * - phone
     */
    public static function login(?string $value): string
    {
        return Str::lower(trim((string) $value));
    }
}
