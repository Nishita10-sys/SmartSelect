
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Student signup
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

  // User login
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

  // Fetch schools using the logged-in user's token
  static Future<Map<String, dynamic>> getSchools({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/schools'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }
}