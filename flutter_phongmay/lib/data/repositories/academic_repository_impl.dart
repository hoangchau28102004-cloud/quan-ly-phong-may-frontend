import 'academic_repository.dart'; 
import '../datasources/api_service.dart';
import '../models/class_model.dart';
import '../models/teacher_model.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final ApiService apiService;
  
  AcademicRepositoryImpl({required this.apiService});

  @override
  Future<List<ClassModel>> getClasses() async {
    final response = await ApiService.get('/lop-hoc');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = ApiService.decodeBody(response);
      final List<dynamic> data = (decoded != null && decoded is Map && decoded.containsKey('data')) 
          ? decoded['data'] 
          : (decoded is List ? decoded : []);
          
      return data.map((json) => ClassModel.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi load danh sách lớp: ${response.statusCode}');
    }
  }

  @override
  Future<List<TeacherModel>> getTeachers() async {
    final response = await ApiService.get('/giang-vien'); 
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = ApiService.decodeBody(response);
      final List<dynamic> data = (decoded != null && decoded is Map && decoded.containsKey('data')) 
          ? decoded['data'] 
          : (decoded is List ? decoded : []);
          
      return data.map((json) => TeacherModel.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi load danh sách giáo viên: ${response.statusCode}');
    }
  }

  @override
  Future<void> addClass(ClassModel classModel) async {
    // Tự tạo body thủ công để ép key chuẩn snake_case khớp với NodeJS
    final body = {
      'ma_lop': classModel.maLop,
      'nien_khoa': classModel.nienKhoa,
      'chuyen_nganh': classModel.chuyenNganh,
      'ma_giang_vien': classModel.maGiangVien,
    };
    final response = await ApiService.post('/lop-hoc', body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Lỗi thêm lớp: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateClass(int id, ClassModel classModel) async {
    // Tự tạo body thủ công để ép key chuẩn snake_case khớp với NodeJS
    final body = {
      'ma_lop': classModel.maLop,
      'nien_khoa': classModel.nienKhoa,
      'chuyen_nganh': classModel.chuyenNganh,
      'ma_giang_vien': classModel.maGiangVien,
    };
    final response = await ApiService.put('/lop-hoc/$id', body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Lỗi cập nhật lớp: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteClass(int id) async {
    final response = await ApiService.delete('/lop-hoc/$id');
    if (response.statusCode != 200) {
      throw Exception('Lỗi xóa lớp: ${response.statusCode}');
    }
  }
}