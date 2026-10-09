import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final String name = user['name'] ?? 'Student';
    final String email = user['email'] ?? 'Not available';
    final String enrollmentNumber =
        user['enrollmentNumber'] ?? 'Not available';
    final String branch = user['branch'] ?? 'Not available';
    final String specialization =
        user['specialization'] ?? 'Not available';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8E9FF),
              Color(0xFFF5F0FF),
              Color(0xFFE6F5FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SMARTSELECT',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                        Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // Greeting
                    Text(
                      'Hello, $name 👋',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF27224D),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Welcome back to your SmartSelect dashboard.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B6880),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Student Profile
                    _glassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Color(0xFF6366F1),
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Student Profile',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF312E5A),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              final bool isWide =
                                  constraints.maxWidth > 700;

                              return Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                children: [
                                  _profileItem(
                                    Icons.badge_outlined,
                                    'Name',
                                    name,
                                    isWide,
                                  ),
                                  _profileItem(
                                    Icons.email_outlined,
                                    'Email',
                                    email,
                                    isWide,
                                  ),
                                  _profileItem(
                                    Icons.numbers_outlined,
                                    'Enrollment Number',
                                    enrollmentNumber,
                                    isWide,
                                  ),
                                  _profileItem(
                                    Icons.school_outlined,
                                    'Branch',
                                    branch,
                                    isWide,
                                  ),
                                  _profileItem(
                                    Icons.auto_awesome_outlined,
                                    'Specialization',
                                    specialization,
                                    isWide,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Elective Selection
                    _glassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                color: Color(0xFF6366F1),
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Elective Selection',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF312E5A),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Explore and select electives available for you.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF77768A),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Search
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search electives...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9995A8),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF6366F1),
                              ),
                              filled: true,
                              fillColor:
                                  Colors.white.withValues(alpha: 0.65),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Temporary elective cards
                          Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            children: [
                              _electiveCard(
                                context,
                                'Cloud Security',
                                'CC501',
                                '3 Credits',
                              ),
                              _electiveCard(
                                context,
                                'DevOps Engineering',
                                'CC502',
                                '3 Credits',
                              ),
                              _electiveCard(
                                context,
                                'Artificial Intelligence',
                                'AI501',
                                '4 Credits',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Footer
                    const Center(
                      child: Text(
                        'SmartSelect • University Student Platform',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF77768A),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _glassCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.08),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _profileItem(
    IconData icon,
    String title,
    String value,
    bool isWide,
  ) {
    return SizedBox(
      width: isWide ? 320 : double.infinity,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6366F1),
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF858296),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF312E5A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _electiveCard(
    BuildContext context,
    String subject,
    String code,
    String credits,
  ) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(subject),
              content: Text(
                'Subject Code: $code\n'
                'Credits: $credits\n\n'
                'Detailed elective information will be available here.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.60),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              subject,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF312E5A),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              code,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF77768A),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              credits,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 15),
            const Row(
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}