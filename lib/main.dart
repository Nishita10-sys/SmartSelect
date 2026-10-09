import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SmartSelectApp());
}

class SmartSelectApp extends StatelessWidget {
  const SmartSelectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartSelect',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF7FBFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
        ),
      ),
      home: const SmartSelectHome(),
    );
  }
}

class SmartSelectHome extends StatefulWidget {
  const SmartSelectHome({super.key});

  @override
  State<SmartSelectHome> createState() => _SmartSelectHomeState();
}

class _SmartSelectHomeState extends State<SmartSelectHome>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey discoverKey = GlobalKey();
  final GlobalKey campusKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  late AnimationController _heroController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color darkBlue = Color(0xFF12304A);
  static const Color lightBlue = Color(0xFFEAF5FF);
  static const Color background = Color(0xFFF7FBFF);
  static const Color textGrey = Color(0xFF607D94);
//s
  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: Curves.easeOutCubic,
      ),
    );

    _heroController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  void openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  void scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;

    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void goHome() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildNavbar(),
              _buildHero(),
              _buildDiscover(),
              _buildCampus(),
              _buildAbout(),
              _buildContact(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVBAR
  // ============================================================

  Widget _buildNavbar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE4EEF6),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 13,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;

              return Row(
                children: [
                  GestureDetector(
                    onTap: goHome,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        const SizedBox(width: 11),
                        Text(
                            'SmartSelect',
                            style: GoogleFonts.cinzelDecorative(
                            color: Color.fromARGB(255, 46, 83, 101),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                            ),
                          ),


                      ],
                    ),
                  ),

                  const Spacer(),

                  if (!isMobile)
                    Row(
                      children: [
                        _navButton('Discover', () {
                          scrollTo(discoverKey);
                        }),
                        _navButton('Campus', () {
                          scrollTo(campusKey);
                        }),
                        _navButton('About', () {
                          scrollTo(aboutKey);
                        }),
                        _navButton('Contact', () {
                          scrollTo(contactKey);
                        }),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: openLogin,
                          style: TextButton.styleFrom(
                            foregroundColor: darkBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: openSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 19,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: darkBlue,
                        size: 28,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'discover':
                            scrollTo(discoverKey);
                            break;
                          case 'campus':
                            scrollTo(campusKey);
                            break;
                          case 'about':
                            scrollTo(aboutKey);
                            break;
                          case 'contact':
                            scrollTo(contactKey);
                            break;
                          case 'login':
                            openLogin();
                            break;
                          case 'signup':
                            openSignup();
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'discover',
                            child: Text('Discover'),
                          ),
                          PopupMenuItem(
                            value: 'campus',
                            child: Text('Campus'),
                          ),
                          PopupMenuItem(
                            value: 'about',
                            child: Text('About'),
                          ),
                          PopupMenuItem(
                            value: 'contact',
                            child: Text('Contact'),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'login',
                            child: Text('Login'),
                          ),
                          PopupMenuItem(
                            value: 'signup',
                            child: Text('Create Account'),
                          ),
                        ];
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _navButton(
    String title,
    VoidCallback onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textGrey,
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 620,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(182, 76, 158, 221),
            Color(0xFFEAF6FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -70,
            child: _backgroundCircle(
              280,
              const Color.fromARGB(230, 78, 163, 237),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -100,
            child: _backgroundCircle(
              300,
              const Color(0xFFD6EDFF),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 80,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _animatedLogo(),

                      const SizedBox(height: 28),

                                        LayoutBuilder(
                    builder: (context, constraints) {
                      double fontSize = 40;

                      if (constraints.maxWidth < 400) {
                        fontSize = 30;
                      } else if (constraints.maxWidth < 600) {
                        fontSize = 35;
                      }

                      return Text(
                        'SmartSelect',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzelDecorative(
                          color: const Color.fromARGB(225, 25, 53, 67),
                          fontSize: fontSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      );
                    },
                  ),

                      //const SizedBox(height: 2),

                        Text(
                        'Your Campus . Your Choice . Your Move.',
                        textAlign: TextAlign.center,
                        style:GoogleFonts.firaSans(
                          color: Color.fromARGB(255, 28, 50, 73),
                          fontSize: 23,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 40),

                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 680,
                        ),
                        child:Text(
                          'Smart Select brings elective management to your fingertips. Explore diverse subjects, '
                          'receive AI-driven recommendations, and manage your academic journey '
                          'with ease — all in one place.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color.fromARGB(195, 0, 0, 0),
                            fontSize: 18,
                            height: 1.7,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: openSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              scrollTo(discoverKey);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: darkBlue,
                              side: const BorderSide(
                                color: Color(0xFFBBD6EA),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            child: const Text(
                              'Discover',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 34),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            color: primaryBlue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Built for MIT Art, Design & Technology University',
                            style: TextStyle(
                              color: darkBlue.withOpacity(0.65),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundCircle(
    double size,
    Color color,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.35),
      ),
    );
  }

  Widget _animatedLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0.85,
        end: 1.0,
      ),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 250,
        height: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(228, 255, 255, 255),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color.fromARGB(207, 255, 255, 255),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.12),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Image.asset(
          'web/icons/mit_adt_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const Icon(
              Icons.school_rounded,
              color: primaryBlue,
              size: 50,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // DISCOVER
  // ============================================================

  Widget _buildDiscover() {
    return Container(
      key: discoverKey,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),
          child: Column(
            children: [
              _sectionHeading(
                'DISCOVER',
                'Everything in one place.',
                'Select elective subjects, explore resources and experience campus '
                    'without switching between different platforms.',
              ),

              const SizedBox(height: 55),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 750;

                  final cards = [
                    _infoCard(
                      Icons.explore_rounded,
                      'Select Electives',
                      'Apply for the elective subjects which are '
                          'relevant with your domain & part of academics.',
                    ),
                    _infoCard(
                      Icons.menu_book_rounded,
                      'AI Driven Recommendations',
                      'Take help of AI to choose the correct elective by '
                          'analyzing your domain and academic profile.',
                    ),
                    _infoCard(
                      Icons.event_available_rounded,
                      'Be in touch',
                      'Stay updated on elective selection, track your chosen subjects  '
                          'through a dashboard, and explore campus.',
                    ),
                  ];

                  if (isMobile) {
                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 18),
                        cards[1],
                        const SizedBox(height: 18),
                        cards[2],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 18),
                      Expanded(child: cards[1]),
                      const SizedBox(width: 18),
                      Expanded(child: cards[2]),
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

  Widget _infoCard(
    IconData icon,
    String title,
    String description,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FCFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFDCEBF6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: primaryBlue,
                size: 25,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              title,
              style: const TextStyle(
                color: darkBlue,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              description,
              style: const TextStyle(
                color: textGrey,
                fontSize: 13,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CAMPUS
  // ============================================================

  Widget _buildCampus() {
    return Container(
      key: campusKey,
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 95,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 800;

              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CAMPUS',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Stay connected\nwith campus life.',
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 40,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'SmartSelect creates a simpler way for students '
                    'to discover what is happening around their campus '
                    'and stay connected with useful opportunities.',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _checkItem('Student-focused experience'),
                  _checkItem('Opportunities and resources'),
                  _checkItem('Simple web-based platform'),
                ],
              );

              final visual = Container(
                height: 330,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF64B5F6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -45,
                      top: -50,
                      child: _glassCircle(170),
                    ),
                    Positioned(
                      left: -60,
                      bottom: -60,
                      child: _glassCircle(200),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'MIT ADT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'Connect • Discover • Grow',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (isMobile) {
                return Column(
                  children: [
                    content,
                    const SizedBox(height: 45),
                    visual,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 70),
                  Expanded(child: visual),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _glassCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
      ),
    );
  }

  Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: primaryBlue,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: darkBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  Widget _buildAbout() {
    return Container(
      key: aboutKey,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 95,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 850,
          ),
          child: Column(
            children: [
              const Text(
                'ABOUT SMARTSELECT',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Built around student life.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'SmartSelect is a student-focused digital platform '
                'designed to bring useful campus experiences together '
                'through a modern, simple and accessible web experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textGrey,
                  fontSize: 15,
                  height: 1.75,
                ),
              ),

              const SizedBox(height: 35),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFD7EAF7),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'web/icons/mit_adt_logo.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.school_rounded,
                          color: primaryBlue,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'For students at MIT ADT University',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTACT
  // ============================================================

  Widget _buildContact() {
    return Container(
      key: contactKey,
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 90,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1050,
          ),
          child: Container(
            padding: const EdgeInsets.all(45),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFFDDEBF5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;

                final heading = const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTACT',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Have a question?',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Get started with SmartSelect and explore '
                      'your campus experience.',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                );

                final button = ElevatedButton(
                  onPressed: openSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );

                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading,
                      const SizedBox(height: 25),
                      button,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: heading),
                    const SizedBox(width: 30),
                    button,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: darkBlue,
      padding: const EdgeInsets.symmetric(
        horizontal: 35,
        vertical: 30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;

              final brand = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'web/icons/mit_adt_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SmartSelect',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'MIT ADT Student Platform',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              );

              const copyright = Text(
                'Built for students • © 2026 SmartSelect',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    brand,
                    const SizedBox(height: 20),
                    copyright,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: brand),
                  copyright,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _sectionHeading(
    String eyebrow,
    String title,
    String subtitle,
  ) {
    return Column(
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: primaryBlue,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: darkBlue,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 12),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 650,
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textGrey,
              fontSize: 15,
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }
}