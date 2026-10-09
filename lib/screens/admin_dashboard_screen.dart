
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'school_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String token;

  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.token,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> schools = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getSchools(
        token: widget.token,
      );

      if (!mounted) return;

      if (result['statusCode'] == 200) {
        final data = result['data'];
        final schoolList = data['schools'] as List<dynamic>? ?? [];

        setState(() {
          schools = schoolList
              .map((school) => Map<String, dynamic>.from(school))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              result['data']['message'] ?? 'Unable to load schools.';
          isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Could not connect to the server. Please try again.';
        isLoading = false;
      });
    }
  }

  
void openSchool(Map<String, dynamic> school) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SchoolManagementScreen(
        school: school,
        user: widget.user,
        token: widget.token,
      ),
    ),
  );
}

  void showAdminProfile() {
    final name = widget.user['name'] ?? 'Administrator';
    final email = widget.user['email'] ?? '';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Profile'),
        content: Text(
          'Name: $name\nEmail: $email\nRole: Admin',
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

  @override
  Widget build(BuildContext context) {
    final name = widget.user['name'] ?? 'Administrator';
    final email = widget.user['email'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartSelect Admin'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Refresh schools',
            icon: const Icon(Icons.refresh),
            onPressed: fetchSchools,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            },
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
                  'Welcome, $name!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27224D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B6880),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Manage Schools',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27224D),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select a school to manage its faculty and electives.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B6880),
                  ),
                ),
                const SizedBox(height: 18),

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (errorMessage != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: fetchSchools,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (schools.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text('No active schools found.'),
                      ),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          constraints.maxWidth >= 900 ? 3 :
                          constraints.maxWidth >= 550 ? 2 : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: schools.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 150,
                        ),
                        itemBuilder: (context, index) {
                          final school = schools[index];
                          final colors = [
                            const Color(0xFF4359B8),
                            const Color(0xFFBE185D),
                            const Color(0xFF0369A1),
                            const Color(0xFF15803D),
                          ];
                          final icons = [
                            Icons.computer_outlined,
                            Icons.theater_comedy_outlined,
                            Icons.engineering_outlined,
                            Icons.science_outlined,
                          ];

                          return Card(
                            elevation: 3,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () => openSchool(school),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      icons[index % icons.length],
                                      color:
                                          colors[index % colors.length],
                                      size: 30,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      school['name'] ?? 'School',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF27224D),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Manage faculty and electives',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B6880),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_circle_outlined,
                      color: Color(0xFF6366F1),
                      size: 32,
                    ),
                    title: const Text('Admin Profile'),
                    subtitle: const Text(
                      'View your account information',
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios),
                    onTap: showAdminProfile,
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