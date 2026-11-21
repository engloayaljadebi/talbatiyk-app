// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_index200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationIndex200Response extends NotificationIndex200Response {
  @override
  final BuiltList<NotificationResource> data;
  @override
  final ProductIndex200ResponseLinks links;
  @override
  final ProductIndex200ResponseMeta meta;

  factory _$NotificationIndex200Response(
          [void Function(NotificationIndex200ResponseBuilder)? updates]) =>
      (NotificationIndex200ResponseBuilder()..update(updates))._build();

  _$NotificationIndex200Response._(
      {required this.data, required this.links, required this.meta})
      : super._();
  @override
  NotificationIndex200Response rebuild(
          void Function(NotificationIndex200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationIndex200ResponseBuilder toBuilder() =>
      NotificationIndex200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationIndex200Response &&
        data == other.data &&
        links == other.links &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, links.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationIndex200Response')
          ..add('data', data)
          ..add('links', links)
          ..add('meta', meta))
        .toString();
  }
}

class NotificationIndex200ResponseBuilder
    implements
        Builder<NotificationIndex200Response,
            NotificationIndex200ResponseBuilder> {
  _$NotificationIndex200Response? _$v;

  ListBuilder<NotificationResource>? _data;
  ListBuilder<NotificationResource> get data =>
      _$this._data ??= ListBuilder<NotificationResource>();
  set data(ListBuilder<NotificationResource>? data) => _$this._data = data;

  ProductIndex200ResponseLinksBuilder? _links;
  ProductIndex200ResponseLinksBuilder get links =>
      _$this._links ??= ProductIndex200ResponseLinksBuilder();
  set links(ProductIndex200ResponseLinksBuilder? links) =>
      _$this._links = links;

  ProductIndex200ResponseMetaBuilder? _meta;
  ProductIndex200ResponseMetaBuilder get meta =>
      _$this._meta ??= ProductIndex200ResponseMetaBuilder();
  set meta(ProductIndex200ResponseMetaBuilder? meta) => _$this._meta = meta;

  NotificationIndex200ResponseBuilder() {
    NotificationIndex200Response._defaults(this);
  }

  NotificationIndex200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _links = $v.links.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationIndex200Response other) {
    _$v = other as _$NotificationIndex200Response;
  }

  @override
  void update(void Function(NotificationIndex200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationIndex200Response build() => _build();

  _$NotificationIndex200Response _build() {
    _$NotificationIndex200Response _$result;
    try {
      _$result = _$v ??
          _$NotificationIndex200Response._(
            data: data.build(),
            links: links.build(),
            meta: meta.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'links';
        links.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationIndex200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
