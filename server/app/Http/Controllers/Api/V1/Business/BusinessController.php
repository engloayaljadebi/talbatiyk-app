<?php

/*
|--------------------------------------------------------------------------
| Business API Controller
|--------------------------------------------------------------------------
|
| Endpoints:
| POST /api/v1/businesses
|
| المسؤوليات:
| - استقبال طلب إنشاء النشاط بعد التحقق من البيانات.
| - تمرير المستخدم والبيانات إلى BusinessOnboardingService.
| - إعادة BusinessResource بحالة HTTP 201.
|
| ملاحظة:
| منطق إنشاء النشاط لا يوضع داخل Controller.
| جميع عمليات قاعدة البيانات موجودة في BusinessOnboardingService.
|
*/

namespace App\Http\Controllers\Api\V1\Business;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Business\CreateBusinessRequest;
use App\Http\Resources\Api\V1\BusinessResource;
use App\Services\Business\BusinessOnboardingService;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class BusinessController extends Controller
{
    public function __construct(
        private readonly BusinessOnboardingService $businessOnboardingService,
    ) {}

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
}
