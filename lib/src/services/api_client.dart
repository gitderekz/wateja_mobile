import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? (dotenv.env['API_URL'] != null ? '${dotenv.env['API_URL']}/api' : 'http://localhost:3000/api');

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _defaultHeaders([String? token]) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body, String? token}) {
    return http.post(_uri(path), headers: _defaultHeaders(token), body: jsonEncode(body ?? {}));
  }

  Future<http.Response> put(String path, {Map<String, dynamic>? body, String? token}) {
    return http.put(_uri(path), headers: _defaultHeaders(token), body: jsonEncode(body ?? {}));
  }

  Future<http.Response> get(String path, {String? token, Map<String, String>? queryParams}) {
    final uri = queryParams == null ? _uri(path) : Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    return http.get(uri, headers: _defaultHeaders(token));
  }

  Future<http.Response> delete(String path, {String? token}) {
    return http.delete(_uri(path), headers: _defaultHeaders(token));
  }
}
