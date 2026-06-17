// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 int get id;@JsonKey(name: 'tai_khoan') String get taiKhoan;@JsonKey(name: 'ho_ten') String get hoTen;@JsonKey(name: 'vai_tro_id') int get vaiTroId;@JsonKey(name: 'lop_hoc_id') int? get lopHocId;// --- KHAI BÁO THÊM CÁC TRƯỜNG CÒN THIẾU Ở ĐÂY ---
@JsonKey(name: 'email') String? get email;@JsonKey(name: 'so_dien_thoai') String? get soDienThoai;@JsonKey(name: 'trang_thai') int? get trangThai;@JsonKey(name: 'gioi_tinh') String? get gioiTinh;@JsonKey(name: 'ngay_sinh') String? get ngaySinh;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.taiKhoan, taiKhoan) || other.taiKhoan == taiKhoan)&&(identical(other.hoTen, hoTen) || other.hoTen == hoTen)&&(identical(other.vaiTroId, vaiTroId) || other.vaiTroId == vaiTroId)&&(identical(other.lopHocId, lopHocId) || other.lopHocId == lopHocId)&&(identical(other.email, email) || other.email == email)&&(identical(other.soDienThoai, soDienThoai) || other.soDienThoai == soDienThoai)&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&(identical(other.gioiTinh, gioiTinh) || other.gioiTinh == gioiTinh)&&(identical(other.ngaySinh, ngaySinh) || other.ngaySinh == ngaySinh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,taiKhoan,hoTen,vaiTroId,lopHocId,email,soDienThoai,trangThai,gioiTinh,ngaySinh);

@override
String toString() {
  return 'UserModel(id: $id, taiKhoan: $taiKhoan, hoTen: $hoTen, vaiTroId: $vaiTroId, lopHocId: $lopHocId, email: $email, soDienThoai: $soDienThoai, trangThai: $trangThai, gioiTinh: $gioiTinh, ngaySinh: $ngaySinh)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'tai_khoan') String taiKhoan,@JsonKey(name: 'ho_ten') String hoTen,@JsonKey(name: 'vai_tro_id') int vaiTroId,@JsonKey(name: 'lop_hoc_id') int? lopHocId,@JsonKey(name: 'email') String? email,@JsonKey(name: 'so_dien_thoai') String? soDienThoai,@JsonKey(name: 'trang_thai') int? trangThai,@JsonKey(name: 'gioi_tinh') String? gioiTinh,@JsonKey(name: 'ngay_sinh') String? ngaySinh
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taiKhoan = null,Object? hoTen = null,Object? vaiTroId = null,Object? lopHocId = freezed,Object? email = freezed,Object? soDienThoai = freezed,Object? trangThai = freezed,Object? gioiTinh = freezed,Object? ngaySinh = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taiKhoan: null == taiKhoan ? _self.taiKhoan : taiKhoan // ignore: cast_nullable_to_non_nullable
as String,hoTen: null == hoTen ? _self.hoTen : hoTen // ignore: cast_nullable_to_non_nullable
as String,vaiTroId: null == vaiTroId ? _self.vaiTroId : vaiTroId // ignore: cast_nullable_to_non_nullable
as int,lopHocId: freezed == lopHocId ? _self.lopHocId : lopHocId // ignore: cast_nullable_to_non_nullable
as int?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,soDienThoai: freezed == soDienThoai ? _self.soDienThoai : soDienThoai // ignore: cast_nullable_to_non_nullable
as String?,trangThai: freezed == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as int?,gioiTinh: freezed == gioiTinh ? _self.gioiTinh : gioiTinh // ignore: cast_nullable_to_non_nullable
as String?,ngaySinh: freezed == ngaySinh ? _self.ngaySinh : ngaySinh // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'tai_khoan')  String taiKhoan, @JsonKey(name: 'ho_ten')  String hoTen, @JsonKey(name: 'vai_tro_id')  int vaiTroId, @JsonKey(name: 'lop_hoc_id')  int? lopHocId, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'so_dien_thoai')  String? soDienThoai, @JsonKey(name: 'trang_thai')  int? trangThai, @JsonKey(name: 'gioi_tinh')  String? gioiTinh, @JsonKey(name: 'ngay_sinh')  String? ngaySinh)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.taiKhoan,_that.hoTen,_that.vaiTroId,_that.lopHocId,_that.email,_that.soDienThoai,_that.trangThai,_that.gioiTinh,_that.ngaySinh);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'tai_khoan')  String taiKhoan, @JsonKey(name: 'ho_ten')  String hoTen, @JsonKey(name: 'vai_tro_id')  int vaiTroId, @JsonKey(name: 'lop_hoc_id')  int? lopHocId, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'so_dien_thoai')  String? soDienThoai, @JsonKey(name: 'trang_thai')  int? trangThai, @JsonKey(name: 'gioi_tinh')  String? gioiTinh, @JsonKey(name: 'ngay_sinh')  String? ngaySinh)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.taiKhoan,_that.hoTen,_that.vaiTroId,_that.lopHocId,_that.email,_that.soDienThoai,_that.trangThai,_that.gioiTinh,_that.ngaySinh);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'tai_khoan')  String taiKhoan, @JsonKey(name: 'ho_ten')  String hoTen, @JsonKey(name: 'vai_tro_id')  int vaiTroId, @JsonKey(name: 'lop_hoc_id')  int? lopHocId, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'so_dien_thoai')  String? soDienThoai, @JsonKey(name: 'trang_thai')  int? trangThai, @JsonKey(name: 'gioi_tinh')  String? gioiTinh, @JsonKey(name: 'ngay_sinh')  String? ngaySinh)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.taiKhoan,_that.hoTen,_that.vaiTroId,_that.lopHocId,_that.email,_that.soDienThoai,_that.trangThai,_that.gioiTinh,_that.ngaySinh);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.id, @JsonKey(name: 'tai_khoan') required this.taiKhoan, @JsonKey(name: 'ho_ten') required this.hoTen, @JsonKey(name: 'vai_tro_id') required this.vaiTroId, @JsonKey(name: 'lop_hoc_id') this.lopHocId, @JsonKey(name: 'email') this.email, @JsonKey(name: 'so_dien_thoai') this.soDienThoai, @JsonKey(name: 'trang_thai') this.trangThai, @JsonKey(name: 'gioi_tinh') this.gioiTinh, @JsonKey(name: 'ngay_sinh') this.ngaySinh});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  int id;
@override@JsonKey(name: 'tai_khoan') final  String taiKhoan;
@override@JsonKey(name: 'ho_ten') final  String hoTen;
@override@JsonKey(name: 'vai_tro_id') final  int vaiTroId;
@override@JsonKey(name: 'lop_hoc_id') final  int? lopHocId;
// --- KHAI BÁO THÊM CÁC TRƯỜNG CÒN THIẾU Ở ĐÂY ---
@override@JsonKey(name: 'email') final  String? email;
@override@JsonKey(name: 'so_dien_thoai') final  String? soDienThoai;
@override@JsonKey(name: 'trang_thai') final  int? trangThai;
@override@JsonKey(name: 'gioi_tinh') final  String? gioiTinh;
@override@JsonKey(name: 'ngay_sinh') final  String? ngaySinh;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.taiKhoan, taiKhoan) || other.taiKhoan == taiKhoan)&&(identical(other.hoTen, hoTen) || other.hoTen == hoTen)&&(identical(other.vaiTroId, vaiTroId) || other.vaiTroId == vaiTroId)&&(identical(other.lopHocId, lopHocId) || other.lopHocId == lopHocId)&&(identical(other.email, email) || other.email == email)&&(identical(other.soDienThoai, soDienThoai) || other.soDienThoai == soDienThoai)&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&(identical(other.gioiTinh, gioiTinh) || other.gioiTinh == gioiTinh)&&(identical(other.ngaySinh, ngaySinh) || other.ngaySinh == ngaySinh));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,taiKhoan,hoTen,vaiTroId,lopHocId,email,soDienThoai,trangThai,gioiTinh,ngaySinh);

@override
String toString() {
  return 'UserModel(id: $id, taiKhoan: $taiKhoan, hoTen: $hoTen, vaiTroId: $vaiTroId, lopHocId: $lopHocId, email: $email, soDienThoai: $soDienThoai, trangThai: $trangThai, gioiTinh: $gioiTinh, ngaySinh: $ngaySinh)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'tai_khoan') String taiKhoan,@JsonKey(name: 'ho_ten') String hoTen,@JsonKey(name: 'vai_tro_id') int vaiTroId,@JsonKey(name: 'lop_hoc_id') int? lopHocId,@JsonKey(name: 'email') String? email,@JsonKey(name: 'so_dien_thoai') String? soDienThoai,@JsonKey(name: 'trang_thai') int? trangThai,@JsonKey(name: 'gioi_tinh') String? gioiTinh,@JsonKey(name: 'ngay_sinh') String? ngaySinh
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taiKhoan = null,Object? hoTen = null,Object? vaiTroId = null,Object? lopHocId = freezed,Object? email = freezed,Object? soDienThoai = freezed,Object? trangThai = freezed,Object? gioiTinh = freezed,Object? ngaySinh = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taiKhoan: null == taiKhoan ? _self.taiKhoan : taiKhoan // ignore: cast_nullable_to_non_nullable
as String,hoTen: null == hoTen ? _self.hoTen : hoTen // ignore: cast_nullable_to_non_nullable
as String,vaiTroId: null == vaiTroId ? _self.vaiTroId : vaiTroId // ignore: cast_nullable_to_non_nullable
as int,lopHocId: freezed == lopHocId ? _self.lopHocId : lopHocId // ignore: cast_nullable_to_non_nullable
as int?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,soDienThoai: freezed == soDienThoai ? _self.soDienThoai : soDienThoai // ignore: cast_nullable_to_non_nullable
as String?,trangThai: freezed == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as int?,gioiTinh: freezed == gioiTinh ? _self.gioiTinh : gioiTinh // ignore: cast_nullable_to_non_nullable
as String?,ngaySinh: freezed == ngaySinh ? _self.ngaySinh : ngaySinh // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
