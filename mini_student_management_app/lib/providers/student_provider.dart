import 'package:flutter/foundation.dart';

import '../models/student.dart';
import '../services/database_service.dart';

class StudentProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final List<Student> _students = [];

  bool _isLoading = false;
  String _searchQuery = '';

  List<Student> get students => List.unmodifiable(_students);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Student> get filteredStudents {
    if (_searchQuery.isEmpty) {
      return students;
    }

    final lowerQuery = _searchQuery.toLowerCase();
    return students.where((student) {
      return student.name.toLowerCase().contains(lowerQuery) ||
          student.email.toLowerCase().contains(lowerQuery) ||
          student.grade.toLowerCase().contains(lowerQuery) ||
          student.phone.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    final loadedStudents = await _databaseService.fetchStudents();
    _students
      ..clear()
      ..addAll(loadedStudents);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    final id = await _databaseService.insertStudent(student);
    _students.insert(0, student.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    if (student.id == null) {
      return;
    }
    await _databaseService.updateStudent(student);

    final index = _students.indexWhere((existing) => existing.id == student.id);
    if (index != -1) {
      _students[index] = student;
      notifyListeners();
    }
  }

  Future<void> removeStudent(int id) async {
    await _databaseService.deleteStudent(id);
    _students.removeWhere((student) => student.id == id);
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
