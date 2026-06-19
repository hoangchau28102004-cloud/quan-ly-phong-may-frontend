import 'package:flutter_phongmay/domain/entities/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> getScheduleList(
    int tuanHoc, {
    int? lopHocId,
    int? nguoiDungId,
  });

  Future<bool> bookRoom(
    String ngayYeuCau, 
    int nguoiDungId, 
    int phongMayId,
    String maCa,
    int tietBatDau,
    int tietKetThuc,
    String mucDich,
  );
}