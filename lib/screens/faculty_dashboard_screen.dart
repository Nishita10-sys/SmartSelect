
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FacultyDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String token;

  const FacultyDashboardScreen({
    super.key,
    required this.user,
    required this.token,
  });

  @override
  State<FacultyDashboardScreen> createState() =>
      _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState
    extends State<FacultyDashboardScreen> {
  static const Color navy = Color(0xFF27224D);
  static const Color muted = Color(0xFF6B6880);
  static const Color accent = Color(0xFF6366F1);
  static const Color pageBlue = Color(0xFFEAF4FC);

  List<Map<String, dynamic>> electives = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';

  String get facultyName =>
      widget.user['name']?.toString() ?? 'Faculty';

  String get department =>
      widget.user['department']?.toString() ?? '';

  String get specialization =>
      widget.user['specialization']?.toString() ?? '';

  String get schoolId =>
      widget.user['schoolId']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    loadElectives();
  }

  Future<void> loadElectives() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      final result = await ApiService.getMyElectives(
        token: widget.token,
      );

      if (!mounted) return;

      if (result['statusCode'] == 200) {
        final data = result['data'];
        final List<dynamic> items =
            data['electives'] as List<dynamic>? ?? [];

        setState(() {
          electives = items
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result['data']['message']?.toString() ??
                  'Could not load electives.';
          isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Unable to connect to the server. Check that your backend is running.';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredElectives {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return electives;

    return electives.where((elective) {
      final subjectName =
          elective['subjectName']?.toString().toLowerCase() ?? '';
      final subjectCode =
          elective['subjectCode']?.toString().toLowerCase() ?? '';
      final year =
          elective['academicYear']?.toString().toLowerCase() ?? '';
      final semester = elective['semester']?.toString() ?? '';
      final dept =
          elective['department']?.toString().toLowerCase() ?? '';

      return subjectName.contains(query) ||
          subjectCode.contains(query) ||
          year.contains(query) ||
          semester.contains(query) ||
          dept.contains(query);
    }).toList();
  }

  int get totalSeats => electives.fold<int>(
        0,
        (sum, item) =>
            sum + ((item['totalSeats'] as num?)?.toInt() ?? 0),
      );

  int get availableSeats => electives.fold<int>(
        0,
        (sum, item) =>
            sum + ((item['availableSeats'] as num?)?.toInt() ?? 0),
      );

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> showAddElectiveDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();
    final seatsController = TextEditingController(text: '60');

    String selectedYear = 'FY';
    int selectedSemester = 1;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Add Elective',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dialogField(
                          controller: nameController,
                          label: 'Subject Name',
                          hint: 'e.g. Cloud Computing',
                        ),
                        const SizedBox(height: 14),
                        _dialogField(
                          controller: codeController,
                          label: 'Subject Code',
                          hint: 'e.g. CSE401',
                        ),
                        const SizedBox(height: 14),
                        _dialogField(
                          controller: descriptionController,
                          label: 'Description (optional)',
                          hint: 'Describe the elective',
                          requiredField: false,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: selectedYear,
                          decoration: _inputDecoration('Academic Year'),
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
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setDialogState(
                                      () => selectedYear = value,
                                    );
                                  }
                                },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          value: selectedSemester,
                          decoration: _inputDecoration('Semester'),
                          items: List.generate(
                            8,
                            (index) => DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text('Semester ${index + 1}'),
                            ),
                          ),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setDialogState(
                                      () => selectedSemester = value,
                                    );
                                  }
                                },
                        ),
                        const SizedBox(height: 14),
                        _dialogField(
                          controller: seatsController,
                          label: 'Total Seats',
                          hint: 'e.g. 60',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pageBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Department: ${department.isEmpty ? 'Not specified' : department}\n'
                            'Specialization: ${specialization.isEmpty ? 'Not specified' : specialization}',
                            style: const TextStyle(
                              color: navy,
                              height: 1.5,
                            ),
                          ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final seats =
                              int.tryParse(seatsController.text.trim());

                          if (seats == null || seats < 1) {
                            showMessage(
                              'Enter a valid positive seat count.',
                              isError: true,
                            );
                            return;
                          }

                          setDialogState(() => isSaving = true);

                          try {
                            final result = await ApiService.addElective(
                              token: widget.token,
                              subjectName: nameController.text.trim(),
                              subjectCode: codeController.text.trim(),
                              description:
                                  descriptionController.text.trim(),
                              schoolId: schoolId,
                              department: department,
                              specialization: specialization,
                              academicYear: selectedYear,
                              semester: selectedSemester,
                              totalSeats: seats,
                            );

                            if (!mounted) return;

                            if (result['statusCode'] == 201) {
                              Navigator.pop(dialogContext);
                              showMessage(
                                result['data']['message']?.toString() ??
                                    'Elective created successfully.',
                              );
                              await loadElectives();
                            } else {
                              setDialogState(() => isSaving = false);
                              showMessage(
                                result['data']['message']?.toString() ??
                                    'Could not create elective.',
                                isError: true,
                              );
                            }
                          } catch (error) {
                            if (!mounted) return;
                            setDialogState(() => isSaving = false);
                            showMessage(
                              'Unable to connect to the backend.',
                              isError: true,
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Elective'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    seatsController.dispose();
  }

  static InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF7F9FE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDE4F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    );
  }

  static Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool requiredField = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label).copyWith(hintText: hint),
      validator: (value) {
        if (!requiredField) return null;
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  void showProfileDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Faculty Profile',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileRow('Name', facultyName),
              _profileRow(
                'Email',
                widget.user['email']?.toString() ?? 'Not provided',
              ),
              _profileRow(
                'Employee ID',
                widget.user['employeeId']?.toString() ?? 'Not provided',
              ),
              _profileRow(
                'Department',
                department.isEmpty ? 'Not provided' : department,
              ),
              _profileRow(
                'Specialization',
                specialization.isEmpty ? 'Not provided' : specialization,
              ),
              _profileRow(
                'School ID',
                schoolId.isEmpty ? 'Not provided' : schoolId,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void logout() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBlue,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'SmartSelect FACULTY',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh electives',
            onPressed: loadElectives,
            icon: const Icon(Icons.refresh, color: navy),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: showProfileDialog,
            icon: const Icon(Icons.account_circle_outlined, color: navy),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(Icons.logout, color: navy),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomePanel(),
                  const SizedBox(height: 24),
                  _buildStatistics(),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'My Electives',
                          style: TextStyle(
                            fontSize: 24,
                            color: navy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: showAddElectiveDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Elective'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Search by subject, code, year, semester...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildElectiveContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 550;

          final greeting = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FACULTY DASHBOARD',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Welcome, $facultyName!',
                style: const TextStyle(
                  color: navy,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${department.isEmpty ? 'Faculty' : department}'
                '${specialization.isEmpty ? '' : ' • $specialization'}',
                style: const TextStyle(
                  color: muted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage the electives assigned to your academic area.',
                style: TextStyle(color: muted, height: 1.5),
              ),
            ],
          );

          final icon = Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 42,
              color: accent,
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                greeting,
                const SizedBox(height: 18),
                icon,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: greeting),
              const SizedBox(width: 20),
              icon,
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 3;
        if (constraints.maxWidth < 600) {
          columns = 1;
        } else if (constraints.maxWidth < 900) {
          columns = 2;
        }

        final cards = [
          _statCard(
            'My Electives',
            electives.length.toString(),
            Icons.menu_book_outlined,
            const Color(0xFF6366F1),
          ),
          _statCard(
            'Total Seats',
            totalSeats.toString(),
            Icons.event_seat_outlined,
            const Color(0xFF0D9488),
          ),
          _statCard(
            'Available Seats',
            availableSeats.toString(),
            Icons.people_outline,
            const Color(0xFF2563EB),
          ),
        ];

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: columns == 1 ? 4.0 : 2.1,
          children: cards,
        );
      },
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectiveContent() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return _emptyPanel(
        icon: Icons.cloud_off_outlined,
        title: 'Could not load electives',
        message: errorMessage,
        buttonLabel: 'Try Again',
        onPressed: loadElectives,
      );
    }

    final items = filteredElectives;

    if (items.isEmpty) {
      return _emptyPanel(
        icon: Icons.menu_book_outlined,
        title: searchQuery.isEmpty
            ? 'No electives created yet'
            : 'No matching electives',
        message: searchQuery.isEmpty
            ? 'Add your first elective to get started.'
            : 'Try searching with a different subject name or code.',
        buttonLabel: searchQuery.isEmpty ? 'Add Elective' : 'Clear Search',
        onPressed: searchQuery.isEmpty
            ? showAddElectiveDialog
            : () => setState(() => searchQuery = ''),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 3;
        if (constraints.maxWidth < 650) {
          columns = 1;
        } else if (constraints.maxWidth < 1000) {
          columns = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: 280,
          ),
          itemBuilder: (context, index) {
            return _electiveCard(items[index]);
          },
        );
      },
    );
  }

  Widget _emptyPanel({
    required IconData icon,
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: accent),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: navy,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  Widget _electiveCard(Map<String, dynamic> elective) {
    final subjectName =
        elective['subjectName']?.toString() ?? 'Untitled Elective';
    final subjectCode =
        elective['subjectCode']?.toString() ?? '';
    final year = elective['academicYear']?.toString() ?? '';
    final semester = elective['semester']?.toString() ?? '';
    final description =
        elective['description']?.toString() ?? '';
    final seats =
        (elective['totalSeats'] as num?)?.toInt() ?? 0;
    final available =
        (elective['availableSeats'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: accent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subjectCode,
                  style: const TextStyle(
                    color: Color(0xFF147D52),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            subjectName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$year • Semester $semester',
            style: const TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              description.isEmpty
                  ? 'No description provided.'
                  : description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: muted,
                height: 1.4,
              ),
            ),
          ),
          const Divider(),
          Row(
            children: [
              const Icon(
                Icons.event_seat_outlined,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '$available available / $seats seats',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
