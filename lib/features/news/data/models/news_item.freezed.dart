// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) {
  return _NewsItem.fromJson(json);
}

/// @nodoc
mixin _$NewsItem {
  String get image => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get src => throw _privateConstructorUsedError;

  /// Serializes this NewsItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsItemCopyWith<NewsItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsItemCopyWith<$Res> {
  factory $NewsItemCopyWith(NewsItem value, $Res Function(NewsItem) then) =
      _$NewsItemCopyWithImpl<$Res, NewsItem>;
  @useResult
  $Res call({String image, String category, String title, String src});
}

/// @nodoc
class _$NewsItemCopyWithImpl<$Res, $Val extends NewsItem>
    implements $NewsItemCopyWith<$Res> {
  _$NewsItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
    Object? category = null,
    Object? title = null,
    Object? src = null,
  }) {
    return _then(_value.copyWith(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      src: null == src
          ? _value.src
          : src // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NewsItemImplCopyWith<$Res>
    implements $NewsItemCopyWith<$Res> {
  factory _$$NewsItemImplCopyWith(
          _$NewsItemImpl value, $Res Function(_$NewsItemImpl) then) =
      __$$NewsItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String image, String category, String title, String src});
}

/// @nodoc
class __$$NewsItemImplCopyWithImpl<$Res>
    extends _$NewsItemCopyWithImpl<$Res, _$NewsItemImpl>
    implements _$$NewsItemImplCopyWith<$Res> {
  __$$NewsItemImplCopyWithImpl(
      _$NewsItemImpl _value, $Res Function(_$NewsItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
    Object? category = null,
    Object? title = null,
    Object? src = null,
  }) {
    return _then(_$NewsItemImpl(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      src: null == src
          ? _value.src
          : src // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsItemImpl implements _NewsItem {
  const _$NewsItemImpl(
      {required this.image,
      required this.category,
      required this.title,
      required this.src});

  factory _$NewsItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsItemImplFromJson(json);

  @override
  final String image;
  @override
  final String category;
  @override
  final String title;
  @override
  final String src;

  @override
  String toString() {
    return 'NewsItem(image: $image, category: $category, title: $title, src: $src)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsItemImpl &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.src, src) || other.src == src));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, image, category, title, src);

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      __$$NewsItemImplCopyWithImpl<_$NewsItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsItemImplToJson(
      this,
    );
  }
}

abstract class _NewsItem implements NewsItem {
  const factory _NewsItem(
      {required final String image,
      required final String category,
      required final String title,
      required final String src}) = _$NewsItemImpl;

  factory _NewsItem.fromJson(Map<String, dynamic> json) =
      _$NewsItemImpl.fromJson;

  @override
  String get image;
  @override
  String get category;
  @override
  String get title;
  @override
  String get src;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
