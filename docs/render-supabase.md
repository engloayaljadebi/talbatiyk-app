# نشر طلبيتك للاختبار الداخلي

شغّل Laravel على Render Free في فرانكفورت. عند إنشاء مشروع Supabase للاختبار، اختر فرانكفورت أيضًا إذا كانت متاحة.

## Supabase

1. أنشئ مشروعًا جديدًا للاختبار، وعطّل **Enable Data API** من إعداداته. يتصل Laravel مباشرة بقاعدة PostgreSQL.
2. من **Connect → Session pooler** خذ قيمة المضيف واسم المستخدم. يستخدم الإعداد المنفذ `5432` وقاعدة `postgres` واتصالًا مشفّرًا.
3. أنشئ حاوية عامة باسم `product-images` وحاوية خاصة باسم `private-assets`. خذ صورة تجريبية بدل أي وثيقة هوية حقيقية عند التحقق من البيئة.
4. من إعدادات **Storage → S3** فعّل S3 وانسخ رابط الاتصال والمنطقة وأنشئ مفتاح وصول. احتفظ بالمفتاح وكلمة مرور PostgreSQL في متغيرات Render.

## Render

أنشئ **New → Blueprint** واربط مستودع المشروع والفرع الذي يحتوي على `render.yaml`. يختار الملف خطة Free، ويولّد مفتاح التطبيق `APP_KEY`، ويفحص مسار `/up`. احتفظ بمفتاح التطبيق نفسه بين عمليات النشر.

| المتغير | القيمة |
| --- | --- |
| `DB_HOST` | المضيف الذي يظهر في Session pooler |
| `DB_USERNAME` | اسم مستخدم Session pooler بالشكل `postgres.<project-ref>` |
| `DB_PASSWORD` | كلمة مرور قاعدة البيانات |
| `SUPABASE_URL` | عنوان مشروع Supabase عبر HTTPS |
| `SUPABASE_S3_ENDPOINT` | عنوان S3 من إعدادات Storage |
| `SUPABASE_S3_REGION` | منطقة S3 كما تظهر في Supabase |
| `SUPABASE_S3_KEY` | Access Key ID |
| `SUPABASE_S3_SECRET` | Secret Access Key |

تطبق الخدمة الـ migrations والبيانات المرجعية عند بدء التشغيل. الإعداد ينشئ بيئة اختبار فارغة. إذا كنت تنقل قاعدة أو ملفات من بيئة موجودة، انسخها إلى قاعدة الاختبار والحاويات مع الحفاظ على مسارات الملفات قبل اختبارها.

## التحقق وبناء Android

من PowerShell، بعد ظهور الرابط الفعلي لخدمة Render:

```powershell
$serviceUrl = (Read-Host 'Render HTTPS URL').Trim().TrimEnd('/')
$api = "$serviceUrl/api/v1"
curl.exe --fail --max-time 120 "$serviceUrl/up"
if ($LASTEXITCODE -ne 0) { throw "Render health check failed." }
curl.exe --fail --max-time 120 -H "Accept: application/json" "$api/auth/registration-categories"
if ($LASTEXITCODE -ne 0) { throw "API check failed." }
flutter build appbundle --release "--dart-define=API_BASE_URL=$api" --dart-define=INTERNAL_TEST_API=true
```

ارفع ملف `build/app/outputs/bundle/release/app-release.aab` الموقّع إلى مسار **Internal testing** في Google Play. اختبر التسجيل وتسجيل الدخول ورفع صورة منتج، ثم أعد تشغيل الخدمة وتأكد أن الصورة تظل متاحة. اختبر أيضًا أن حاوية الملفات الخاصة تمنع القراءة دون صلاحية.

Render Free يدخل في وضع السكون بعد 15 دقيقة بلا طلبات. أول اتصال بعد السكون قد يستغرق نحو دقيقة.
