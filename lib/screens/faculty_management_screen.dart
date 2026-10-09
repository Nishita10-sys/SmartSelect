
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FacultyManagementScreen extends StatefulWidget {
  final Map<String, dynamic> school;
  final Map<String, dynamic> user;
  final String token;

  const FacultyManagementScreen({
    super.key,
    required this.school,
    required this.user,
    required this.token,
  });

  @override
  State<FacultyManagementScreen> createState() =>
      _FacultyManagementScreenState();
}

class _FacultyManagementScreenState
    extends State<FacultyManagementScreen> {
  List<Map<String, dynamic>> facultyMembers = [];
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _specializationController = TextEditingController();
  final _passwordController = TextEditingController();

  String get schoolName => widget.school['name'] ?? 'School';

  String get schoolId =>
      widget.school['_id']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    fetchFaculty();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _specializationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> fetchFaculty() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getFaculty(
        token: widget.token,
        schoolId: schoolId,
      );

      if (!mounted) return;

      if (result['statusCode'] == 200) {
        final list =
            result['data']['faculty'] as List<dynamic>? ?? [];

        setState(() {
          facultyMembers = list
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['data']['message'] ??
              'Unable to load faculty members.';
          isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Could not connect to the server. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> addFaculty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      final result = await ApiService.addFaculty(
        token: widget.token,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
        department: _departmentController.text.trim(),
        specialization: _specializationController.text.trim(),
        schoolId: schoolId,
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      if (result['statusCode'] == 201) {
        _nameController.clear();
        _emailController.clear();
        _employeeIdController.clear();
        _departmentController.clear();
        _specializationController.clear();
        _passwordController.clear();

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty registered successfully.'),
          ),
        );

        await fetchFaculty();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['data']['message'] ??
                  'Failed to register faculty.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not connect to the server. Please try again.',
          ),
        ),
      );
    }
  }

  void showAddFacultyDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Register Faculty'),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildField(
                          _nameController,
                          'Full Name',
                          Icons.person_outline,
                        ),
                        _buildField(
                          _emailController,
                          'Email Address',
                          Icons.email_outlined,
                          isEmail: true,
                        ),
                        _buildField(
                          _employeeIdController,
                          'Employee ID',
                          Icons.badge_outlined,
                        ),
                        _buildField(
                          _departmentController,
                          'Department',
                          Icons.apartment_outlined,
                        ),
                        _buildField(
                          _specializationController,
                          'Specialization (optional)',
                          Icons.school_outlined,
                          required: false,
                        ),
                        _buildField(
                          _passwordController,
                          'Temporary Password (min. 8 characters)',
                          Icons.lock_outline,
                          obscure: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() {});
                          await addFaculty();
                          if (mounted && isSaving) {
                            setDialogState(() {});
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Register'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isEmail = false,
    bool obscure = false,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (required && text.isEmpty) {
            return 'This field is required';
          }

          if (isEmail &&
              text.isNotEmpty &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(text)) {
            return 'Enter a valid email address';
          }

          if (obscure && text.length < 8) {
            return 'Use at least 8 characters';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Management'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh faculty',
            onPressed: isLoading ? null : fetchFaculty,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27224D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register and manage faculty members for this school.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B6880),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: showAddFacultyDialog,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Register New Faculty'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Faculty Members (${facultyMembers.length})',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27224D),
                  ),
                ),
                const SizedBox(height: 14),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (errorMessage != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                      title: Text(errorMessage!),
                      trailing: IconButton(
                        onPressed: fetchFaculty,
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  )
                else if (facultyMembers.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No faculty members registered yet.',
                        ),
                      ),
                    ),
                  )
                else
                  ...facultyMembers.map((faculty) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFDDF7E8),
                          child: Icon(
                            Icons.person_outline,
                            color: Color(0xFF18794E),
                          ),
                        ),
                        title: Text(
                          faculty['name'] ?? 'Faculty',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${faculty['email'] ?? ''}\n'
                            'Employee ID: ${faculty['employeeId'] ?? ''}\n'
                            'Department: ${faculty['department'] ?? ''}'
                            '${(faculty['specialization'] ?? '').toString().isNotEmpty ? '\nSpecialization: ${faculty['specialization']}' : ''}',
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}