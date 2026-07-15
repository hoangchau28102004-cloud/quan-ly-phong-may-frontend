import '../../data/models/class_model.dart';
import '../../data/models/teacher_model.dart';

abstract class AcademicRepository {
  Future<List<ClassModel>> getClasses();
  Future<List<TeacherModel>> getTeachers();
  Future<void> addClass(ClassModel classModel);
  Future<void> updateClass(int id, ClassModel classModel);
  Future<void> deleteClass(int id);
}