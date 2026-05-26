import 'package:flutter_phongmay/domain/entities/schedule_entity.dart';
import 'package:flutter_phongmay/domain/repositories/schedule_repository.dart';

class GetScheduleUseCase {
  final ScheduleRepository scheduleRepository;

  GetScheduleUseCase(this.scheduleRepository);

  Future<List<ScheduleEntity>> call(
    int tuanHoc, {
    int? lopHocId,
    int? nguoiDungId,
  }) async {
    if (tuanHoc <= 0) {
      throw Exception('Tuần học phải lớn hơn 0');
    }
    return await scheduleRepository.getScheduleList(
      tuanHoc,
      lopHocId: lopHocId,
      nguoiDungId: nguoiDungId,
    );
  }
}
