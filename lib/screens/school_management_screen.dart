
import 'package:flutter/material.dart';
import 'faculty_management_screen.dart';
import 'elective_management_screen.dart';

class SchoolManagementScreen extends StatelessWidget {
  final Map<String, dynamic> school;
  final Map<String, dynamic> user;
  final String token;

  const SchoolManagementScreen({
    super.key,
    required this.school,
    required this.user,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final schoolName = school['name'] ?? 'School';

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Management'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(182, 129, 185, 228),
              Color.fromARGB(255, 183, 210, 235),
              Color(0xFF8EC5E8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schoolName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27224D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage faculty members and elective offerings '
                  'for this school.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B6880),
                  ),
                ),
                const SizedBox(height: 28),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFDDF7E8),
                      child: Icon(
                        Icons.people_outline,
                        color: Color(0xFF18794E),
                        size: 30,
                      ),
                    ),
                    title: const Text(
                      'Manage Faculty',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Register faculty and manage faculty '
                        'members belonging to this school.',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FacultyManagementScreen(
                            school: school,
                            user: user,
                            token: token,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFF1E8FF),
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: Color(0xFF7746C8),
                        size: 30,
                      ),
                    ),
                    title: const Text(
                      'Manage Electives',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Create and manage elective offerings '
                        'for this school.',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ElectiveManagementScreen(
                            school: school,
                            user: user,
                            token: token,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}