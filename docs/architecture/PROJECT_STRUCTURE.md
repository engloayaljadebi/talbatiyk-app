\# Talbatiyk Project Structure



\## 1. Purpose



هذه الوثيقة هي المرجع الرسمي لهيكل مشروع \*\*Talbatiyk / طلبيتك\*\*.



الهدف منها:



\* الحفاظ على نفس المعمارية الحالية وعدم تغييرها عشوائيًا.

\* تحديد مكان كل Feature وملف قبل بدء تنفيذه.

\* منع تكرار المسؤوليات بين الملفات.

\* إبقاء Flutter مبنيًا بأسلوب Local-First Clean Architecture.

\* إبقاء Laravel مقسمًا إلى Request / Controller / Service / Model / Resource.

\* منع إنشاء Placeholder files غير مستخدمة.

\* إنشاء Models وMigrations فقط عند بدء المرحلة التي تحتاجها.



\---



\# 2. Project Root



```text

talbatiyk/

│

├── lib/                       Flutter application

├── test/                      Flutter tests

├── integration\_test/          Flutter integration tests

│

├── server/                    Laravel REST API

│

├── contracts/                 API contracts

├── docs/                      Project documentation

├── tool/                      Project tooling

│

├── pubspec.yaml

└── README.md

```



\---



\# 3. Flutter Architecture



المعمارية المعتمدة:



```text

Presentation

&#x20;    ↓

Controller / Provider

&#x20;    ↓

UseCase

&#x20;    ↓

Repository

&#x20;  ↙       ↘

Local      Remote

Drift      REST API

&#x20;  ↘       ↙

&#x20;  Sync Queue

```



التطبيق Local-First.



هذا يعني أن البيانات المحلية في Drift تظل المصدر الأساسي للعمل أثناء انقطاع الإنترنت، ثم تتم المزامنة مع Laravel عند توفر الاتصال.



\---



\# 4. Flutter Core



```text

lib/core/

│

├── config/

│

├── database/

│   ├── daos/

│   ├── tables/

│   └── migrations/

│

├── di/

│

├── network/

│   ├── clients/

│   ├── interceptors/

│   └── generated/

│

├── router/

│

├── storage/

│

├── sync/

│   ├── queue/

│   ├── workers/

│   ├── conflict/

│   └── models/

│

├── errors/

├── logging/

├── theme/

└── utils/

```



\## Responsibilities



\### `core/database`



قاعدة البيانات المحلية Drift وكل ما يتعلق بها.



\### `core/network`



البنية المشتركة للاتصال مع Laravel REST API.



\### `core/network/generated`



مخصص مستقبلًا للعميل المولد من OpenAPI.



لا يتم تعديل الملفات المولدة داخله يدويًا.



\### `core/sync`



المزامنة بين Drift وLaravel.



يتضمن:



\* Sync Queue.

\* Retry handling.

\* Conflict resolution.

\* Background synchronization.



\### `core/storage`



تخزين الملفات والصور والبيانات المحلية غير التابعة مباشرة إلى Drift.



\### `core/errors`



أنواع الأخطاء المشتركة داخل التطبيق.



\### `core/logging`



التسجيل المنظم للأخطاء والأحداث بدل استخدام `print`.



\---



\# 5. Flutter Feature Template



كل Feature أساسية تستخدم الهيكل التالي:



```text

feature/

│

├── data/

│   ├── datasources/

│   │   ├── local/

│   │   └── remote/

│   │

│   ├── models/

│   └── repositories/

│

├── domain/

│   ├── entities/

│   ├── repositories/

│   └── usecases/

│

└── presentation/

&#x20;   ├── controllers/

&#x20;   ├── providers/

&#x20;   ├── pages/

&#x20;   └── widgets/

```



\---



\# 6. Flutter Features



الـFeatures الأساسية:



```text

lib/features/

│

├── auth/

├── businesses/

├── verification/

├── follows/

├── products/

├── cart/

├── orders/

├── account/

├── notifications/

├── home/

└── navigation/

```



لا يتم إنشاء Features منفصلة باسم:



```text

supplier/

shop/

```



لأن المورد والمتجر ليسا نوعين مختلفين من المستخدمين.



يتم تمثيلهما عن طريق:



```text

Business

&#x20;  ↓

Capabilities

&#x20;  ├── supplier

&#x20;  └── shop

```



\---



\# 7. Auth Feature



المسار:



```text

lib/features/auth/

```



الملفات المتوقعة عند تنفيذ ربط Auth:



```text

data/

├── datasources/

│   ├── local/

│   │   └── auth\_local\_data\_source.dart

│   │

│   └── remote/

│       └── auth\_remote\_data\_source.dart

│

├── models/

│   ├── authenticated\_user\_model.dart

│   └── auth\_session\_model.dart

│

└── repositories/

&#x20;   └── auth\_repository\_impl.dart



domain/

├── entities/

│   ├── authenticated\_user\_entity.dart

│   └── auth\_session\_entity.dart

│

├── repositories/

│   └── auth\_repository.dart

│

└── usecases/

&#x20;   ├── register\_usecase.dart

&#x20;   ├── login\_usecase.dart

&#x20;   ├── logout\_usecase.dart

&#x20;   └── get\_current\_user\_usecase.dart



presentation/

├── controllers/

│   └── auth\_controller.dart

│

├── providers/

│   └── auth\_provider.dart

│

├── pages/

│   ├── login\_page.dart

│   └── register\_page.dart

│

└── widgets/

```



\---



\# 8. Businesses Feature



المسار:



```text

lib/features/businesses/

```



المسؤوليات:



\* قائمة أنشطة المستخدم.

\* تفاصيل النشاط.

\* إنشاء النشاط.

\* تعديل النشاط.

\* المواقع والفروع.

\* وسائل التواصل.

\* capabilities.

\* أوقات العمل.



الهيكل المتوقع:



```text

businesses/

│

├── data/

│   ├── datasources/

│   │   ├── local/

│   │   └── remote/

│   ├── models/

│   └── repositories/

│

├── domain/

│   ├── entities/

│   ├── repositories/

│   └── usecases/

│

└── presentation/

&#x20;   ├── controllers/

&#x20;   ├── providers/

&#x20;   ├── pages/

&#x20;   └── widgets/

```



\---



\# 9. Verification Feature



```text

lib/features/verification/

```



المسؤوليات:



\* تقديم طلب توثيق.

\* قراءة حالة التوثيق.

\* عرض حالة النشاط أو المستخدم الموثق.

\* التعامل مع حالات pending / approved / rejected مستقبلًا.



\---



\# 10. Follow Feature



```text

lib/features/follows/

```



العلاقة الأساسية:



```text

Shop Business

&#x20;     ↓

&#x20;   follows

&#x20;     ↓

Supplier Business

```



هذه العلاقة ستكون الأساس لاحقًا لقاعدة:



> منتجات المورد لا تظهر إلا للأنشطة التي تتبعه، مع استثناءات الإدارة ومالك المورد.



\---



\# 11. Products Feature



المسار الحالي:



```text

lib/features/products/

```



ويظل على نفس الهيكل الحالي:



```text

products/

├── data/

├── domain/

└── presentation/

```



المسؤوليات المستقبلية:



\* CRUD المنتجات.

\* Local-first persistence.

\* الصور.

\* المزامنة.

\* Product Visibility.

\* البحث.

\* الفئات.

\* تفاصيل المنتج.



\---



\# 12. Cart Feature



```text

lib/features/cart/

```



السلة Local-First.



لا يجب إرسال كل تعديل في الكمية إلى Laravel مباشرة.



التدفق:



```text

Product

&#x20;  ↓

Local Cart / Drift

&#x20;  ↓

User confirms

&#x20;  ↓

Order

&#x20;  ↓

Laravel

```



\---



\# 13. Orders Feature



```text

lib/features/orders/

```



المسؤوليات:



\* إنشاء الطلب.

\* بنود الطلب.

\* اختيار المورد.

\* الطلبات الصادرة.

\* الطلبات الواردة.

\* حالات الطلب.

\* المزامنة.

\* سجل تغير الحالة.



\---



\# 14. Laravel Architecture



البنية العامة المعتمدة:



```text

Request

&#x20;  ↓

Controller

&#x20;  ↓

Service

&#x20;  ↓

Model / Database

&#x20;  ↓

Resource

```



كل طبقة لها مسؤولية واحدة.



\---



\# 15. Laravel Application Structure



```text

server/app/

│

├── Http/

│   ├── Controllers/

│   │   └── Api/

│   │       └── V1/

│   │           ├── Auth/

│   │           ├── Business/

│   │           ├── Verification/

│   │           ├── Follow/

│   │           ├── Product/

│   │           └── Order/

│   │

│   ├── Requests/

│   │   └── Api/

│   │       └── V1/

│   │           ├── Auth/

│   │           ├── Business/

│   │           ├── Verification/

│   │           ├── Follow/

│   │           ├── Product/

│   │           └── Order/

│   │

│   ├── Resources/

│   │   └── Api/

│   │       └── V1/

│   │

│   └── Middleware/

│

├── Models/

│

├── Services/

│   ├── Auth/

│   ├── Authorization/

│   ├── Business/

│   ├── Verification/

│   ├── Follow/

│   ├── Product/

│   ├── Order/

│   └── Sync/

│

├── Policies/

├── Enums/

├── Jobs/

├── Notifications/

└── Support/

```



\---



\# 16. Controllers



Controller يجب أن يكون خفيفًا.



مسؤولياته:



```text

Receive request

↓

Call service

↓

Return resource/response

```



لا يوضع فيه منطق Business معقد.



\---



\# 17. Requests



كل Input قادم من API يتم التحقق منه داخل Form Request عندما تكون العملية تحتاج Validation.



مثال:



```text

CreateBusinessRequest

UpdateBusinessRequest

CreateProductRequest

CreateOrderRequest

```



المسؤوليات:



\* Validation.

\* Normalization.

\* prepareForValidation عند الحاجة.

\* رسائل Validation الخاصة بالـAPI عند الحاجة.



\---



\# 18. Services



Services هي مكان Business Logic.



أمثلة مستقبلية:



```text

Services/Business/

├── BusinessOnboardingService.php

├── BusinessQueryService.php

├── BusinessUpdateService.php

├── BusinessAccessService.php

├── BusinessLocationService.php

├── BusinessContactService.php

├── BusinessCapabilityService.php

└── BusinessHoursService.php

```



لا يتم إنشاء الملف إلا عند بداية مرحلته.



\---



\# 19. Business Backend Roadmap



الموجود والمنجز:



```text

BusinessOnboardingService       DONE

BusinessQueryService            DONE

```



المراحل التالية:



```text

BusinessAccessService

BusinessUpdateService

BusinessLocationService

BusinessContactService

BusinessCapabilityService

BusinessHoursService

```



\---



\# 20. Verification Backend



المسار المتوقع:



```text

Http/Controllers/Api/V1/Verification/

Http/Requests/Api/V1/Verification/

Services/Verification/

```



الملفات تنشأ عند بدء Feature.



\---



\# 21. Follow Backend



المسار:



```text

Http/Controllers/Api/V1/Follow/

Services/Follow/

```



المسؤوليات:



\* Follow supplier.

\* Unfollow supplier.

\* Following list.

\* Followers list.

\* Access validation.



\---



\# 22. Product Backend



المسارات:



```text

Http/Controllers/Api/V1/Product/

Http/Requests/Api/V1/Product/

Services/Product/

```



Services المتوقعة:



```text

ProductService

ProductQueryService

ProductMediaService

ProductVisibilityService

```



\---



\# 23. Order Backend



المسارات:



```text

Http/Controllers/Api/V1/Order/

Http/Requests/Api/V1/Order/

Services/Order/

```



Services المتوقعة:



```text

OrderService

OrderQueryService

OrderStatusService

SupplierSelectionService

```



\---



\# 24. Sync Backend



```text

server/app/Services/Sync/

```



قد يحتوي مستقبلًا على:



```text

IdempotencyService

SyncConflictService

```



ولا يتم إنشاؤهما قبل الحاجة الفعلية.



\---



\# 25. Models



Models تبقى داخل:



```text

server/app/Models/

```



لا يتم إنشاء Model مسبقًا فقط لإكمال الهيكل.



يتم إنشاء Model عندما يصبح تصميم الجدول والعلاقات معروفًا.



مثال:



```powershell

php artisan make:model Product

```



\---



\# 26. Migrations



تبقى داخل:



```text

server/database/migrations/

```



لا يتم إنشاء Migrations مستقبلية كـPlaceholder.



كل Migration تنشأ عند بداية Feature حتى نحافظ على:



\* ترتيب التنفيذ.

\* Dependencies.

\* Foreign keys.

\* Constraints.

\* تاريخ Migration الصحيح.



\---



\# 27. API Versioning



كل API الخاص بتطبيق Flutter يبدأ بـ:



```text

/api/v1

```



مثل:



```text

/api/v1/auth/login

/api/v1/businesses

/api/v1/products

/api/v1/orders

```



\---



\# 28. OpenAPI



Laravel Scramble هو المصدر الحالي لـOpenAPI.



المصدر:



```text

/docs/api.json

```



لاحقًا يتم تصدير العقد إلى:



```text

contracts/openapi/

```



ثم يستخدم لتوليد Dart-Dio Client.



\---



\# 29. Generated API Client



المسار:



```text

lib/core/network/generated/

```



قاعدة ثابتة:



> Never manually edit generated API files.



أي تعديل يجب أن يبدأ من Laravel/OpenAPI ثم يعاد توليد Client.



\---



\# 30. Tests



Laravel:



```text

server/tests/

├── Feature/

│   └── Api/V1/

│       ├── Auth/

│       ├── Business/

│       ├── Verification/

│       ├── Follow/

│       ├── Product/

│       ├── Order/

│       └── Middleware/

│

└── Unit/

&#x20;   ├── Services/

&#x20;   ├── Policies/

&#x20;   └── Support/

```



Flutter:



```text

test/

├── core/

└── features/

```



Integration:



```text

integration\_test/

├── auth\_business\_flow/

├── product\_order\_flow/

└── offline\_sync\_flow/

```



\---



\# 31. Feature Development Workflow



كل Feature جديدة تمر بنفس الدورة:



```text

develop

&#x20;  ↓

feature branch

&#x20;  ↓

Database / business rules

&#x20;  ↓

Implementation

&#x20;  ↓

Tests

&#x20;  ↓

Pint / Analyze

&#x20;  ↓

OpenAPI check

&#x20;  ↓

Commit

&#x20;  ↓

Push

&#x20;  ↓

Draft Pull Request

&#x20;  ↓

CI

&#x20;  ↓

Ready

&#x20;  ↓

Merge into develop

```



\---



\# 32. Current Development Order



بعد تثبيت هذا الهيكل، الترتيب المعتمد هو:



```text

1\. Business Update + Authorization

2\. Business Locations

3\. Business Contacts

4\. Business Capabilities

5\. Business Hours

6\. Verification

7\. Follow System

8\. Product Backend Foundation

9\. Product API

10\. Product Images

11\. Product Visibility

12\. Orders Foundation

13\. Order API

14\. Supplier Selection

15\. Order Status Workflow

16\. Sync Infrastructure

17\. OpenAPI Finalization

18\. Generated Dart-Dio Client

19\. Flutter Auth Integration

20\. Flutter Business Integration

21\. Flutter Products Integration

22\. Flutter Orders Integration

23\. Conflict Resolution

24\. Security Hardening

25\. Full Tests

26\. Production Preparation

```



\---



\# 33. Important Rules



1\. لا يتم تغيير هيكل Feature دون سبب معماري واضح.



2\. لا يتم إنشاء Placeholder files.



3\. لا يتم إنشاء Models أو Migrations قبل وقتها.



4\. Controller لا يحتوي Business Logic معقد.



5\. API validation داخل Request.



6\. Business Logic داخل Services.



7\. Flutter UI لا يتصل مباشرة بـDio أو Drift.



8\. Flutter Domain لا يعتمد على Flutter UI أو Dio.



9\. Drift يظل المصدر المحلي الأساسي.



10\. OpenAPI هو العقد بين Laravel وFlutter.



11\. Generated API Client لا يعدل يدويًا.



12\. كل Feature يجب أن تحتوي اختبارات قبل الدمج في `develop`.



\---



\# 34. Structure Builder



الهيكل الناقص يمكن إنشاؤه في أي جهاز بواسطة:



```powershell

.\\tool\\create\_project\_structure.ps1

```



السكربت:



\* ينشئ المجلدات الناقصة فقط.

\* لا يستبدل الملفات الموجودة.

\* لا ينشئ Placeholder files.

\* لا ينشئ Models.

\* لا ينشئ Migrations.

\* يمكن تشغيله أكثر من مرة بأمان.



