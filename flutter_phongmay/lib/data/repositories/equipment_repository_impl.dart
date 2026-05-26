import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/domain/entities/equipment_entity.dart';
import 'package:flutter_phongmay/domain/repositories/equipment_repository.dart';
import 'dart:convert';

class EquipmentRepositoryImpl implements EquipmentRepository {
  EquipmentRepositoryImpl();

  @override
  Future<List<EquipmentEntity>> getAllEquipment() async {
    try {
      final response = await ApiService.get('/thiet-bi');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> equipment = data['data'] ?? [];
        return equipment.map((item) {
          return EquipmentEntity(
            id: item['id'] ?? 0,
            tenTb: item['ten_tb'] ?? '',
            donViTinh: item['don_vi_tinh'] ?? 'Cái',
            thongSoKyThuat: item['thong_so_ky_thuat'],
            namTrangBi: item['nam_trang_bi'],
            soLuongCon: item['so_luong_con'] ?? 0,
            phongMayId: item['phong_may_id'],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<EquipmentEntity>> getBorrowHistory(int nguoiDungId) async {
    try {
      final response = await ApiService.get('/phieu-muon/ca-nhan');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> borrowHistory = data['data'] ?? [];
        return borrowHistory.map((item) {
          return EquipmentEntity(
            id: item['id'] ?? 0,
            tenTb: item['ten_tb'] ?? '',
            donViTinh: item['don_vi_tinh'] ?? 'Cái',
            thongSoKyThuat: null,
            namTrangBi: null,
            soLuongCon: item['so_luong'] ?? 0,
            phongMayId: null,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
