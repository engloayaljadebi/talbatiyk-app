// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AvailabilityStatus _$full = const AvailabilityStatus._('full');
const AvailabilityStatus _$partial = const AvailabilityStatus._('partial');
const AvailabilityStatus _$unavailable =
    const AvailabilityStatus._('unavailable');

AvailabilityStatus _$valueOf(String name) {
  switch (name) {
    case 'full':
      return _$full;
    case 'partial':
      return _$partial;
    case 'unavailable':
      return _$unavailable;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AvailabilityStatus> _$values =
    BuiltSet<AvailabilityStatus>(const <AvailabilityStatus>[
  _$full,
  _$partial,
  _$unavailable,
]);

class _$AvailabilityStatusMeta {
  const _$AvailabilityStatusMeta();
  AvailabilityStatus get full => _$full;
  AvailabilityStatus get partial => _$partial;
  AvailabilityStatus get unavailable => _$unavailable;
  AvailabilityStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<AvailabilityStatus> get values => _$values;
}

abstract class _$AvailabilityStatusMixin {
  // ignore: non_constant_identifier_names
  _$AvailabilityStatusMeta get AvailabilityStatus =>
      const _$AvailabilityStatusMeta();
}

Serializer<AvailabilityStatus> _$availabilityStatusSerializer =
    _$AvailabilityStatusSerializer();

class _$AvailabilityStatusSerializer
    implements PrimitiveSerializer<AvailabilityStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'full': 'full',
    'partial': 'partial',
    'unavailable': 'unavailable',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'full': 'full',
    'partial': 'partial',
    'unavailable': 'unavailable',
  };

  @override
  final Iterable<Type> types = const <Type>[AvailabilityStatus];
  @override
  final String wireName = 'AvailabilityStatus';

  @override
  Object serialize(Serializers serializers, AvailabilityStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AvailabilityStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AvailabilityStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
