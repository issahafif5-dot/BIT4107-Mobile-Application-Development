import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import '../services/database_service.dart';
import '../services/password_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final existingUser = await _databaseService.getUserByUsername(username);
      if (existingUser != null) {
        _error = 'Username already exists';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final hashedPassword = PasswordService.hashPassword(password);
      final user = User(
        username: username,
        email: email,
        password: hashedPassword,
      );

      final userId = await _databaseService.insertUser(user);
      _currentUser = user.copyWith(id: userId);
      await _secureStorage.write(key: 'user_id', value: userId.toString());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _databaseService.getUserByUsername(username);
      if (user == null) {
        _error = 'Username or password is incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final isPasswordValid = PasswordService.verifyPassword(password, user.password);
      if (!isPasswordValid) {
        _error = 'Username or password is incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _secureStorage.write(key: 'user_id', value: user.id.toString());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSavedUser() async {
    try {
      final userId = await _secureStorage.read(key: 'user_id');
      if (userId != null) {
        _currentUser = await _databaseService.getUserById(int.parse(userId));
      }
    } catch (e) {
      _error = 'Failed to load saved user: $e';
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _secureStorage.delete(key: 'user_id');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
