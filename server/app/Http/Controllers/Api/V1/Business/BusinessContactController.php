<?php

/*
|--------------------------------------------------------------------------
| Controller وسائل اتصال النشاط - BusinessContactController
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إدارة وسائل الاتصال العامة للنشاط.
| - إدارة وسائل الاتصال الخاصة بفروع النشاط.
| - عرض وإنشاء وتعديل وحذف وسائل الاتصال.
| - تعيين الوسيلة الرئيسية لكل نوع.
|
| الصلاحيات:
| - القراءة: أي عضو active.
| - الكتابة: owner أو manager.
|
| Business Contacts:
| GET    /businesses/{business}/contacts
| GET    /businesses/{business}/contacts/{contact}
| POST   /businesses/{business}/contacts
| PATCH  /businesses/{business}/contacts/{contact}
| DELETE /businesses/{business}/contacts/{contact}
| POST   /businesses/{business}/contacts/{contact}/primary
|
| Location Contacts:
| GET    /businesses/{business}/locations/{location}/contacts
| GET    /businesses/{business}/locations/{location}/contacts/{contact}
| POST   /businesses/{business}/locations/{location}/contacts
| PATCH  /businesses/{business}/locations/{location}/contacts/{contact}
| DELETE /businesses/{business}/locations/{location}/contacts/{contact}
| POST   /businesses/{business}/locations/{location}/contacts/{contact}/primary
|
*/

namespace App\Http\Controllers\Api\V1\Business;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Business\CreateBusinessContactRequest;
use App\Http\Requests\Api\V1\Business\UpdateBusinessContactRequest;
use App\Http\Resources\Api\V1\BusinessContactResource;
use App\Services\Business\BusinessContactQueryService;
use App\Services\Business\BusinessContactService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class BusinessContactController extends Controller
{
    public function __construct(
        private readonly BusinessContactQueryService $businessContactQueryService,
        private readonly BusinessContactService $businessContactService,
    ) {}

    /*
    |--------------------------------------------------------------------------
    | Business Contacts
    |--------------------------------------------------------------------------
    */

    /**
     * عرض وسائل الاتصال العامة للنشاط.
     */
    public function indexBusiness(
        Request $request,
        string $business,
    ): AnonymousResourceCollection {
        $contacts = $this->businessContactQueryService->forBusiness(
            $request->user(),
            $business,
        );

        return BusinessContactResource::collection(
            $contacts,
        );
    }

    /**
     * عرض وسيلة اتصال عامة واحدة.
     */
    public function showBusiness(
        Request $request,
        string $business,
        string $contact,
    ): BusinessContactResource {
        $contactModel = $this->businessContactQueryService->findForBusiness(
            $request->user(),
            $business,
            $contact,
        );

        return new BusinessContactResource(
            $contactModel,
        );
    }

    /**
     * إنشاء وسيلة اتصال عامة.
     */
    public function storeBusiness(
        CreateBusinessContactRequest $request,
        string $business,
    ): JsonResponse {
        $contact = $this->businessContactService->createForBusiness(
            $request->user(),
            $business,
            $request->validated(),
        );

        return (new BusinessContactResource($contact))
            ->response()
            ->setStatusCode(201);
    }

    /**
     * تعديل وسيلة اتصال عامة.
     */
    public function updateBusiness(
        UpdateBusinessContactRequest $request,
        string $business,
        string $contact,
    ): BusinessContactResource {
        $contactModel = $this->businessContactService->updateForBusiness(
            $request->user(),
            $business,
            $contact,
            $request->validated(),
        );

        return new BusinessContactResource(
            $contactModel,
        );
    }

    /**
     * حذف وسيلة اتصال عامة.
     */
    public function destroyBusiness(
        Request $request,
        string $business,
        string $contact,
    ): Response {
        $this->businessContactService->deleteForBusiness(
            $request->user(),
            $business,
            $contact,
        );

        return response()->noContent();
    }

    /**
     * تعيين وسيلة اتصال عامة كوسيلة رئيسية من نوعها.
     */
    public function setPrimaryBusiness(
        Request $request,
        string $business,
        string $contact,
    ): BusinessContactResource {
        $contactModel = $this->businessContactService->setPrimaryForBusiness(
            $request->user(),
            $business,
            $contact,
        );

        return new BusinessContactResource(
            $contactModel,
        );
    }

    /*
    |--------------------------------------------------------------------------
    | Location Contacts
    |--------------------------------------------------------------------------
    */

    /**
     * عرض وسائل الاتصال الخاصة بفرع.
     */
    public function indexLocation(
        Request $request,
        string $business,
        string $location,
    ): AnonymousResourceCollection {
        $contacts = $this->businessContactQueryService->forLocation(
            $request->user(),
            $business,
            $location,
        );

        return BusinessContactResource::collection(
            $contacts,
        );
    }

    /**
     * عرض وسيلة اتصال خاصة بفرع.
     */
    public function showLocation(
        Request $request,
        string $business,
        string $location,
        string $contact,
    ): BusinessContactResource {
        $contactModel = $this->businessContactQueryService->findForLocation(
            $request->user(),
            $business,
            $location,
            $contact,
        );

        return new BusinessContactResource(
            $contactModel,
        );
    }

    /**
     * إنشاء وسيلة اتصال خاصة بفرع.
     */
    public function storeLocation(
        CreateBusinessContactRequest $request,
        string $business,
        string $location,
    ): JsonResponse {
        $contact = $this->businessContactService->createForLocation(
            $request->user(),
            $business,
            $location,
            $request->validated(),
        );

        return (new BusinessContactResource($contact))
            ->response()
            ->setStatusCode(201);
    }

    /**
     * تعديل وسيلة اتصال خاصة بفرع.
     */
    public function updateLocation(
        UpdateBusinessContactRequest $request,
        string $business,
        string $location,
        string $contact,
    ): BusinessContactResource {
        $contactModel = $this->businessContactService->updateForLocation(
            $request->user(),
            $business,
            $location,
            $contact,
            $request->validated(),
        );

        return new BusinessContactResource(
            $contactModel,
        );
    }

    /**
     * حذف وسيلة اتصال خاصة بفرع.
     */
    public function destroyLocation(
        Request $request,
        string $business,
        string $location,
        string $contact,
    ): Response {
        $this->businessContactService->deleteForLocation(
            $request->user(),
            $business,
            $location,
            $contact,
        );

        return response()->noContent();
    }

    /**
     * تعيين وسيلة اتصال فرع كوسيلة رئيسية من نوعها.
     */
    public function setPrimaryLocation(
        Request $request,
        string $business,
        string $location,
        string $contact,
    ): BusinessContactResource {
        $contactModel = $this->businessContactService->setPrimaryForLocation(
            $request->user(),
            $business,
            $location,
            $contact,
        );

        return new BusinessContactResource(
            $contactModel,
        );
    }
}
