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
import 'package:talbatiyk_api/src/model/inline_object.dart';
import 'package:talbatiyk_api/src/model/inline_object1.dart';
import 'package:talbatiyk_api/src/model/login_request.dart';
import 'package:talbatiyk_api/src/model/register_request.dart';
import 'package:talbatiyk_api/src/model/register_request_contact_value.dart';
import 'package:talbatiyk_api/src/model/update_business_contact_request.dart';
import 'package:talbatiyk_api/src/model/update_business_location_request.dart';
import 'package:talbatiyk_api/src/model/update_business_request.dart';
import 'package:talbatiyk_api/src/model/user_resource.dart';
import 'package:talbatiyk_api/src/model/user_resource_contacts_inner.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthLogout200Response,
  AuthMe200Response,
  AuthRegister201Response,
  AuthRegister201ResponseData,
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
  InlineObject,
  InlineObject1,
  LoginRequest,
  RegisterRequest,
  RegisterRequestContactValue,
  UpdateBusinessContactRequest,
  UpdateBusinessLocationRequest,
  UpdateBusinessRequest,
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
