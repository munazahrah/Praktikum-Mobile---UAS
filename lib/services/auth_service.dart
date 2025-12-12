import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'currentUser';
  // Kunci baru untuk menyimpan seluruh dummy database user
  static const String _dbKey = 'userDatabase';

  // Database yang sekarang akan diisi dari SharedPreferences saat dibutuhkan
  Map<String, dynamic> _userDatabase = {};

  // --- HELPER: Load Database dari SharedPreferences ---
  Future<void> _loadDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final dbJsonString = prefs.getString(_dbKey);
    if (dbJsonString != null) {
      // Mengubah string JSON menjadi Map<String, dynamic>
      _userDatabase = json.decode(dbJsonString) as Map<String, dynamic>;
    } else {
      _userDatabase = {};
    }
  }

  // --- HELPER: Save Database ke SharedPreferences ---
  Future<void> _saveDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    // Mengubah Map<String, dynamic> menjadi string JSON
    final dbJsonString = json.encode(_userDatabase);
    await prefs.setString(_dbKey, dbJsonString);
  }

  // --- REGISTRASI ---
  Future<UserModel> register(
    String username,
    String email,
    String password,
  ) async {
    // Pastikan database dimuat sebelum memeriksa email
    await _loadDatabase();

    if (_userDatabase.containsKey(email)) {
      throw Exception('Email sudah terdaftar. Silakan login.');
    }

    // Simulasi pembuatan user baru
    final newUser = UserModel(
      userId: DateTime.now().millisecondsSinceEpoch.toString(), // ID unik
      username: username,
      email: email,
    );

    // Menyimpan user baru ke dummy database
    _userDatabase[email] = {'user': newUser.toJson(), 'password': password};

    // --- KUNCI PERMANENSI: Simpan database yang sudah diupdate ---
    await _saveDatabase();

    // Setelah register, langsung login dan simpan status sesi
    await _saveUserLocally(newUser);
    return newUser;
  }

  // --- LOGIN ---
  Future<UserModel> login(String email, String password) async {
    // Pastikan database dimuat sebelum mencari user
    await _loadDatabase();

    if (!_userDatabase.containsKey(email)) {
      throw Exception('Pengguna tidak ditemukan. Silakan daftar.');
    }

    final userData = _userDatabase[email];

    // Cek Password
    if (userData['password'] != password) {
      throw Exception('Password salah.');
    }

    // Login Sukses
    final user = UserModel.fromJson(userData['user']);
    await _saveUserLocally(user);
    return user;
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // --- CEK STATUS LOGIN (Tidak Berubah) ---
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = prefs.getString(_userKey);

    if (userJsonString != null) {
      final userJson = json.decode(userJsonString);
      return UserModel.fromJson(userJson);
    }
    return null;
  }

  // --- Helper untuk Menyimpan Sesi (Tidak Berubah) ---
  Future<void> _saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = json.encode(user.toJson());
    await prefs.setString(_userKey, userJsonString);
  }
}
