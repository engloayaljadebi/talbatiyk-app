<?php

/*
|--------------------------------------------------------------------------
| Business API Controller
|--------------------------------------------------------------------------
|
| Endpoints:
| GET  /api/v1/businesses
| GET  /api/v1/businesses/{business}
| POST /api/v1/businesses
|
| المسؤوليات:
| - قراءة الأنشطة التي يملك المستخدم عضوية نشطة فيها.
| - قراءة نشاط واحد للمستخدم الحالي.
| - استقبال طلب إنشاء نشاط جديد.
| - إبقاء منطق الأعمال وقواعد الوصول داخل الخدمات.
|
| الخدمات:
| - BusinessQueryService:
|   مسؤول عن قراءة الأنشطة وتطبيق نطاق العضوية النشطة.
|
| - BusinessOnboardingService:
|   مسؤول عن إنشاء النشاط وجميع البيانات المرتبطة به ذريًا.
|
*/

namespace App\Http\Controllers\Api\V1\Business;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Business\CreateBusinessRequest;
use App\Http\Requests\Api\V1\Business\UpdateBusinessRequest;
use App\Http\Resources\Api\V1\BusinessResource;
use App\Services\Business\BusinessOnboardingService;
use App\Services\Business\BusinessQueryService;
use App\Services\Business\BusinessUpdateService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Symfony\Component\HttpFoundation\Response;

class BusinessController extends Controller
{
    public function __construct(
        private readonly BusinessOnboardingService $businessOnboardingService,
        private readonly BusinessQueryService $businessQueryService,
        private readonly BusinessUpdateService $businessUpdateService,
    ) {}

    /**
     * إرجاع جميع الأنشطة التي لدى المستخدم
     * الحالي عضوية نشطة فيها.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $businesses = $this->businessQueryService->forUser(
            $request->user(),
        );

        return BusinessResource::collection($businesses);
    }

    /**
     * قراءة نشاط واحد بشرط أن تكون للمستخدم
     * الحالي عضوية نشطة فيه.
     *
     * عند عدم وجود النشاط أو عدم امتلاك العضوية
     * سيعيد BusinessQueryService استجابة 404.
     */
    public function show(
        Request $request,
        string $business,
    ): BusinessResource {
        $businessModel = $this->businessQueryService->findForUser(
            $request->user(),
            $business,
        );

        return new BusinessResource($businessModel);
    }

    /**
     * إنشاء نشاط تجاري جديد للمستخدم الحالي.
     */
    public function store(CreateBusinessRequest $request): JsonResponse
    {
        $business = $this->businessOnboardingService->create(
            $request->user(),
            $request->validated(),
        );

        return (new BusinessResource($business))
            ->response()
            ->setStatusCode(Response::HTTP_CREATED);
    }

    /**
     * تعديل البيانات الأساسية لنشاط تجاري.
     *
     * يسمح بالتعديل فقط للمستخدم الذي:
     * - لديه عضوية active.
     * - يحمل دور owner أو manager.
     *
     * BusinessAccessService يتولى التحقق من الصلاحيات.
     */
    public function update(
        UpdateBusinessRequest $request,
        string $business,
    ): BusinessResource {
        $businessModel = $this->businessUpdateService->update(
            $request->user(),
            $business,
            $request->validated(),
        );

        return new BusinessResource($businessModel);
    }
}
