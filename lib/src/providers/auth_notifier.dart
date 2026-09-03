import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _auth;
  bool isAuthenticated = false;
  Map<String, dynamic>? user;

  AuthNotifier({AuthService? auth}) : _auth = auth ?? AuthService();

  Future<void> initialize() async {
    final token = await _auth.getToken();
    if (token != null && token.isNotEmpty) {
      final res = await _auth.getProfile();
      if (res['success'] == true) {
        user = (res['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>?;
        isAuthenticated = true;
      } else {
        await _auth.clearToken();
        isAuthenticated = false;
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _auth.login(email, password);
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>?;
      user = data?['user'] as Map<String, dynamic>?;
      isAuthenticated = true;
      notifyListeners();
    }
    return res;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    return await _auth.register(payload);
  }

  Future<Map<String, dynamic>> verifyOtp(String userId, String otpCode) async {
    final res = await _auth.verifyOtp(userId, otpCode);
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>?;
      user = data?['user'] as Map<String, dynamic>?;
      isAuthenticated = true;
      notifyListeners();
    }
    return res;
  }

  Future<void> logout() async {
    await _auth.logout();
    user = null;
    isAuthenticated = false;
    notifyListeners();
  }
}
