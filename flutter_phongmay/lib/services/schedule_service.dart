import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_model.dart';
import '../core/services/api_service.dart';

class ScheduleService {
  String get _base => ApiService.baseUrl + '/schedule';

  // Gọi API lấy lịch học
  Future<List<ScheduleItem>> fetchScheduleList(
    int tuanHoc, {
    int? lopHocId,
    int? nguoiDungId,
  }) async {
    String url = '$_base/list?tuan_hoc=$tuanHoc';
    if (lopHocId != null) url += '&lop_hoc_id=$lopHocId';
    if (nguoiDungId != null) url += '&nguoi_dung_id=$nguoiDungId';

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

  // Gọi API mượn phòng
  Future<bool> bookRoom(
    String ngayYeuCau,
    int nguoiDungId,
    int phongMayId,
  ) async {
    try {
      final response = await ApiService.post('/schedule/book', {
        'ngay_yeu_cau': ngayYeuCau,
        'nguoi_dung_id': nguoiDungId,
        'phong_may_id': phongMayId,
      });
      return response.statusCode == 201; // HTTP 201 Created
    } catch (e) {
      return false;
    }
  }
}
