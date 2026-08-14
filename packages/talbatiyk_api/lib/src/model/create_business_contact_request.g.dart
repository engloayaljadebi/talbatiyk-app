// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_business_contact_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateBusinessContactRequestTypeEnum
    _$createBusinessContactRequestTypeEnum_phone =
    const CreateBusinessContactRequestTypeEnum._('phone');
const CreateBusinessContactRequestTypeEnum
    _$createBusinessContactRequestTypeEnum_whatsapp =
    const CreateBusinessContactRequestTypeEnum._('whatsapp');
const CreateBusinessContactRequestTypeEnum
    _$createBusinessContactRequestTypeEnum_email =
    const CreateBusinessContactRequestTypeEnum._('email');
const CreateBusinessContactRequestTypeEnum
    _$createBusinessContactRequestTypeEnum_website =
    const CreateBusinessContactRequestTypeEnum._('website');

CreateBusinessContactRequestTypeEnum
    _$createBusinessContactRequestTypeEnumValueOf(String name) {
  switch (name) {
    case 'phone':
      return _$createBusinessContactRequestTypeEnum_phone;
    case 'whatsapp':
      return _$createBusinessContactRequestTypeEnum_whatsapp;
    case 'email':
      return _$createBusinessContactRequestTypeEnum_email;
    case 'website':
      return _$createBusinessContactRequestTypeEnum_website;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateBusinessContactRequestTypeEnum>
    _$createBusinessContactRequestTypeEnumValues = BuiltSet<
        CreateBusinessContactRequestTypeEnum>(const <CreateBusinessContactRequestTypeEnum>[
  _$createBusinessContactRequestTypeEnum_phone,
  _$createBusinessContactRequestTypeEnum_whatsapp,
  _$createBusinessContactRequestTypeEnum_email,
  _$createBusinessContactRequestTypeEnum_website,
]);

Serializer<CreateBusinessContactRequestTypeEnum>
    _$createBusinessContactRequestTypeEnumSerializer =
    _$CreateBusinessContactRequestTypeEnumSerializer();

class _$CreateBusinessContactRequestTypeEnumSerializer
    implements PrimitiveSerializer<CreateBusinessContactRequestTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'phone': 'phone',
    'whatsapp': 'whatsapp',
    'email': 'email',
    'website': 'website',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'phone': 'phone',
    'whatsapp': 'whatsapp',
    'email': 'email',
    'website': 'website',
  };

  @override
  final Iterable<Type> types = const <Type>[
    CreateBusinessContactRequestTypeEnum
  ];
  @override
  final String wireName = 'CreateBusinessContactRequestTypeEnum';

  @override
  Object serialize(
          Serializers serializers, CreateBusinessContactRequestTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateBusinessContactRequestTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateBusinessContactRequestTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateBusinessContactRequest extends CreateBusinessContactRequest {
  @override
  final CreateBusinessContactRequestTypeEnum type;
  @override
  final String value;
  @override
  final String? label;

  factory _$CreateBusinessContactRequest(
          [void Function(CreateBusinessContactRequestBuilder)? updates]) =>
      (CreateBusinessContactRequestBuilder()..update(updates))._build();

  _$CreateBusinessContactRequest._(
      {required this.type, required this.value, this.label})
      : super._();
  @override
  CreateBusinessContactRequest rebuild(
          void Function(CreateBusinessContactRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateBusinessContactRequestBuilder toBuilder() =>
      CreateBusinessContactRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateBusinessContactRequest &&
        type == other.type &&
        value == other.value &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateBusinessContactRequest')
          ..add('type', type)
          ..add('value', value)
          ..add('label', label))
        .toString();
  }
}

class CreateBusinessContactRequestBuilder
    implements
        Builder<CreateBusinessContactRequest,
            CreateBusinessContactRequestBuilder> {
  _$CreateBusinessContactRequest? _$v;

  CreateBusinessContactRequestTypeEnum? _type;
  CreateBusinessContactRequestTypeEnum? get type => _$this._type;
  set type(CreateBusinessContactRequestTypeEnum? type) => _$this._type = type;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  CreateBusinessContactRequestBuilder() {
    CreateBusinessContactRequest._defaults(this);
  }

  CreateBusinessContactRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _value = $v.value;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateBusinessContactRequest other) {
    _$v = other as _$CreateBusinessContactRequest;
  }

  @override
  void update(void Function(CreateBusinessContactRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateBusinessContactRequest build() => _build();

  _$CreateBusinessContactRequest _build() {
    final _$result = _$v ??
        _$CreateBusinessContactRequest._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'CreateBusinessContactRequest', 'type'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'CreateBusinessContactRequest', 'value'),
          label: label,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
