
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ElectiveManagementScreen extends StatefulWidget {
  final Map<String, dynamic> school;
  final Map<String, dynamic> user;
  final String token;

  const ElectiveManagementScreen({
    super.key,
    required this.school,
    required this.user,
    required this.token,
  });

  @override
  State<ElectiveManagementScreen> createState() =>
      _ElectiveManagementScreenState();
}

class _ElectiveManagementScreenState
    extends State<ElectiveManagementScreen> {
  List<Map<String, dynamic>> electives = [];
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _specializationController = TextEditingController();
  final _seatsController = TextEditingController(text: '60');

  String academicYear = 'FY';
  int semester = 1;

  String get schoolName => widget.school['name'] ?? 'School';

  String get schoolId => widget.school['_id']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    fetchElectives();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    _specializationController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> fetchElectives() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getElectives(
        token: widget.token,
        schoolId: schoolId,
      );

      if (!mounted) return;

      if (result['statusCode'] == 200) {
        final list =
            result['data']['electives'] as List<dynamic>? ?? [];

        setState(() {
          electives = list
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['data']['message'] ??
              'Unable to load electives.';
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

  Future<void> addElective() async {
    if (!_formKey.currentState!.validate()) return;

    final seats = int.tryParse(_seatsController.text.trim());

    if (seats == null || seats < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid number of seats.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final result = await ApiService.addElective(
        token: widget.token,
        subjectName: _nameController.text.trim(),
        subjectCode: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        schoolId: schoolId,
        department: _departmentController.text.trim(),
        specialization: _specializationController.text.trim(),
        academicYear: academicYear,
        semester: semester,
        totalSeats: seats,
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      if (result['statusCode'] == 201) {
        Navigator.of(context).pop();

        _nameController.clear();
        _codeController.clear();
        _descriptionController.clear();
        _departmentController.clear();
        _specializationController.clear();
        _seatsController.text = '60';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Elective added successfully.'),
          ),
        );

        await fetchElectives();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['data']['message'] ??
                  'Failed to add elective.',
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

  void showAddElectiveDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Elective'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildField(
                          _nameController,
                          'Subject Name',
                          Icons.menu_book_outlined,
                        ),
                        _buildField(
                          _codeController,
                          'Subject Code',
                          Icons.tag,
                        ),
                        _buildField(
                          _descriptionController,
                          'Description (optional)',
                          Icons.description_outlined,
                          required: false,
                          maxLines: 3,
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
                        DropdownButtonFormField<String>(
                          value: academicYear,
                          decoration: const InputDecoration(
                            labelText: 'Academic Year',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'FY',
                              child: Text('First Year (FY)'),
                            ),
                            DropdownMenuItem(
                              value: 'SY',
                              child: Text('Second Year (SY)'),
                            ),
                            DropdownMenuItem(
                              value: 'TY',
                              child: Text('Third Year (TY)'),
                            ),
                            DropdownMenuItem(
                              value: 'LY',
                              child: Text('Last Year (LY)'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                academicYear = value;
                              });
                              setState(() {
                                academicYear = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          value: semester,
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(
                            8,
                            (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text('Semester ${index + 1}'),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                semester = value;
                              });
                              setState(() {
                                semester = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          _seatsController,
                          'Total Seats',
                          Icons.event_seat_outlined,
                          isNumber: true,
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
                          await addElective();
                          if (mounted) {
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
                      : const Text('Save Elective'),
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
    bool required = true,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber
            ? TextInputType.number
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

          if (isNumber &&
              text.isNotEmpty &&
              (int.tryParse(text) == null ||
                  int.parse(text) < 1)) {
            return 'Enter a positive whole number';
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
        title: const Text('Elective Management'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh electives',
            onPressed: isLoading ? null : fetchElectives,
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
                  'Create and view elective subjects for this school.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B6880),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: showAddElectiveDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Elective'),
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
                  'Electives (${electives.length})',
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
                        onPressed: fetchElectives,
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  )
                else if (electives.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('No electives added yet.'),
                      ),
                    ),
                  )
                else
                  ...electives.map((elective) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF1E8FF),
                          child: Icon(
                            Icons.menu_book_outlined,
                            color: Color(0xFF7746C8),
                          ),
                        ),
                        title: Text(
                          elective['subjectName'] ?? 'Elective',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Code: ${elective['subjectCode'] ?? ''}\n'
                            'Year: ${elective['academicYear'] ?? ''} · '
                            'Semester: ${elective['semester'] ?? ''}\n'
                            'Department: ${elective['department'] ?? ''}\n'
                            'Seats available: ${elective['availableSeats'] ?? 0}'
                            ' / ${elective['totalSeats'] ?? 0}'
                            '${(elective['description'] ?? '').toString().isNotEmpty ? '\n${elective['description']}' : ''}',
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