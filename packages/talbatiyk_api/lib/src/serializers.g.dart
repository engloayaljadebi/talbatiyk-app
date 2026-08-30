// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(AuthLogout200Response.serializer)
      ..add(AuthLogout200ResponseMessageEnum.serializer)
      ..add(AuthMe200Response.serializer)
      ..add(AuthRegister201Response.serializer)
      ..add(AuthRegister201ResponseData.serializer)
      ..add(AuthRegister201ResponseDataTokenTypeEnum.serializer)
      ..add(AvailabilityStatus.serializer)
      ..add(BusinessContactIndexBusiness200Response.serializer)
      ..add(BusinessContactResource.serializer)
      ..add(BusinessContactStoreBusiness201Response.serializer)
      ..add(BusinessIndex200Response.serializer)
      ..add(BusinessLocationIndex200Response.serializer)
      ..add(BusinessLocationResource.serializer)
      ..add(BusinessLocationResourceAddress.serializer)
      ..add(BusinessLocationResourceCoordinates.serializer)
      ..add(BusinessLocationStore201Response.serializer)
      ..add(BusinessResource.serializer)
      ..add(BusinessResourceMembership.serializer)
      ..add(BusinessStore201Response.serializer)
      ..add(CreateBusinessContactRequest.serializer)
      ..add(CreateBusinessContactRequestTypeEnum.serializer)
      ..add(CreateBusinessLocationRequest.serializer)
      ..add(CreateBusinessLocationRequestStatusEnum.serializer)
      ..add(CreateBusinessLocationRequestTypeEnum.serializer)
      ..add(CreateBusinessRequest.serializer)
      ..add(CreateBusinessRequestContact.serializer)
      ..add(CreateBusinessRequestContactTypeEnum.serializer)
      ..add(CreateBusinessRequestLocation.serializer)
      ..add(CreateBusinessRequestLocationTypeEnum.serializer)
      ..add(CreateOrderRequest.serializer)
      ..add(CreateOrderRequestItemsInner.serializer)
      ..add(FulfillmentStatus.serializer)
      ..add(InlineObject.serializer)
      ..add(InlineObject1.serializer)
      ..add(LoginRequest.serializer)
      ..add(OrderAggregateStatus.serializer)
      ..add(OrderItemResource.serializer)
      ..add(OrderRecipientItemResource.serializer)
      ..add(OrderRecipientItemResponseResource.serializer)
      ..add(OrderRecipientResource.serializer)
      ..add(OrderRecipientResponseResource.serializer)
      ..add(OrderResource.serializer)
      ..add(OrderResponseComparisonItemResource.serializer)
      ..add(OrderResponseComparisonItemResourceSupplier.serializer)
      ..add(OrderResponseComparisonResource.serializer)
      ..add(OrderResponseComparisonSelectionResource.serializer)
      ..add(OrderResponseComparisonShow200Response.serializer)
      ..add(OrderStore201Response.serializer)
      ..add(ProductIndex200Response.serializer)
      ..add(ProductIndex200ResponseLinks.serializer)
      ..add(ProductIndex200ResponseMeta.serializer)
      ..add(ProductIndex200ResponseMetaLinksInner.serializer)
      ..add(ProductResource.serializer)
      ..add(RegisterRequest.serializer)
      ..add(RegisterRequestContactTypeEnum.serializer)
      ..add(RegisterRequestContactValue.serializer)
      ..add(SelectOrderSupplierResponsesRequest.serializer)
      ..add(SelectOrderSupplierResponsesRequestSelectionsInner.serializer)
      ..add(SubmitSupplierOrderResponseRequest.serializer)
      ..add(SubmitSupplierOrderResponseRequestItemsInner.serializer)
      ..add(SupplierFollowShow200Response.serializer)
      ..add(SupplierFollowShow200ResponseData.serializer)
      ..add(SupplierFollowStore422Response.serializer)
      ..add(SupplierFollowStore422ResponseErrors.serializer)
      ..add(SupplierOrderFulfillmentUpdate200Response.serializer)
      ..add(SupplierOrderIndex200Response.serializer)
      ..add(SupplierOrderResponseStore201Response.serializer)
      ..add(UpdateBusinessContactRequest.serializer)
      ..add(UpdateBusinessLocationRequest.serializer)
      ..add(UpdateBusinessLocationRequestStatusEnum.serializer)
      ..add(UpdateBusinessLocationRequestTypeEnum.serializer)
      ..add(UpdateBusinessRequest.serializer)
      ..add(UpdateSupplierFulfillmentRequest.serializer)
      ..add(UpdateSupplierFulfillmentRequestStatusEnum.serializer)
      ..add(UserResource.serializer)
      ..add(UserResourceContactsInner.serializer)
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(BusinessContactResource)]),
          () => ListBuilder<BusinessContactResource>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(BusinessLocationResource)]),
          () => ListBuilder<BusinessLocationResource>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(BusinessResource)]),
          () => ListBuilder<BusinessResource>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CreateOrderRequestItemsInner)]),
          () => ListBuilder<CreateOrderRequestItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(OrderItemResource)]),
          () => ListBuilder<OrderItemResource>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(OrderRecipientItemResource)]),
          () => ListBuilder<OrderRecipientItemResource>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(OrderRecipientItemResponseResource)]),
          () => ListBuilder<OrderRecipientItemResponseResource>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(OrderRecipientResource)]),
          () => ListBuilder<OrderRecipientResource>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(OrderResponseComparisonItemResource)]),
          () => ListBuilder<OrderResponseComparisonItemResource>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(ProductIndex200ResponseMetaLinksInner)]),
          () => ListBuilder<ProductIndex200ResponseMetaLinksInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ProductResource)]),
          () => ListBuilder<ProductResource>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(SelectOrderSupplierResponsesRequestSelectionsInner)
          ]),
          () =>
              ListBuilder<SelectOrderSupplierResponsesRequestSelectionsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(SubmitSupplierOrderResponseRequestItemsInner)
          ]),
          () => ListBuilder<SubmitSupplierOrderResponseRequestItemsInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(UserResourceContactsInner)]),
          () => ListBuilder<UserResourceContactsInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType.nullable(JsonObject)]),
          () => ListBuilder<JsonObject?>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType.nullable(JsonObject)]),
          () => ListBuilder<JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType(BuiltList, const [const FullType(String)])
          ]),
          () => MapBuilder<String, BuiltList<String>>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
