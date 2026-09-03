import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';

class AuthService {
  final ApiClient _client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'token';

  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> setToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await _client.post('/auth/login', body: {'email': email, 'password': password});
    final status = resp.statusCode;
    final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
    if (status == 200) {
      final token = body['token'] as String?;
      if (token != null) await setToken(token);
      return {'success': true, 'data': body};
    }
    return {'success': false, 'error': body['error'] ?? 'Login failed', 'status': status};
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final resp = await _client.post('/auth/register', body: userData);
    final status = resp.statusCode;
    final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
    if (status == 201 || status == 200) {
      return {'success': true, 'data': body};
    }
    return {'success': false, 'error': body['error'] ?? 'Registration failed', 'status': status};
  }

  Future<Map<String, dynamic>> verifyOtp(String userId, String otpCode) async {
    final resp = await _client.post('/auth/verify-otp', body: {'userId': userId, 'otpCode': otpCode});
    final status = resp.statusCode;
    final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
    if (status == 200) {
      final token = body['token'] as String?;
      if (token != null) await setToken(token);
      return {'success': true, 'data': body};
    }
    return {'success': false, 'error': body['error'] ?? 'Verification failed', 'status': status};
  }

  Future<Map<String, dynamic>> resendOtp(String userId, {String? channel}) async {
    final Map<String, dynamic> bodyMap = {'userId': userId};
    if (channel != null) bodyMap['channel'] = channel;
    final resp = await _client.post('/auth/resend-otp', body: bodyMap);
    final status = resp.statusCode;
    final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
    if (status == 200) return {'success': true, 'data': body};
    return {'success': false, 'error': body['error'] ?? 'Resend failed', 'status': status};
  }

  Future<Map<String, dynamic>> logout() async {
    final token = await getToken();
    final resp = await _client.post('/auth/logout', token: token);
    await clearToken();
    final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
    if (resp.statusCode == 200) return {'success': true, 'data': body};
    return {'success': false, 'error': body['error'] ?? 'Logout failed', 'status': resp.statusCode};
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final resp = await _client.get('/auth/profile', token: token);
    final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
    if (resp.statusCode == 200) return {'success': true, 'data': body};
    return {'success': false, 'error': body['error'] ?? 'Failed to fetch profile', 'status': resp.statusCode};
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final resp = await _client.post('/auth/forgot-password', body: {'email': email});
    final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
    if (resp.statusCode == 200) return {'success': true, 'data': body};
    return {'success': false, 'error': body['error'] ?? 'Request failed', 'status': resp.statusCode};
  }

  Future<Map<String, dynamic>> resetPassword(String email, String resetToken, String newPassword) async {
    final resp = await _client.post('/auth/reset-password', body: {'email': email, 'resetToken': resetToken, 'newPassword': newPassword});
    final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
    if (resp.statusCode == 200) return {'success': true, 'data': body};
    return {'success': false, 'error': body['error'] ?? 'Reset failed', 'status': resp.statusCode};
  }
}
