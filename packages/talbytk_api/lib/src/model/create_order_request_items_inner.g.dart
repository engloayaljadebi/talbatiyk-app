// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateOrderRequestItemsInnerItemTypeEnum
    _$createOrderRequestItemsInnerItemTypeEnum_catalog =
    const CreateOrderRequestItemsInnerItemTypeEnum._('catalog');
const CreateOrderRequestItemsInnerItemTypeEnum
    _$createOrderRequestItemsInnerItemTypeEnum_manual =
    const CreateOrderRequestItemsInnerItemTypeEnum._('manual');

CreateOrderRequestItemsInnerItemTypeEnum
    _$createOrderRequestItemsInnerItemTypeEnumValueOf(String name) {
  switch (name) {
    case 'catalog':
      return _$createOrderRequestItemsInnerItemTypeEnum_catalog;
    case 'manual':
      return _$createOrderRequestItemsInnerItemTypeEnum_manual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateOrderRequestItemsInnerItemTypeEnum>
    _$createOrderRequestItemsInnerItemTypeEnumValues = BuiltSet<
        CreateOrderRequestItemsInnerItemTypeEnum>(const <CreateOrderRequestItemsInnerItemTypeEnum>[
  _$createOrderRequestItemsInnerItemTypeEnum_catalog,
  _$createOrderRequestItemsInnerItemTypeEnum_manual,
]);

Serializer<CreateOrderRequestItemsInnerItemTypeEnum>
    _$createOrderRequestItemsInnerItemTypeEnumSerializer =
    _$CreateOrderRequestItemsInnerItemTypeEnumSerializer();

class _$CreateOrderRequestItemsInnerItemTypeEnumSerializer
    implements PrimitiveSerializer<CreateOrderRequestItemsInnerItemTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'catalog': 'catalog',
    'manual': 'manual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'catalog': 'catalog',
    'manual': 'manual',
  };

  @override
  final Iterable<Type> types = const <Type>[
    CreateOrderRequestItemsInnerItemTypeEnum
  ];
  @override
  final String wireName = 'CreateOrderRequestItemsInnerItemTypeEnum';

  @override
  Object serialize(Serializers serializers,
          CreateOrderRequestItemsInnerItemTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateOrderRequestItemsInnerItemTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateOrderRequestItemsInnerItemTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateOrderRequestItemsInner extends CreateOrderRequestItemsInner {
  @override
  final CreateOrderRequestItemsInnerItemTypeEnum? itemType;
  @override
  final String? productId;
  @override
  final int quantity;
  @override
  final num? expectedUnitPrice;
  @override
  final String? expectedSupplierId;
  @override
  final String? name;
  @override
  final num? unitPrice;
  @override
  final String? unit;
  @override
  final String? note;

  factory _$CreateOrderRequestItemsInner(
          [void Function(CreateOrderRequestItemsInnerBuilder)? updates]) =>
      (CreateOrderRequestItemsInnerBuilder()..update(updates))._build();

  _$CreateOrderRequestItemsInner._(
      {this.itemType,
      this.productId,
      required this.quantity,
      this.expectedUnitPrice,
      this.expectedSupplierId,
      this.name,
      this.unitPrice,
      this.unit,
      this.note})
      : super._();
  @override
  CreateOrderRequestItemsInner rebuild(
          void Function(CreateOrderRequestItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateOrderRequestItemsInnerBuilder toBuilder() =>
      CreateOrderRequestItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateOrderRequestItemsInner &&
        itemType == other.itemType &&
        productId == other.productId &&
        quantity == other.quantity &&
        expectedUnitPrice == other.expectedUnitPrice &&
        expectedSupplierId == other.expectedSupplierId &&
        name == other.name &&
        unitPrice == other.unitPrice &&
        unit == other.unit &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemType.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, expectedUnitPrice.hashCode);
    _$hash = $jc(_$hash, expectedSupplierId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateOrderRequestItemsInner')
          ..add('itemType', itemType)
          ..add('productId', productId)
          ..add('quantity', quantity)
          ..add('expectedUnitPrice', expectedUnitPrice)
          ..add('expectedSupplierId', expectedSupplierId)
          ..add('name', name)
          ..add('unitPrice', unitPrice)
          ..add('unit', unit)
          ..add('note', note))
        .toString();
  }
}

class CreateOrderRequestItemsInnerBuilder
    implements
        Builder<CreateOrderRequestItemsInner,
            CreateOrderRequestItemsInnerBuilder> {
  _$CreateOrderRequestItemsInner? _$v;

  CreateOrderRequestItemsInnerItemTypeEnum? _itemType;
  CreateOrderRequestItemsInnerItemTypeEnum? get itemType => _$this._itemType;
  set itemType(CreateOrderRequestItemsInnerItemTypeEnum? itemType) =>
      _$this._itemType = itemType;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  num? _expectedUnitPrice;
  num? get expectedUnitPrice => _$this._expectedUnitPrice;
  set expectedUnitPrice(num? expectedUnitPrice) =>
      _$this._expectedUnitPrice = expectedUnitPrice;

  String? _expectedSupplierId;
  String? get expectedSupplierId => _$this._expectedSupplierId;
  set expectedSupplierId(String? expectedSupplierId) =>
      _$this._expectedSupplierId = expectedSupplierId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _unitPrice;
  num? get unitPrice => _$this._unitPrice;
  set unitPrice(num? unitPrice) => _$this._unitPrice = unitPrice;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CreateOrderRequestItemsInnerBuilder() {
    CreateOrderRequestItemsInner._defaults(this);
  }

  CreateOrderRequestItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemType = $v.itemType;
      _productId = $v.productId;
      _quantity = $v.quantity;
      _expectedUnitPrice = $v.expectedUnitPrice;
      _expectedSupplierId = $v.expectedSupplierId;
      _name = $v.name;
      _unitPrice = $v.unitPrice;
      _unit = $v.unit;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateOrderRequestItemsInner other) {
    _$v = other as _$CreateOrderRequestItemsInner;
  }

  @override
  void update(void Function(CreateOrderRequestItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateOrderRequestItemsInner build() => _build();

  _$CreateOrderRequestItemsInner _build() {
    final _$result = _$v ??
        _$CreateOrderRequestItemsInner._(
          itemType: itemType,
          productId: productId,
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'CreateOrderRequestItemsInner', 'quantity'),
          expectedUnitPrice: expectedUnitPrice,
          expectedSupplierId: expectedSupplierId,
          name: name,
          unitPrice: unitPrice,
          unit: unit,
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
