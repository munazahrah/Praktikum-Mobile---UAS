import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  AuthViewModel() {
    checkInitialLogin();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<void> checkInitialLogin() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _authService.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.login(email, password);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.register(username, email, password);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
