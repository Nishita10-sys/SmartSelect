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

  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();

}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  static const Color navy = Color(0xFF27224D);

  static const Color muted = Color(0xFF6B6880);

  static const Color accent = Color(0xFF6366F1);

  static const Color pageBlue = Color(0xFFEAF4FC);

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> schools = [];
  List<Map<String, dynamic>> schoolStats = [];
  int totalSchoolsCount = 0;
  int totalFaculty = 0;
  int totalElectives = 0;
  bool statsAvailable = false;

  bool isLoading = true;

  String? errorMessage;

  String searchQuery = '';

  @override

  void initState() {

    super.initState();

    fetchSchools();

  }

  @override

  void dispose() {

    searchController.dispose();

    super.dispose();

  }

  Future<void> fetchSchools() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getSchools(token: widget.token),
        ApiService.getDashboardStats(token: widget.token),
      ]);
      if (!mounted) return;

      final schoolsResult = results[0];
      final statsResult = results[1];

      if (schoolsResult['statusCode'] != 200) {
        final data = schoolsResult['data'];
        setState(() {
          errorMessage = data is Map
              ? (data['message']?.toString() ?? 'Unable to load schools.')
              : 'Unable to load schools.';
          isLoading = false;
        });
        return;
      }

      final schoolsData = schoolsResult['data'];
      final schoolList = schoolsData is Map
          ? (schoolsData['schools'] as List<dynamic>? ?? [])
          : <dynamic>[];
      final loadedSchools = schoolList
          .whereType<Map>()
          .map((school) => Map<String, dynamic>.from(school))
          .toList();

      var loadedSchoolStats = <Map<String, dynamic>>[];
      var loadedTotalSchools = loadedSchools.length;
      var loadedTotalFaculty = 0;
      var loadedTotalElectives = 0;
      var loadedStatsAvailable = false;

      if (statsResult['statusCode'] == 200) {
        loadedStatsAvailable = true;
        final rawStats = statsResult['data'];
        if (rawStats is Map) {
          final statsData = rawStats['stats'] is Map
              ? Map<String, dynamic>.from(rawStats['stats'] as Map)
              : Map<String, dynamic>.from(rawStats);
          final rawSchoolStats = statsData['schools'] ??
              statsData['schoolStats'] ??
              statsData['perSchool'];

          if (rawSchoolStats is List) {
            loadedSchoolStats = rawSchoolStats
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }

          loadedTotalSchools = _readCount(statsData['totalSchools']);
          if (statsData['totalSchools'] == null) {
            loadedTotalSchools = loadedSchools.length;
          }
          loadedTotalFaculty = _readCount(statsData['totalFaculty']);
          loadedTotalElectives = _readCount(statsData['totalElectives']);

          if (statsData['totalFaculty'] == null) {
            loadedTotalFaculty = loadedSchoolStats.fold<int>(
              0,
              (sum, item) => sum + _readCount(item['facultyCount']),
            );
          }
          if (statsData['totalElectives'] == null) {
            loadedTotalElectives = loadedSchoolStats.fold<int>(
              0,
              (sum, item) => sum + _readCount(item['electiveCount']),
            );
          }
        }
      }

      setState(() {
        schools = loadedSchools;
        schoolStats = loadedSchoolStats;
        totalSchoolsCount = loadedTotalSchools;
        totalFaculty = loadedTotalFaculty;
        totalElectives = loadedTotalElectives;
        statsAvailable = loadedStatsAvailable;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Could not connect to the server. Please try again.';
        isLoading = false;
      });
    }
  }

  int _readCount(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic>? _statsForSchool(Map<String, dynamic> school) {
    final schoolId = (school['_id'] ?? school['id'] ?? school['schoolId'])
        ?.toString();
    final schoolName = school['name']?.toString().trim().toLowerCase();

    for (final stats in schoolStats) {
      final statsSchoolId =
          (stats['schoolId'] ?? stats['_id'] ?? stats['id'])?.toString();
      final statsSchoolName = stats['name']?.toString().trim().toLowerCase();
      if ((schoolId != null && statsSchoolId == schoolId) ||
          (schoolName != null && schoolName.isNotEmpty &&
              statsSchoolName == schoolName)) {
        return stats;
      }
    }
    return null;
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

      builder: (dialogContext) => AlertDialog(

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: const Row(

          children: [

            Icon(Icons.account_circle_outlined, color: accent, size: 28),

            SizedBox(width: 10),

            Text('Admin Profile'),

          ],

        ),

        content: Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            _profileRow(Icons.person_outline, 'Name', '$name'),

            const SizedBox(height: 14),

            _profileRow(Icons.email_outlined, 'Email', '$email'),

            const SizedBox(height: 14),

            _profileRow(Icons.verified_user_outlined, 'Role', 'Administrator'),

          ],

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(dialogContext),

            child: const Text('Close'),

          ),

        ],

      ),

    );

  }

  Widget _profileRow(IconData icon, String label, String value) {

    return Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Icon(icon, size: 20, color: accent),

        const SizedBox(width: 10),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(label, style: const TextStyle(fontSize: 12, color: muted)),

              const SizedBox(height: 3),

              Text(

                value,

                style: const TextStyle(

                  color: navy,

                  fontWeight: FontWeight.w600,

                ),

              ),

            ],

          ),

        ),

      ],

    );

  }

  void logout() {

    Navigator.of(context).popUntil((route) => route.isFirst);

  }

  @override

  Widget build(BuildContext context) {

    final name = widget.user['name']?.toString() ?? 'Administrator';

    final email = widget.user['email']?.toString() ?? '';

    final filteredSchools = schools.where((school) {

      final schoolName = (school['name'] ?? '').toString().toLowerCase();

      final description =

          (school['description'] ?? '').toString().toLowerCase();

      final query = searchQuery.toLowerCase().trim();

      return schoolName.contains(query) || description.contains(query);

    }).toList();

    return Scaffold(

      backgroundColor: pageBlue,

      appBar: AppBar(

        automaticallyImplyLeading: false,

        elevation: 0,

        backgroundColor: const Color(0xFF9CCBEA),

        foregroundColor: navy,

        titleSpacing: 24,

        title: const Row(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(Icons.school_outlined, size: 29),

            SizedBox(width: 10),

            Text(

              'SmartSelect',

              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: .2),

            ),

            SizedBox(width: 8),

            Text(

              'ADMIN',

              style: TextStyle(

                fontSize: 11,

                letterSpacing: 1.4,

                fontWeight: FontWeight.w700,

              ),

            ),

          ],

        ),

        actions: [

          IconButton(

            tooltip: 'Refresh schools',

            onPressed: isLoading ? null : fetchSchools,

            icon: const Icon(Icons.refresh_rounded),

          ),

          IconButton(

            tooltip: 'Admin profile',

            onPressed: showAdminProfile,

            icon: const Icon(Icons.account_circle_outlined),

          ),

          IconButton(

            tooltip: 'Logout',

            onPressed: logout,

            icon: const Icon(Icons.logout_rounded),

          ),

          const SizedBox(width: 12),

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

            child: Center(

              child: ConstrainedBox(

                constraints: const BoxConstraints(maxWidth: 1400),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    _welcomePanel(name, email),

                    const SizedBox(height: 24),

                    LayoutBuilder(

                      builder: (context, constraints) {

                        final columns = constraints.maxWidth >= 900

                            ? 3

                            : constraints.maxWidth >= 560

                                ? 2

                                : 1;

                        return GridView.count(

                          crossAxisCount: columns,

                          shrinkWrap: true,

                          physics: const NeverScrollableScrollPhysics(),

                          crossAxisSpacing: 16,

                          mainAxisSpacing: 16,

                          childAspectRatio: columns == 1 ? 4.2 : 2.5,

                          children: [

                            _summaryCard(

                              icon: Icons.account_balance_outlined,

                              title: 'Schools',

                              value: isLoading ? '—' : '$totalSchoolsCount',

                              subtitle: 'Available schools',

                              iconColor: const Color(0xFF5368C5),

                            ),

                            _summaryCard(

                              icon: Icons.groups_2_outlined,

                              title: 'Faculty',
                              value: isLoading || !statsAvailable ? '—' : '$totalFaculty',
                              subtitle: 'Across all schools',

                              iconColor: const Color(0xFF3A86A8),

                            ),

                            _summaryCard(

                              icon: Icons.menu_book_outlined,

                              title: 'Electives',
                              value: isLoading || !statsAvailable ? '—' : '$totalElectives',
                              subtitle: 'Across all schools',

                              iconColor: const Color(0xFF6477D8),

                            ),

                          ],

                        );

                      },

                    ),

                    const SizedBox(height: 30),

                    Row(

                      children: [

                        Container(

                          width: 5,

                          height: 30,

                          decoration: BoxDecoration(

                            color: accent,

                            borderRadius: BorderRadius.circular(8),

                          ),

                        ),

                        const SizedBox(width: 12),

                        const Expanded(

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(

                                'Manage Schools',

                                style: TextStyle(

                                  fontSize: 23,

                                  fontWeight: FontWeight.bold,

                                  color: navy,

                                ),

                              ),

                              SizedBox(height: 4),

                              Text(

                                'Choose a school to manage faculty and electives.',

                                style: TextStyle(color: muted, fontSize: 14),

                              ),

                            ],

                          ),

                        ),

                        if (!isLoading && errorMessage == null)

                          Text(

                            '${schools.length} ${schools.length == 1 ? 'school' : 'schools'}',

                            style: const TextStyle(

                              color: navy,

                              fontWeight: FontWeight.w600,

                            ),

                          ),

                      ],

                    ),

                    const SizedBox(height: 18),

                    TextField(

                      controller: searchController,

                      onChanged: (value) => setState(() => searchQuery = value),

                      decoration: InputDecoration(

                        hintText: 'Search schools...',

                        prefixIcon: const Icon(Icons.search_rounded),

                        suffixIcon: searchQuery.isNotEmpty

                            ? IconButton(

                                tooltip: 'Clear search',

                                onPressed: () {

                                  searchController.clear();

                                  setState(() => searchQuery = '');

                                },

                                icon: const Icon(Icons.close_rounded),

                              )

                            : null,

                        filled: true,

                        fillColor: const Color(0xFFF8FBFF),

                        contentPadding: const EdgeInsets.symmetric(

                          vertical: 16,

                          horizontal: 18,

                        ),

                        border: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(15),

                          borderSide: BorderSide.none,

                        ),

                        enabledBorder: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(15),

                          borderSide: const BorderSide(

                            color: Color(0xFFD7E6F4),

                          ),

                        ),

                        focusedBorder: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(15),

                          borderSide: const BorderSide(

                            color: accent,

                            width: 1.5,

                          ),

                        ),

                      ),

                    ),

                    const SizedBox(height: 20),

                    if (isLoading)

                      const Center(

                        child: Padding(

                          padding: EdgeInsets.all(40),

                          child: CircularProgressIndicator(color: accent),

                        ),

                      )

                    else if (errorMessage != null)

                      _messageCard(

                        icon: Icons.error_outline_rounded,

                        iconColor: const Color(0xFFEF4444),

                        message: errorMessage!,

                        buttonLabel: 'Try Again',

                        onPressed: fetchSchools,

                      )

                    else if (filteredSchools.isEmpty)

                      _messageCard(

                        icon: Icons.search_off_rounded,

                        iconColor: accent,

                        message: schools.isEmpty

                            ? 'No active schools found.'

                            : 'No schools match "$searchQuery".',

                      )

                    else

                      LayoutBuilder(

                        builder: (context, constraints) {

                          final columns = constraints.maxWidth >= 1000

                              ? 3

                              : constraints.maxWidth >= 620

                                  ? 2

                                  : 1;

                          return GridView.builder(

                            shrinkWrap: true,

                            physics: const NeverScrollableScrollPhysics(),

                            itemCount: filteredSchools.length,

                            gridDelegate:

                                SliverGridDelegateWithFixedCrossAxisCount(

                              crossAxisCount: columns,

                              crossAxisSpacing: 18,

                              mainAxisSpacing: 18,

                              mainAxisExtent: 220,

                            ),

                            itemBuilder: (context, index) {

                              final school = filteredSchools[index];

                              return _schoolCard(school, index);

                            },

                          );

                        },

                      ),

                    const SizedBox(height: 24),

                    Card(

                      elevation: 2,

                      shadowColor: navy.withValues(alpha: .08),

                      color: const Color(0xFFF5F7FD),

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(18),

                      ),

                      child: ListTile(

                        contentPadding: const EdgeInsets.symmetric(

                          horizontal: 20,

                          vertical: 10,

                        ),

                        leading: Container(

                          width: 48,

                          height: 48,

                          decoration: BoxDecoration(

                            color: const Color(0xFFE3E7FF),

                            borderRadius: BorderRadius.circular(14),

                          ),

                          child: const Icon(

                            Icons.manage_accounts_outlined,

                            color: accent,

                            size: 29,

                          ),

                        ),

                        title: const Text(

                          'Admin Profile',

                          style: TextStyle(

                            color: navy,

                            fontWeight: FontWeight.w700,

                          ),

                        ),

                        subtitle: Text(

                          email.isEmpty ? 'View your account information' : email,

                          style: const TextStyle(color: muted),

                        ),

                        trailing: const Icon(

                          Icons.arrow_forward_ios_rounded,

                          size: 18,

                          color: muted,

                        ),

                        onTap: showAdminProfile,

                      ),

                    ),

                  ],

                ),

              ),

            ),

          ),

        ),

      ),

    );

  }

  Widget _welcomePanel(String name, String email) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(26),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(22),

        gradient: const LinearGradient(

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [

            Color(0xFFF7FAFF),

            Color(0xFFEAF3FC),

          ],

        ),

        border: Border.all(color: Colors.white.withValues(alpha: .8)),

        boxShadow: [

          BoxShadow(

            color: navy.withValues(alpha: .07),

            blurRadius: 18,

            offset: const Offset(0, 7),

          ),

        ],

      ),

      child: LayoutBuilder(

        builder: (context, constraints) {

          final compact = constraints.maxWidth < 520;

          final textBlock = Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Container(

                padding: const EdgeInsets.symmetric(

                  horizontal: 12,

                  vertical: 6,

                ),

                decoration: BoxDecoration(

                  color: const Color(0xFFE4E9FF),

                  borderRadius: BorderRadius.circular(30),

                ),

                child: const Text(

                  'ADMINISTRATOR PORTAL',

                  style: TextStyle(

                    color: accent,

                    fontSize: 11,

                    fontWeight: FontWeight.w800,

                    letterSpacing: 1.1,

                  ),

                ),

              ),

              const SizedBox(height: 16),

              Text(

                'Welcome, $name!',

                style: const TextStyle(

                  fontSize: 28,

                  height: 1.2,

                  fontWeight: FontWeight.bold,

                  color: navy,

                ),

              ),

              const SizedBox(height: 8),

              Text(

                email,

                style: const TextStyle(fontSize: 15, color: muted),

              ),

              const SizedBox(height: 12),

              const Text(

                'Manage your schools, faculty, and elective offerings from one place.',

                style: TextStyle(fontSize: 14, color: muted, height: 1.5),

              ),

            ],

          );

          final illustration = Container(

            width: 104,

            height: 104,

            decoration: BoxDecoration(

              color: const Color(0xFFDDEBFA),

              borderRadius: BorderRadius.circular(26),

            ),

            child: const Icon(

              Icons.account_balance_outlined,

              size: 56,

              color: Color(0xFF5368C5),

            ),

          );

          if (compact) {

            return Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                textBlock,

                const SizedBox(height: 18),

                Align(alignment: Alignment.centerRight, child: illustration),

              ],

            );

          }

          return Row(

            children: [

              Expanded(child: textBlock),

              const SizedBox(width: 24),

              illustration,

            ],

          );

        },

      ),

    );

  }

  Widget _summaryCard({

    required IconData icon,

    required String title,

    required String value,

    required String subtitle,

    required Color iconColor,

  }) {

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: const Color(0xFFF8FBFF),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFDDEAF6)),

        boxShadow: [

          BoxShadow(

            color: navy.withValues(alpha: .05),

            blurRadius: 12,

            offset: const Offset(0, 4),

          ),

        ],

      ),

      child: Row(

        children: [

          Container(

            width: 50,

            height: 50,

            decoration: BoxDecoration(

              color: iconColor.withValues(alpha: .12),

              borderRadius: BorderRadius.circular(15),

            ),

            child: Icon(icon, color: iconColor, size: 27),

          ),

          const SizedBox(width: 14),

          Expanded(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(title, style: const TextStyle(color: muted, fontSize: 13)),

                const SizedBox(height: 3),

                Text(

                  value,

                  style: const TextStyle(

                    color: navy,

                    fontSize: 22,

                    fontWeight: FontWeight.bold,

                  ),

                ),

                Text(

                  subtitle,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(color: muted, fontSize: 11),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  Widget _schoolCard(Map<String, dynamic> school, int index) {

    const colors = [

      Color(0xFF5368C5),

      Color(0xFF3A86A8),

      Color(0xFF6477D8),

      Color(0xFF4B8B83),

    ];

    const icons = [

      Icons.computer_outlined,

      Icons.theater_comedy_outlined,

      Icons.engineering_outlined,

      Icons.science_outlined,

    ];

    final color = colors[index % colors.length];

    return Card(

      elevation: 3,

      shadowColor: navy.withValues(alpha: .08),

      color: const Color(0xFFF8FBFF),

      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: InkWell(

        onTap: () => openSchool(school),

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(

                children: [

                  Container(

                    width: 48,

                    height: 48,

                    decoration: BoxDecoration(

                      color: color.withValues(alpha: .12),

                      borderRadius: BorderRadius.circular(14),

                    ),

                    child: Icon(icons[index % icons.length], color: color, size: 27),

                  ),

                  const Spacer(),

                  const Icon(

                    Icons.arrow_outward_rounded,

                    color: muted,

                    size: 20,

                  ),

                ],

              ),

              const Spacer(),

              Text(

                school['name']?.toString() ?? 'School',

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(

                  fontSize: 17,

                  fontWeight: FontWeight.bold,

                  color: navy,

                ),

              ),

              const SizedBox(height: 6),

              Text(

                (school['description']?.toString().trim().isNotEmpty ?? false)

                    ? school['description'].toString()

                    : 'Manage faculty and electives',

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(

                  fontSize: 12,

                  height: 1.35,

                  color: muted,

                ),

              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final stats = _statsForSchool(school);
                  final facultyCount = stats == null || !statsAvailable
                      ? '—'
                      : '${_readCount(stats['facultyCount'])}';
                  final electiveCount = stats == null || !statsAvailable
                      ? '—'
                      : '${_readCount(stats['electiveCount'])}';
                  return Row(
                    children: [
                      Expanded(
                        child: _schoolCountChip(
                          Icons.groups_2_outlined,
                          '$facultyCount Faculty',
                          color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _schoolCountChip(
                          Icons.menu_book_outlined,
                          '$electiveCount Electives',
                          color,
                        ),
                      ),
                    ],
                  );
                },
              ),

            ],

          ),

        ),

      ),

    );

  }

  Widget _schoolCountChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard({

    required IconData icon,

    required Color iconColor,

    required String message,

    String? buttonLabel,

    VoidCallback? onPressed,

  }) {

    return Container(

      width: double.infinity,

      constraints: const BoxConstraints(maxWidth: 520),

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        color: const Color(0xFFF5F6FC),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white, width: 1.2),

        boxShadow: [

          BoxShadow(

            color: navy.withValues(alpha: .07),

            blurRadius: 10,

            offset: const Offset(0, 4),

          ),

        ],

      ),

      child: Column(

        children: [

          Icon(icon, color: iconColor, size: 38),

          const SizedBox(height: 12),

          Text(

            message,

            textAlign: TextAlign.center,

            style: const TextStyle(color: Color(0xFF343443), fontSize: 14),

          ),

          if (buttonLabel != null && onPressed != null) ...[

            const SizedBox(height: 16),

            OutlinedButton.icon(

              onPressed: onPressed,

              icon: const Icon(Icons.refresh_rounded, size: 18),

              label: Text(buttonLabel),

              style: OutlinedButton.styleFrom(

                foregroundColor: const Color(0xFF42669A),

                side: const BorderSide(color: Color(0xFFD6DCE8)),

                shape: const StadiumBorder(),

                padding: const EdgeInsets.symmetric(

                  horizontal: 20,

                  vertical: 12,

                ),

              ),

            ),

          ],

        ],

      ),

    );

  }

}
