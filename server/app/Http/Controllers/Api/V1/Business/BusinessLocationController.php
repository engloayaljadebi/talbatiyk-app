<?php

/*
|--------------------------------------------------------------------------
| Controller مواقع النشاط - BusinessLocationController
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - عرض مواقع النشاط.
| - عرض موقع واحد.
| - إنشاء موقع جديد.
| - تعديل موقع.
| - حذف موقع.
| - تعيين الموقع الرئيسي.
|
| مبدأ التصميم:
| - Controller يبقى خفيفًا.
| - Validation داخل Form Requests.
| - القراءة داخل BusinessLocationQueryService.
| - الكتابة داخل BusinessLocationService.
| - الصلاحيات داخل BusinessAccessService.
|
| Endpoints:
| GET    /businesses/{business}/locations
| GET    /businesses/{business}/locations/{location}
| POST   /businesses/{business}/locations
| PATCH  /businesses/{business}/locations/{location}
| DELETE /businesses/{business}/locations/{location}
| POST   /businesses/{business}/locations/{location}/primary
|
*/

namespace App\Http\Controllers\Api\V1\Business;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Business\CreateBusinessLocationRequest;
use App\Http\Requests\Api\V1\Business\UpdateBusinessLocationRequest;
use App\Http\Resources\Api\V1\BusinessLocationResource;
use App\Services\Business\BusinessLocationQueryService;
use App\Services\Business\BusinessLocationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class BusinessLocationController extends Controller
{
    public function __construct(
        private readonly BusinessLocationQueryService $businessLocationQueryService,
        private readonly BusinessLocationService $businessLocationService,
    ) {}

    /**
     * عرض جميع مواقع النشاط.
     *
     * أي عضو active يستطيع القراءة.
     */
    public function index(
        Request $request,
        string $business,
    ): AnonymousResourceCollection {
        $locations = $this->businessLocationQueryService->forUser(
            $request->user(),
            $business,
        );

        return BusinessLocationResource::collection(
            $locations,
        );
    }

    /**
     * عرض موقع واحد تابع للنشاط.
     */
    public function show(
        Request $request,
        string $business,
        string $location,
    ): BusinessLocationResource {
        $locationModel = $this->businessLocationQueryService->findForUser(
            $request->user(),
            $business,
            $location,
        );

        return new BusinessLocationResource(
            $locationModel,
        );
    }

    /**
     * إنشاء موقع جديد.
     *
     * owner أو manager فقط.
     */
    public function store(
        CreateBusinessLocationRequest $request,
        string $business,
    ): JsonResponse {
        $location = $this->businessLocationService->create(
            $request->user(),
            $business,
            $request->validated(),
        );

        return (new BusinessLocationResource($location))
            ->response()
            ->setStatusCode(201);
    }

    /**
     * تعديل موقع موجود.
     *
     * owner أو manager فقط.
     */
    public function update(
        UpdateBusinessLocationRequest $request,
        string $business,
        string $location,
    ): BusinessLocationResource {
        $locationModel = $this->businessLocationService->update(
            $request->user(),
            $business,
            $location,
            $request->validated(),
        );

        return new BusinessLocationResource(
            $locationModel,
        );
    }

    /**
     * حذف موقع حذفًا منطقيًا.
     *
     * الموقع الرئيسي لا يمكن حذفه
     * قبل تعيين موقع رئيسي آخر.
     */
    public function destroy(
        Request $request,
        string $business,
        string $location,
    ): Response {
        $this->businessLocationService->delete(
            $request->user(),
            $business,
            $location,
        );

        return response()->noContent();
    }

    /**
     * تعيين موقع باعتباره الموقع الرئيسي.
     */
    public function setPrimary(
        Request $request,
        string $business,
        string $location,
    ): BusinessLocationResource {
        $locationModel = $this->businessLocationService->setPrimary(
            $request->user(),
            $business,
            $location,
        );

        return new BusinessLocationResource(
            $locationModel,
        );
    }
}
