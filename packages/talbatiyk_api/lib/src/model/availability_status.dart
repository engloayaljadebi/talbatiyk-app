//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'availability_status.g.dart';

class AvailabilityStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'full')
  static const AvailabilityStatus full = _$full;
  @BuiltValueEnumConst(wireName: r'partial')
  static const AvailabilityStatus partial = _$partial;
  @BuiltValueEnumConst(wireName: r'unavailable')
  static const AvailabilityStatus unavailable = _$unavailable;

  static Serializer<AvailabilityStatus> get serializer => _$availabilityStatusSerializer;

  const AvailabilityStatus._(String name): super(name);

  static BuiltSet<AvailabilityStatus> get values => _$values;
  static AvailabilityStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class AvailabilityStatusMixin = Object with _$AvailabilityStatusMixin;

