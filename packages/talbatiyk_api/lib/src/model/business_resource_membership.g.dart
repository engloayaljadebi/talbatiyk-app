// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_resource_membership.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessResourceMembership extends BusinessResourceMembership {
  @override
  final String id;
  @override
  final String status;
  @override
  final BuiltList<JsonObject?> roles;
  @override
  final String? joinedAt;

  factory _$BusinessResourceMembership(
          [void Function(BusinessResourceMembershipBuilder)? updates]) =>
      (BusinessResourceMembershipBuilder()..update(updates))._build();

  _$BusinessResourceMembership._(
      {required this.id,
      required this.status,
      required this.roles,
      this.joinedAt})
      : super._();
  @override
  BusinessResourceMembership rebuild(
          void Function(BusinessResourceMembershipBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessResourceMembershipBuilder toBuilder() =>
      BusinessResourceMembershipBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessResourceMembership &&
        id == other.id &&
        status == other.status &&
        roles == other.roles &&
        joinedAt == other.joinedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BusinessResourceMembership')
          ..add('id', id)
          ..add('status', status)
          ..add('roles', roles)
          ..add('joinedAt', joinedAt))
        .toString();
  }
}

class BusinessResourceMembershipBuilder
    implements
        Builder<BusinessResourceMembership, BusinessResourceMembershipBuilder> {
  _$BusinessResourceMembership? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  ListBuilder<JsonObject?>? _roles;
  ListBuilder<JsonObject?> get roles =>
      _$this._roles ??= ListBuilder<JsonObject?>();
  set roles(ListBuilder<JsonObject?>? roles) => _$this._roles = roles;

  String? _joinedAt;
  String? get joinedAt => _$this._joinedAt;
  set joinedAt(String? joinedAt) => _$this._joinedAt = joinedAt;

  BusinessResourceMembershipBuilder() {
    BusinessResourceMembership._defaults(this);
  }

  BusinessResourceMembershipBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _roles = $v.roles.toBuilder();
      _joinedAt = $v.joinedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessResourceMembership other) {
    _$v = other as _$BusinessResourceMembership;
  }

  @override
  void update(void Function(BusinessResourceMembershipBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessResourceMembership build() => _build();

  _$BusinessResourceMembership _build() {
    _$BusinessResourceMembership _$result;
    try {
      _$result = _$v ??
          _$BusinessResourceMembership._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'BusinessResourceMembership', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'BusinessResourceMembership', 'status'),
            roles: roles.build(),
            joinedAt: joinedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        roles.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BusinessResourceMembership', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
