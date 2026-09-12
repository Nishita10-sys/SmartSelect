import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String enrollmentNumber,
    required String branch,
    required String specialization,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'enrollmentNumber': enrollmentNumber,
        'branch': branch,
        'specialization': specialization,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }
}