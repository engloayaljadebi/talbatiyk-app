//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:talbatiyk_api/src/date_serializer.dart';
import 'package:talbatiyk_api/src/model/date.dart';

import 'package:talbatiyk_api/src/model/auth_logout200_response.dart';
import 'package:talbatiyk_api/src/model/auth_me200_response.dart';
import 'package:talbatiyk_api/src/model/auth_register201_response.dart';
import 'package:talbatiyk_api/src/model/auth_register201_response_data.dart';
import 'package:talbatiyk_api/src/model/availability_status.dart';
import 'package:talbatiyk_api/src/model/business_contact_index_business200_response.dart';
import 'package:talbatiyk_api/src/model/business_contact_resource.dart';
import 'package:talbatiyk_api/src/model/business_contact_store_business201_response.dart';
import 'package:talbatiyk_api/src/model/business_index200_response.dart';
import 'package:talbatiyk_api/src/model/business_location_index200_response.dart';
import 'package:talbatiyk_api/src/model/business_location_resource.dart';
import 'package:talbatiyk_api/src/model/business_location_resource_address.dart';
import 'package:talbatiyk_api/src/model/business_location_resource_coordinates.dart';
import 'package:talbatiyk_api/src/model/business_location_store201_response.dart';
import 'package:talbatiyk_api/src/model/business_resource.dart';
import 'package:talbatiyk_api/src/model/business_resource_membership.dart';
import 'package:talbatiyk_api/src/model/business_store201_response.dart';
import 'package:talbatiyk_api/src/model/create_business_contact_request.dart';
import 'package:talbatiyk_api/src/model/create_business_location_request.dart';
import 'package:talbatiyk_api/src/model/create_business_request.dart';
import 'package:talbatiyk_api/src/model/create_business_request_contact.dart';
import 'package:talbatiyk_api/src/model/create_business_request_location.dart';
import 'package:talbatiyk_api/src/model/create_order_request.dart';
import 'package:talbatiyk_api/src/model/create_order_request_items_inner.dart';
import 'package:talbatiyk_api/src/model/fulfillment_status.dart';
import 'package:talbatiyk_api/src/model/inline_object.dart';
import 'package:talbatiyk_api/src/model/inline_object1.dart';
import 'package:talbatiyk_api/src/model/login_request.dart';
import 'package:talbatiyk_api/src/model/order_aggregate_status.dart';
import 'package:talbatiyk_api/src/model/order_item_resource.dart';
import 'package:talbatiyk_api/src/model/order_recipient_item_resource.dart';
import 'package:talbatiyk_api/src/model/order_recipient_item_response_resource.dart';
import 'package:talbatiyk_api/src/model/order_recipient_resource.dart';
import 'package:talbatiyk_api/src/model/order_recipient_response_resource.dart';
import 'package:talbatiyk_api/src/model/order_resource.dart';
import 'package:talbatiyk_api/src/model/order_response_comparison_item_resource.dart';
import 'package:talbatiyk_api/src/model/order_response_comparison_item_resource_supplier.dart';
import 'package:talbatiyk_api/src/model/order_response_comparison_resource.dart';
import 'package:talbatiyk_api/src/model/order_response_comparison_selection_resource.dart';
import 'package:talbatiyk_api/src/model/order_response_comparison_show200_response.dart';
import 'package:talbatiyk_api/src/model/order_store201_response.dart';
import 'package:talbatiyk_api/src/model/product_index200_response.dart';
import 'package:talbatiyk_api/src/model/product_index200_response_links.dart';
import 'package:talbatiyk_api/src/model/product_index200_response_meta.dart';
import 'package:talbatiyk_api/src/model/product_index200_response_meta_links_inner.dart';
import 'package:talbatiyk_api/src/model/product_resource.dart';
import 'package:talbatiyk_api/src/model/register_request.dart';
import 'package:talbatiyk_api/src/model/register_request_contact_value.dart';
import 'package:talbatiyk_api/src/model/select_order_supplier_responses_request.dart';
import 'package:talbatiyk_api/src/model/select_order_supplier_responses_request_selections_inner.dart';
import 'package:talbatiyk_api/src/model/submit_supplier_order_response_request.dart';
import 'package:talbatiyk_api/src/model/submit_supplier_order_response_request_items_inner.dart';
import 'package:talbatiyk_api/src/model/supplier_follow_show200_response.dart';
import 'package:talbatiyk_api/src/model/supplier_follow_show200_response_data.dart';
import 'package:talbatiyk_api/src/model/supplier_follow_store422_response.dart';
import 'package:talbatiyk_api/src/model/supplier_follow_store422_response_errors.dart';
import 'package:talbatiyk_api/src/model/supplier_order_fulfillment_update200_response.dart';
import 'package:talbatiyk_api/src/model/supplier_order_index200_response.dart';
import 'package:talbatiyk_api/src/model/supplier_order_response_store201_response.dart';
import 'package:talbatiyk_api/src/model/update_business_contact_request.dart';
import 'package:talbatiyk_api/src/model/update_business_location_request.dart';
import 'package:talbatiyk_api/src/model/update_business_request.dart';
import 'package:talbatiyk_api/src/model/update_supplier_fulfillment_request.dart';
import 'package:talbatiyk_api/src/model/user_resource.dart';
import 'package:talbatiyk_api/src/model/user_resource_contacts_inner.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthLogout200Response,
  AuthMe200Response,
  AuthRegister201Response,
  AuthRegister201ResponseData,
  AvailabilityStatus,
  BusinessContactIndexBusiness200Response,
  BusinessContactResource,
  BusinessContactStoreBusiness201Response,
  BusinessIndex200Response,
  BusinessLocationIndex200Response,
  BusinessLocationResource,
  BusinessLocationResourceAddress,
  BusinessLocationResourceCoordinates,
  BusinessLocationStore201Response,
  BusinessResource,
  BusinessResourceMembership,
  BusinessStore201Response,
  CreateBusinessContactRequest,
  CreateBusinessLocationRequest,
  CreateBusinessRequest,
  CreateBusinessRequestContact,
  CreateBusinessRequestLocation,
  CreateOrderRequest,
  CreateOrderRequestItemsInner,
  FulfillmentStatus,
  InlineObject,
  InlineObject1,
  LoginRequest,
  OrderAggregateStatus,
  OrderItemResource,
  OrderRecipientItemResource,
  OrderRecipientItemResponseResource,
  OrderRecipientResource,
  OrderRecipientResponseResource,
  OrderResource,
  OrderResponseComparisonItemResource,
  OrderResponseComparisonItemResourceSupplier,
  OrderResponseComparisonResource,
  OrderResponseComparisonSelectionResource,
  OrderResponseComparisonShow200Response,
  OrderStore201Response,
  ProductIndex200Response,
  ProductIndex200ResponseLinks,
  ProductIndex200ResponseMeta,
  ProductIndex200ResponseMetaLinksInner,
  ProductResource,
  RegisterRequest,
  RegisterRequestContactValue,
  SelectOrderSupplierResponsesRequest,
  SelectOrderSupplierResponsesRequestSelectionsInner,
  SubmitSupplierOrderResponseRequest,
  SubmitSupplierOrderResponseRequestItemsInner,
  SupplierFollowShow200Response,
  SupplierFollowShow200ResponseData,
  SupplierFollowStore422Response,
  SupplierFollowStore422ResponseErrors,
  SupplierOrderFulfillmentUpdate200Response,
  SupplierOrderIndex200Response,
  SupplierOrderResponseStore201Response,
  UpdateBusinessContactRequest,
  UpdateBusinessLocationRequest,
  UpdateBusinessRequest,
  UpdateSupplierFulfillmentRequest,
  UserResource,
  UserResourceContactsInner,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
