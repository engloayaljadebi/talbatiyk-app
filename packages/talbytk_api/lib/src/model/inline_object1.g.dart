// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inline_object1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InlineObject1 extends InlineObject1 {
  @override
  final String message;

  factory _$InlineObject1([void Function(InlineObject1Builder)? updates]) =>
      (InlineObject1Builder()..update(updates))._build();

  _$InlineObject1._({required this.message}) : super._();
  @override
  InlineObject1 rebuild(void Function(InlineObject1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InlineObject1Builder toBuilder() => InlineObject1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InlineObject1 && message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InlineObject1')
          ..add('message', message))
        .toString();
  }
}

class InlineObject1Builder
    implements Builder<InlineObject1, InlineObject1Builder> {
  _$InlineObject1? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  InlineObject1Builder() {
    InlineObject1._defaults(this);
  }

  InlineObject1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InlineObject1 other) {
    _$v = other as _$InlineObject1;
  }

  @override
  void update(void Function(InlineObject1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InlineObject1 build() => _build();

  _$InlineObject1 _build() {
    final _$result = _$v ??
        _$InlineObject1._(
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'InlineObject1', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
