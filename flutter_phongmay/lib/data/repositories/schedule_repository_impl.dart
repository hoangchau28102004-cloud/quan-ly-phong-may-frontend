import 'package:flutter_phongmay/data/datasources/schedule_service.dart';
import 'package:flutter_phongmay/domain/entities/schedule_entity.dart';
import 'package:flutter_phongmay/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleService scheduleService;

  ScheduleRepositoryImpl(this.scheduleService);

  @override
  Future<List<ScheduleEntity>> getScheduleList(
    int tuanHoc, {
    int? lopHocId,
    int? nguoiDungId,
  }) async {
    final scheduleItems = await scheduleService.fetchScheduleList(
      tuanHoc,
      lopHocId: lopHocId,
      nguoiDungId: nguoiDungId,
    );

    return scheduleItems.map((model) {
      return ScheduleEntity(
        id: model.hashCode, // Fallback: use model hashCode as ID
        ngayHoc: DateTime.parse(model.ngayHoc),
        tuanHoc: 0, // Need to extract from API
        thu: model.thu,
        tietBatDau: 0, // Need to extract from API
        tietKetThuc: 0, // Need to extract from API
        phongMayId: model.phongMayId ?? 0,
        lopHocPhanId: 0, // Need to extract from API
        nguoiDungId: 0, // Need to extract from API
        caHocId: 0, // Need to extract from API
        tenMon: model.tenMon,
        tenPhong: model.tenPhong,
        maLop: model.maLop,
        gioBatDau: model.gioBatDau,
        gioKetThuc: model.gioKetThuc,
        tenGiangVien: model.tenGiangVien,
      );
    }).toList();
  }

  @override
  Future<bool> bookRoom(
    String ngayYeuCau,
    int nguoiDungId,
    int phongMayId,
    String maCa,
    int tietBatDau,
    int tietKetThuc,
    String mucDich,
  ) async {
    return await scheduleService.bookRoom(
      ngayYeuCau,
      nguoiDungId,
      phongMayId,
      maCa,
      tietBatDau,
      tietKetThuc,
      mucDich,
    );
  }
}
