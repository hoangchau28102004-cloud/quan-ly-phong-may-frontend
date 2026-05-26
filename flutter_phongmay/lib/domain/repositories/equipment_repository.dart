import 'package:flutter_phongmay/domain/entities/equipment_entity.dart';

abstract class EquipmentRepository {
  Future<List<EquipmentEntity>> getAllEquipment();
  Future<List<EquipmentEntity>> getBorrowHistory(int nguoiDungId);
}
