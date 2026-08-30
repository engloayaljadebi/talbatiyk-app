// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_supplier_fulfillment_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateSupplierFulfillmentRequestStatusEnum
    _$updateSupplierFulfillmentRequestStatusEnum_preparing =
    const UpdateSupplierFulfillmentRequestStatusEnum._('preparing');
const UpdateSupplierFulfillmentRequestStatusEnum
    _$updateSupplierFulfillmentRequestStatusEnum_readyForDelivery =
    const UpdateSupplierFulfillmentRequestStatusEnum._('readyForDelivery');
const UpdateSupplierFulfillmentRequestStatusEnum
    _$updateSupplierFulfillmentRequestStatusEnum_outForDelivery =
    const UpdateSupplierFulfillmentRequestStatusEnum._('outForDelivery');
const UpdateSupplierFulfillmentRequestStatusEnum
    _$updateSupplierFulfillmentRequestStatusEnum_delivered =
    const UpdateSupplierFulfillmentRequestStatusEnum._('delivered');

UpdateSupplierFulfillmentRequestStatusEnum
    _$updateSupplierFulfillmentRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'preparing':
      return _$updateSupplierFulfillmentRequestStatusEnum_preparing;
    case 'readyForDelivery':
      return _$updateSupplierFulfillmentRequestStatusEnum_readyForDelivery;
    case 'outForDelivery':
      return _$updateSupplierFulfillmentRequestStatusEnum_outForDelivery;
    case 'delivered':
      return _$updateSupplierFulfillmentRequestStatusEnum_delivered;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdateSupplierFulfillmentRequestStatusEnum>
    _$updateSupplierFulfillmentRequestStatusEnumValues = BuiltSet<
        UpdateSupplierFulfillmentRequestStatusEnum>(const <UpdateSupplierFulfillmentRequestStatusEnum>[
  _$updateSupplierFulfillmentRequestStatusEnum_preparing,
  _$updateSupplierFulfillmentRequestStatusEnum_readyForDelivery,
  _$updateSupplierFulfillmentRequestStatusEnum_outForDelivery,
  _$updateSupplierFulfillmentRequestStatusEnum_delivered,
]);

Serializer<UpdateSupplierFulfillmentRequestStatusEnum>
    _$updateSupplierFulfillmentRequestStatusEnumSerializer =
    _$UpdateSupplierFulfillmentRequestStatusEnumSerializer();

class _$UpdateSupplierFulfillmentRequestStatusEnumSerializer
    implements PrimitiveSerializer<UpdateSupplierFulfillmentRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'preparing': 'preparing',
    'readyForDelivery': 'ready_for_delivery',
    'outForDelivery': 'out_for_delivery',
    'delivered': 'delivered',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'preparing': 'preparing',
    'ready_for_delivery': 'readyForDelivery',
    'out_for_delivery': 'outForDelivery',
    'delivered': 'delivered',
  };

  @override
  final Iterable<Type> types = const <Type>[
    UpdateSupplierFulfillmentRequestStatusEnum
  ];
  @override
  final String wireName = 'UpdateSupplierFulfillmentRequestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          UpdateSupplierFulfillmentRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdateSupplierFulfillmentRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdateSupplierFulfillmentRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdateSupplierFulfillmentRequest
    extends UpdateSupplierFulfillmentRequest {
  @override
  final int expectedVersion;
  @override
  final UpdateSupplierFulfillmentRequestStatusEnum status;

  factory _$UpdateSupplierFulfillmentRequest(
          [void Function(UpdateSupplierFulfillmentRequestBuilder)? updates]) =>
      (UpdateSupplierFulfillmentRequestBuilder()..update(updates))._build();

  _$UpdateSupplierFulfillmentRequest._(
      {required this.expectedVersion, required this.status})
      : super._();
  @override
  UpdateSupplierFulfillmentRequest rebuild(
          void Function(UpdateSupplierFulfillmentRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateSupplierFulfillmentRequestBuilder toBuilder() =>
      UpdateSupplierFulfillmentRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateSupplierFulfillmentRequest &&
        expectedVersion == other.expectedVersion &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedVersion.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateSupplierFulfillmentRequest')
          ..add('expectedVersion', expectedVersion)
          ..add('status', status))
        .toString();
  }
}

class UpdateSupplierFulfillmentRequestBuilder
    implements
        Builder<UpdateSupplierFulfillmentRequest,
            UpdateSupplierFulfillmentRequestBuilder> {
  _$UpdateSupplierFulfillmentRequest? _$v;

  int? _expectedVersion;
  int? get expectedVersion => _$this._expectedVersion;
  set expectedVersion(int? expectedVersion) =>
      _$this._expectedVersion = expectedVersion;

  UpdateSupplierFulfillmentRequestStatusEnum? _status;
  UpdateSupplierFulfillmentRequestStatusEnum? get status => _$this._status;
  set status(UpdateSupplierFulfillmentRequestStatusEnum? status) =>
      _$this._status = status;

  UpdateSupplierFulfillmentRequestBuilder() {
    UpdateSupplierFulfillmentRequest._defaults(this);
  }

  UpdateSupplierFulfillmentRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedVersion = $v.expectedVersion;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateSupplierFulfillmentRequest other) {
    _$v = other as _$UpdateSupplierFulfillmentRequest;
  }

  @override
  void update(void Function(UpdateSupplierFulfillmentRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateSupplierFulfillmentRequest build() => _build();

  _$UpdateSupplierFulfillmentRequest _build() {
    final _$result = _$v ??
        _$UpdateSupplierFulfillmentRequest._(
          expectedVersion: BuiltValueNullFieldError.checkNotNull(
              expectedVersion,
              r'UpdateSupplierFulfillmentRequest',
              'expectedVersion'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'UpdateSupplierFulfillmentRequest', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
