
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

  // Fetch all active schools
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

  // Fetch admin dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/schools/stats'),
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

  // Fetch faculty members for a school
  static Future<Map<String, dynamic>> getFaculty({
    required String token,
    required String schoolId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/faculty/school/$schoolId'),
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

  // Register a faculty member
  static Future<Map<String, dynamic>> addFaculty({
    required String token,
    required String name,
    required String email,
    required String employeeId,
    required String department,
    required String specialization,
    required String schoolId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/faculty'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'employeeId': employeeId,
        'department': department,
        'specialization': specialization,
        'schoolId': schoolId,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  // Fetch electives for a school
  static Future<Map<String, dynamic>> getElectives({
    required String token,
    required String schoolId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/electives/school/$schoolId'),
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

  // Create an elective
  static Future<Map<String, dynamic>> addElective({
    required String token,
    required String subjectName,
    required String subjectCode,
    required String description,
    required String schoolId,
    required String department,
    required String specialization,
    required String academicYear,
    required int semester,
    required int totalSeats,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/electives'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'subjectName': subjectName,
        'subjectCode': subjectCode,
        'description': description,
        'schoolId': schoolId,
        'department': department,
        'specialization': specialization,
        'academicYear': academicYear,
        'semester': semester,
        'totalSeats': totalSeats,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      'statusCode': response.statusCode,
      'data': data,
    };
  }
}
