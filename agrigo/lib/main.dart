import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'services/weather_service.dart';
// import 'firebase_options.dart'; // Uncomment setelah setup Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriGo',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: false),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  bool _showText = false;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Start logo animation immediately
    _logoController.forward();

    // Show text after 3 seconds (logo phase complete)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
        _textController.forward();
      }
    });

    // Navigate to login after total 6 seconds (3 seconds logo + 3 seconds with text)
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_logoController, _textController]),
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo with slide animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  transform: Matrix4.translationValues(
                    _showText
                        ? -15.0
                        : 0.0, // Slide slightly to the left when text appears
                    0.0,
                    0.0,
                  ),
                  child: FadeTransition(
                    opacity: _logoAnimation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _logoController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 120,
                                height: 120,
                                child: const Icon(
                                  Icons.local_florist,
                                  color: Color(0xFF2E8B25),
                                  size: 100,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Text with fade in animation
                if (_showText) ...[
                  const SizedBox(width: 12),
                  FadeTransition(
                    opacity: _textAnimation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(
                              0.5,
                              0,
                            ), // Start further from right
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _textController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Agri',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                      0xFFFFA500,
                                    ), // Orange/Yellow color
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Go',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E8B25), // Green color
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Politeknik Negeri Lampung',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
