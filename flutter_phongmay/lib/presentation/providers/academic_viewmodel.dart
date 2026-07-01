import 'package:flutter/material.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/academic_repository.dart'; 
import '../../data/models/class_model.dart';
import '../../data/models/teacher_model.dart';
import '../../data/models/student_model.dart';
import '../../data/models/course_section_model.dart';
import '../../data/models/subject_model.dart';

class AcademicViewModel extends ChangeNotifier {
  final AcademicRepository repository;

  AcademicViewModel({required this.repository}) {
    fetchInitialData();
  }
  List<StudentModel> classStudents = [];
  List<StudentModel> availableStudents = [];
  bool isStudentLoading = false;
  List<ClassModel> classes = [];
  List<TeacherModel> teachers = [];
  bool isLoading = false;
  String errorMessage = '';
  List<CourseSectionModel> courseSections = [];
  List<dynamic> subjects = [];
  List<dynamic> academicYears = [];
  List<dynamic> rooms = [];
  bool isSectionLoading = false;
  List<StudentModel> moduleStudents = [];
  List<StudentModel> allStudents = [];

  Future<void> fetchInitialData() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        repository.getClasses(),
        repository.getTeachers(),
      ]);
      
      classes = results[0] as List<ClassModel>;
      teachers = results[1] as List<TeacherModel>;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveClass(int? id, ClassModel data) async {
    try {
      if (id != null) {
        await repository.updateClass(id, data);
      } else {
        await repository.addClass(data);
      }
      await fetchInitialData(); // Load lại data sau khi thay đổi
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteClass(int id) async {
    try {
      await repository.deleteClass(id);
      classes.removeWhere((element) => element.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  Future<void> fetchStudentsForClass(int classId) async {
    isStudentLoading = true;
    notifyListeners();
    try {
      final resList = await ApiService.get('/lop-hoc/$classId/sinh-vien');
      final resAvail = await ApiService.get('/sinh-vien-tu-do');
      
      final listDecoded = ApiService.decodeBody(resList);
      final availDecoded = ApiService.decodeBody(resAvail);

      final List<dynamic> listData = (listDecoded != null && listDecoded['data'] != null) ? listDecoded['data'] : [];
      final List<dynamic> availData = (availDecoded != null && availDecoded['data'] != null) ? availDecoded['data'] : [];

      classStudents = listData.map((json) => StudentModel.fromJson(json)).toList();
      availableStudents = availData.map((json) => StudentModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isStudentLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStudentToClass(int classId, int studentId) async {
    try {
      await ApiService.post('/lop-hoc/$classId/sinh-vien', {'studentId': studentId});
      await fetchStudentsForClass(classId); // Tải lại list SV
      await fetchInitialData(); // Tải lại list Lớp để cập nhật Số lượng SV
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeStudentFromClass(int classId, int studentId) async {
    try {
      await ApiService.delete('/sinh-vien/$studentId/khoi-lop');
      await fetchStudentsForClass(classId); 
      await fetchInitialData(); 
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  Future<void> fetchCourseSections() async {
    isSectionLoading = true;
    notifyListeners();
    try {
      // 1. Lấy danh sách Lớp học phần
      final resLhp = await ApiService.get('/lop-hoc-phan');
      final decodedLhp = ApiService.decodeBody(resLhp);
      if (decodedLhp != null && decodedLhp['data'] != null) {
        courseSections = (decodedLhp['data'] as List).map((json) => CourseSectionModel.fromJson(json)).toList();
      }

      // 2. Lấy dữ liệu cho Dropdown (Môn, Năm học, Phòng)
      final resMon = await ApiService.get('/mon-hoc');
      final resNam = await ApiService.get('/nam-hoc');
      final resPhong = await ApiService.get('/phong-may');
      
      subjects = ApiService.decodeBody(resMon)?['data'] ?? [];
      academicYears = ApiService.decodeBody(resNam)?['data'] ?? [];
      rooms = ApiService.decodeBody(resPhong)?['data'] ?? [];
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isSectionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveCourseSection(int? id, CourseSectionModel data) async {
    try {
      if (id == null || id == 0) {
        await ApiService.post('/lop-hoc-phan', data.toJson());
      } else {
        await ApiService.put('/lop-hoc-phan/$id', data.toJson());
      }
      await fetchCourseSections(); // Tải lại dữ liệu sau khi lưu
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourseSection(int id) async {
    try {
      await ApiService.delete('/lop-hoc-phan/$id');
      await fetchCourseSections();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  // =========================================================
  // --- BIẾN & HÀM CHO SINH VIÊN TRONG LỚP HỌC PHẦN ---
  // =========================================================


  Future<void> fetchStudentsForModule(int moduleId) async {
    isStudentLoading = true;
    notifyListeners();
    try {
      // Lấy danh sách SV đang học trong Lớp học phần này
      final resList = await ApiService.get('/lop-hoc-phan/$moduleId/sinh-vien');
      // Lấy danh sách SV để đưa vào Dropdown lúc chọn Thêm mới 
      // (Tạm mượn API sinh-vien-tu-do, nếu có API /sinh-vien thì bạn thay vào nhé)
      final resAll = await ApiService.get('/sinh-vien-tu-do');

      final listDecoded = ApiService.decodeBody(resList);
      final allDecoded = ApiService.decodeBody(resAll);

      final List<dynamic> listData = (listDecoded != null && listDecoded['data'] != null) ? listDecoded['data'] : [];
      final List<dynamic> allData = (allDecoded != null && allDecoded['data'] != null) ? allDecoded['data'] : [];

      moduleStudents = listData.map((json) => StudentModel.fromJson(json)).toList();
      allStudents = allData.map((json) => StudentModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isStudentLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStudentToModule(int moduleId, int studentId) async {
    try {
      await ApiService.post('/lop-hoc-phan/$moduleId/sinh-vien', {'studentId': studentId});
      await fetchStudentsForModule(moduleId); // Tải lại DS SV
      await fetchCourseSections(); // Tải lại DS Lớp học phần để cập nhật con số Sĩ số
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeStudentFromModule(int moduleId, int studentId) async {
    try {
      await ApiService.delete('/lop-hoc-phan/$moduleId/sinh-vien/$studentId');
      await fetchStudentsForModule(moduleId); 
      await fetchCourseSections(); 
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  // =========================================================
  // --- BIẾN & HÀM CHO QUẢN LÝ MÔN HỌC ---
  // =========================================================
  List<SubjectModel> listMonHoc = [];
  bool isSubjectLoading = false;

  Future<void> fetchSubjectsData() async {
    isSubjectLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/mon-hoc');
      final decoded = ApiService.decodeBody(res);
      if (decoded != null && decoded['data'] != null) {
        listMonHoc = (decoded['data'] as List).map((json) => SubjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isSubjectLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSubject(int? id, SubjectModel data) async {
    try {
      print("=========================================");
      print("🚀 DỮ LIỆU FLUTTER GỬI ĐI: ${data.toJson()}");
      print("=========================================");
      if (id == null || id == 0) {
        await ApiService.post('/mon-hoc', data.toJson());
      } else {
        await ApiService.put('/mon-hoc/$id', data.toJson());
      }
      await fetchSubjectsData(); // Tải lại danh sách môn
      await fetchCourseSections(); // Tải lại form Lớp học phần
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(int id) async {
    try {
      await ApiService.delete('/mon-hoc/$id');
      await fetchSubjectsData();
      await fetchCourseSections();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}