import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/data/models/schedule_model.dart';

class ScheduleService {
  // Gọi API lấy lịch học
  Future<List<ScheduleItem>> fetchScheduleList(
    int tuanHoc, {
    int? lopHocId,
    int? nguoiDungId,
  }) async {
    try {
      final response = await ApiService.get(
        '/schedule/list?tuan_hoc=$tuanHoc' +
            (lopHocId != null ? '&lop_hoc_id=$lopHocId' : '') +
            (nguoiDungId != null ? '&nguoi_dung_id=$nguoiDungId' : ''),
      );
      if (response.statusCode == 200) {
        final data = ApiService.decodeBody(response);
        if (data != null && data['success'] == true) {
          List listData = data['data'];
          return listData.map((e) => ScheduleItem.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> bookRoom(
    String ngayYeuCau,
    int nguoiDungId,
    int phongMayId,
    String maCa,
    int tietBatDau,
    int tietKetThuc,
    String mucDich,
  ) async {
    try {
      final response = await ApiService.post('/schedule/book', {
        'ngay_yeu_cau': ngayYeuCau,
        'ma_nguoi_dung': nguoiDungId,
        'ma_phong': phongMayId,
        'ma_ca': maCa,
        'tiet_bat_dau': tietBatDau,
        'tiet_ket_thuc': tietKetThuc,
        'muc_dich': mucDich,
      });
      // Kiểm tra API trả về có success = true không
      final data = ApiService.decodeBody(response);
      return (response.statusCode == 201 || response.statusCode == 200) && data?['success'] == true;
    } catch (e) {
      return false;
    }
  }
}