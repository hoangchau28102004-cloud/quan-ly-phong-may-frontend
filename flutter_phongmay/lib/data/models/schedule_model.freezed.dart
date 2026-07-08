// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleItem {

 int? get id; int get thu;@JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc) String get ngayHoc;@JsonKey(name: 'phong_may_id') int? get phongMayId;// 🚀 BỎ chữ 'required' và THÊM '@Default('')' cho các biến dễ bị null từ Server
@JsonKey(name: 'ten_mon') String get tenMon;@JsonKey(name: 'ten_phong') String get tenPhong;@JsonKey(name: 'ma_lop') String get maLop;@JsonKey(name: 'gio_bat_dau') String get gioBatDau;@JsonKey(name: 'gio_ket_thuc') String get gioKetThuc;@JsonKey(name: 'ten_giang_vien') String get tenGiangVien;
/// Create a copy of ScheduleItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleItemCopyWith<ScheduleItem> get copyWith => _$ScheduleItemCopyWithImpl<ScheduleItem>(this as ScheduleItem, _$identity);

  /// Serializes this ScheduleItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleItem&&(identical(other.id, id) || other.id == id)&&(identical(other.thu, thu) || other.thu == thu)&&(identical(other.ngayHoc, ngayHoc) || other.ngayHoc == ngayHoc)&&(identical(other.phongMayId, phongMayId) || other.phongMayId == phongMayId)&&(identical(other.tenMon, tenMon) || other.tenMon == tenMon)&&(identical(other.tenPhong, tenPhong) || other.tenPhong == tenPhong)&&(identical(other.maLop, maLop) || other.maLop == maLop)&&(identical(other.gioBatDau, gioBatDau) || other.gioBatDau == gioBatDau)&&(identical(other.gioKetThuc, gioKetThuc) || other.gioKetThuc == gioKetThuc)&&(identical(other.tenGiangVien, tenGiangVien) || other.tenGiangVien == tenGiangVien));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,thu,ngayHoc,phongMayId,tenMon,tenPhong,maLop,gioBatDau,gioKetThuc,tenGiangVien);

@override
String toString() {
  return 'ScheduleItem(id: $id, thu: $thu, ngayHoc: $ngayHoc, phongMayId: $phongMayId, tenMon: $tenMon, tenPhong: $tenPhong, maLop: $maLop, gioBatDau: $gioBatDau, gioKetThuc: $gioKetThuc, tenGiangVien: $tenGiangVien)';
}


}

/// @nodoc
abstract mixin class $ScheduleItemCopyWith<$Res>  {
  factory $ScheduleItemCopyWith(ScheduleItem value, $Res Function(ScheduleItem) _then) = _$ScheduleItemCopyWithImpl;
@useResult
$Res call({
 int? id, int thu,@JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc) String ngayHoc,@JsonKey(name: 'phong_may_id') int? phongMayId,@JsonKey(name: 'ten_mon') String tenMon,@JsonKey(name: 'ten_phong') String tenPhong,@JsonKey(name: 'ma_lop') String maLop,@JsonKey(name: 'gio_bat_dau') String gioBatDau,@JsonKey(name: 'gio_ket_thuc') String gioKetThuc,@JsonKey(name: 'ten_giang_vien') String tenGiangVien
});




}
/// @nodoc
class _$ScheduleItemCopyWithImpl<$Res>
    implements $ScheduleItemCopyWith<$Res> {
  _$ScheduleItemCopyWithImpl(this._self, this._then);

  final ScheduleItem _self;
  final $Res Function(ScheduleItem) _then;

/// Create a copy of ScheduleItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? thu = null,Object? ngayHoc = null,Object? phongMayId = freezed,Object? tenMon = null,Object? tenPhong = null,Object? maLop = null,Object? gioBatDau = null,Object? gioKetThuc = null,Object? tenGiangVien = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,thu: null == thu ? _self.thu : thu // ignore: cast_nullable_to_non_nullable
as int,ngayHoc: null == ngayHoc ? _self.ngayHoc : ngayHoc // ignore: cast_nullable_to_non_nullable
as String,phongMayId: freezed == phongMayId ? _self.phongMayId : phongMayId // ignore: cast_nullable_to_non_nullable
as int?,tenMon: null == tenMon ? _self.tenMon : tenMon // ignore: cast_nullable_to_non_nullable
as String,tenPhong: null == tenPhong ? _self.tenPhong : tenPhong // ignore: cast_nullable_to_non_nullable
as String,maLop: null == maLop ? _self.maLop : maLop // ignore: cast_nullable_to_non_nullable
as String,gioBatDau: null == gioBatDau ? _self.gioBatDau : gioBatDau // ignore: cast_nullable_to_non_nullable
as String,gioKetThuc: null == gioKetThuc ? _self.gioKetThuc : gioKetThuc // ignore: cast_nullable_to_non_nullable
as String,tenGiangVien: null == tenGiangVien ? _self.tenGiangVien : tenGiangVien // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleItem].
extension ScheduleItemPatterns on ScheduleItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleItem value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleItem value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int thu, @JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc)  String ngayHoc, @JsonKey(name: 'phong_may_id')  int? phongMayId, @JsonKey(name: 'ten_mon')  String tenMon, @JsonKey(name: 'ten_phong')  String tenPhong, @JsonKey(name: 'ma_lop')  String maLop, @JsonKey(name: 'gio_bat_dau')  String gioBatDau, @JsonKey(name: 'gio_ket_thuc')  String gioKetThuc, @JsonKey(name: 'ten_giang_vien')  String tenGiangVien)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleItem() when $default != null:
return $default(_that.id,_that.thu,_that.ngayHoc,_that.phongMayId,_that.tenMon,_that.tenPhong,_that.maLop,_that.gioBatDau,_that.gioKetThuc,_that.tenGiangVien);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int thu, @JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc)  String ngayHoc, @JsonKey(name: 'phong_may_id')  int? phongMayId, @JsonKey(name: 'ten_mon')  String tenMon, @JsonKey(name: 'ten_phong')  String tenPhong, @JsonKey(name: 'ma_lop')  String maLop, @JsonKey(name: 'gio_bat_dau')  String gioBatDau, @JsonKey(name: 'gio_ket_thuc')  String gioKetThuc, @JsonKey(name: 'ten_giang_vien')  String tenGiangVien)  $default,) {final _that = this;
switch (_that) {
case _ScheduleItem():
return $default(_that.id,_that.thu,_that.ngayHoc,_that.phongMayId,_that.tenMon,_that.tenPhong,_that.maLop,_that.gioBatDau,_that.gioKetThuc,_that.tenGiangVien);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int thu, @JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc)  String ngayHoc, @JsonKey(name: 'phong_may_id')  int? phongMayId, @JsonKey(name: 'ten_mon')  String tenMon, @JsonKey(name: 'ten_phong')  String tenPhong, @JsonKey(name: 'ma_lop')  String maLop, @JsonKey(name: 'gio_bat_dau')  String gioBatDau, @JsonKey(name: 'gio_ket_thuc')  String gioKetThuc, @JsonKey(name: 'ten_giang_vien')  String tenGiangVien)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleItem() when $default != null:
return $default(_that.id,_that.thu,_that.ngayHoc,_that.phongMayId,_that.tenMon,_that.tenPhong,_that.maLop,_that.gioBatDau,_that.gioKetThuc,_that.tenGiangVien);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleItem implements ScheduleItem {
  const _ScheduleItem({this.id, required this.thu, @JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc) required this.ngayHoc, @JsonKey(name: 'phong_may_id') this.phongMayId, @JsonKey(name: 'ten_mon') this.tenMon = '', @JsonKey(name: 'ten_phong') this.tenPhong = '', @JsonKey(name: 'ma_lop') this.maLop = '', @JsonKey(name: 'gio_bat_dau') this.gioBatDau = '', @JsonKey(name: 'gio_ket_thuc') this.gioKetThuc = '', @JsonKey(name: 'ten_giang_vien') this.tenGiangVien = ''});
  factory _ScheduleItem.fromJson(Map<String, dynamic> json) => _$ScheduleItemFromJson(json);

@override final  int? id;
@override final  int thu;
@override@JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc) final  String ngayHoc;
@override@JsonKey(name: 'phong_may_id') final  int? phongMayId;
// 🚀 BỎ chữ 'required' và THÊM '@Default('')' cho các biến dễ bị null từ Server
@override@JsonKey(name: 'ten_mon') final  String tenMon;
@override@JsonKey(name: 'ten_phong') final  String tenPhong;
@override@JsonKey(name: 'ma_lop') final  String maLop;
@override@JsonKey(name: 'gio_bat_dau') final  String gioBatDau;
@override@JsonKey(name: 'gio_ket_thuc') final  String gioKetThuc;
@override@JsonKey(name: 'ten_giang_vien') final  String tenGiangVien;

/// Create a copy of ScheduleItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleItemCopyWith<_ScheduleItem> get copyWith => __$ScheduleItemCopyWithImpl<_ScheduleItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleItem&&(identical(other.id, id) || other.id == id)&&(identical(other.thu, thu) || other.thu == thu)&&(identical(other.ngayHoc, ngayHoc) || other.ngayHoc == ngayHoc)&&(identical(other.phongMayId, phongMayId) || other.phongMayId == phongMayId)&&(identical(other.tenMon, tenMon) || other.tenMon == tenMon)&&(identical(other.tenPhong, tenPhong) || other.tenPhong == tenPhong)&&(identical(other.maLop, maLop) || other.maLop == maLop)&&(identical(other.gioBatDau, gioBatDau) || other.gioBatDau == gioBatDau)&&(identical(other.gioKetThuc, gioKetThuc) || other.gioKetThuc == gioKetThuc)&&(identical(other.tenGiangVien, tenGiangVien) || other.tenGiangVien == tenGiangVien));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,thu,ngayHoc,phongMayId,tenMon,tenPhong,maLop,gioBatDau,gioKetThuc,tenGiangVien);

@override
String toString() {
  return 'ScheduleItem(id: $id, thu: $thu, ngayHoc: $ngayHoc, phongMayId: $phongMayId, tenMon: $tenMon, tenPhong: $tenPhong, maLop: $maLop, gioBatDau: $gioBatDau, gioKetThuc: $gioKetThuc, tenGiangVien: $tenGiangVien)';
}


}

/// @nodoc
abstract mixin class _$ScheduleItemCopyWith<$Res> implements $ScheduleItemCopyWith<$Res> {
  factory _$ScheduleItemCopyWith(_ScheduleItem value, $Res Function(_ScheduleItem) _then) = __$ScheduleItemCopyWithImpl;
@override @useResult
$Res call({
 int? id, int thu,@JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc) String ngayHoc,@JsonKey(name: 'phong_may_id') int? phongMayId,@JsonKey(name: 'ten_mon') String tenMon,@JsonKey(name: 'ten_phong') String tenPhong,@JsonKey(name: 'ma_lop') String maLop,@JsonKey(name: 'gio_bat_dau') String gioBatDau,@JsonKey(name: 'gio_ket_thuc') String gioKetThuc,@JsonKey(name: 'ten_giang_vien') String tenGiangVien
});




}
/// @nodoc
class __$ScheduleItemCopyWithImpl<$Res>
    implements _$ScheduleItemCopyWith<$Res> {
  __$ScheduleItemCopyWithImpl(this._self, this._then);

  final _ScheduleItem _self;
  final $Res Function(_ScheduleItem) _then;

/// Create a copy of ScheduleItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? thu = null,Object? ngayHoc = null,Object? phongMayId = freezed,Object? tenMon = null,Object? tenPhong = null,Object? maLop = null,Object? gioBatDau = null,Object? gioKetThuc = null,Object? tenGiangVien = null,}) {
  return _then(_ScheduleItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,thu: null == thu ? _self.thu : thu // ignore: cast_nullable_to_non_nullable
as int,ngayHoc: null == ngayHoc ? _self.ngayHoc : ngayHoc // ignore: cast_nullable_to_non_nullable
as String,phongMayId: freezed == phongMayId ? _self.phongMayId : phongMayId // ignore: cast_nullable_to_non_nullable
as int?,tenMon: null == tenMon ? _self.tenMon : tenMon // ignore: cast_nullable_to_non_nullable
as String,tenPhong: null == tenPhong ? _self.tenPhong : tenPhong // ignore: cast_nullable_to_non_nullable
as String,maLop: null == maLop ? _self.maLop : maLop // ignore: cast_nullable_to_non_nullable
as String,gioBatDau: null == gioBatDau ? _self.gioBatDau : gioBatDau // ignore: cast_nullable_to_non_nullable
as String,gioKetThuc: null == gioKetThuc ? _self.gioKetThuc : gioKetThuc // ignore: cast_nullable_to_non_nullable
as String,tenGiangVien: null == tenGiangVien ? _self.tenGiangVien : tenGiangVien // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
