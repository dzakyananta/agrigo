import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADD THIS IMPORT
import '../services/firebase_service.dart';
import 'dashboard_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

// Custom painter for top-left green circle
class TopLeftCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF3AA02F)
      ..style = PaintingStyle.fill;

    // Draw large circle positioned at top-left corner
    // Circle center is outside viewport to create partial circle effect
    canvas.drawCircle(
      Offset(-size.width * 0.2, size.height * 0.25), // Position at top-left
      size.width * 0.65, // Large radius to cover "Login" text area
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for bottom-right green circle
class BottomRightCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF2E8B25)
      ..style = PaintingStyle.fill;

    // Draw large circle positioned at bottom-right corner
    // Circle center is outside viewport to create partial circle effect
    canvas.drawCircle(
      Offset(size.width * 1.2, size.height * 0.75), // Position at bottom-right
      size.width * 0.65, // Large radius matching top circle
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email/Password Login - ENHANCED with better error handling
  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('🔵 Attempting login with: ${_emailController.text.trim()}');
      
      // STEP 1: Login (will throw error if failed)
      await FirebaseService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('🟢 Login successful!');

      // STEP 2: Get current user ID WITHOUT accessing credential.user
      final currentUserId = FirebaseService.userId;
      
      if (currentUserId != null && mounted) {
        print('🔵 Fetching user data from Firestore...');
        final userDoc = await FirebaseService.getUser(currentUserId);
        String userName = 'User';

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          userName = userData['name'] ?? 'User';
          print('🟢 User data found: $userName');
        } else {
          // Auto-create Firestore document for existing Firebase Auth users
          print('⚠️ User document not found in Firestore - creating now...');
          final currentUser = FirebaseService.currentUser;
          await FirebaseService.createUser(
            userId: currentUserId,
            name: currentUser?.displayName ?? 'User',
            email: currentUser?.email ?? _emailController.text.trim(),
            phone: currentUser?.phoneNumber ?? '',
            region: '',
          );
          userName = currentUser?.displayName ?? 'User';
          print('✅ User document created with name: $userName');
        }

        print('🔵 Navigating to Dashboard...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(userName: userName),
          ),
        );

        print('✅ Navigation complete');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Login berhasil! Selamat datang $userName'),
            backgroundColor: const Color(0xFF2E8B25),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('🔴 FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage = 'Login gagal';

      if (e.code == 'user-not-found') {
        errorMessage = '❌ Email tidak terdaftar.\n\nEmail ini mungkin terdaftar dengan provider lain (Google/Facebook).';
      } else if (e.code == 'wrong-password') {
        errorMessage = '❌ Password salah.\n\nSilakan coba lagi atau gunakan "Lupa Password".';
      } else if (e.code == 'invalid-email') {
        errorMessage = '❌ Format email tidak valid';
      } else if (e.code == 'invalid-credential') {
        errorMessage = '❌ Email atau password salah.\n\nJika Anda mendaftar dengan Google/Facebook, silakan login dengan provider tersebut.';
      } else {
        errorMessage = '❌ ${e.message}';
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Gagal'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('🔴 Unexpected error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Terjadi kesalahan:\n\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Google Login - DISABLED temporarily due to Pigeon bug
  Future<void> _handleGoogleLogin() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Login'),
        content: const Text(
          'Login Google sedang dalam perbaikan.\n\n'
          'Silakan gunakan:\n'
          '• Email & Password\n'
          '• Daftar akun baru jika belum punya'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Facebook Login - DISABLED temporarily due to Pigeon bug
  Future<void> _handleFacebookLogin() async {
    // Show info dialog instead of trying to login
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Facebook Login'),
        content: const Text(
          'Login Facebook sedang dalam perbaikan.\n\n'
          'Silakan gunakan:\n'
          '• Email & Password\n'
          '• Google Sign-In'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  void _handleRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Widget _buildCredentialItem(String role, String email, String password) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$role:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _emailController.text = email;
                _passwordController.text = password;
              },
              child: Text(
                '$email / $password',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          width: isDesktop ? 400 : double.infinity,
          height: isDesktop ? 800 : double.infinity,
          child: Stack(
            children: [
              // Top-left green circle background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: isDesktop ? 300 : size.height * 0.4,
                  child: CustomPaint(
                    painter: TopLeftCirclePainter(),
                    size: Size(
                      size.width,
                      isDesktop ? 300 : size.height * 0.4,
                    ),
                  ),
                ),
              ),

              // Bottom-right green circle background
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: isDesktop ? 200 : size.height * 0.3,
                  child: CustomPaint(
                    painter: BottomRightCirclePainter(),
                    size: Size(size.width, isDesktop ? 200 : size.height * 0.3),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isDesktop ? 60 : size.height * 0.08),

                        // Login title positioned in green circle area
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        SizedBox(height: isDesktop ? 100 : size.height * 0.15),

                        // Email field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2E8B25),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Email atau No. Handphone',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Color(0xFF2E8B25),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email atau No. Handphone tidak boleh kosong';
                              }
                              // Check if it's email format
                              bool isEmail = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value);
                              // Check if it's Indonesian phone format
                              bool isPhone = RegExp(r'^(\+62|62|0)[0-9]{9,13}$')
                                  .hasMatch(
                                    value.replaceAll(RegExp(r'[\s-]'), ''),
                                  );

                              if (!isEmail && !isPhone) {
                                return 'Format email atau nomor handphone tidak valid';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2E8B25),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Ketik password anda',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF2E8B25),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: const Color(0xFF2E8B25),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _handleForgotPassword,
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleEmailLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E8B25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Atau masuk dengan',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Social login buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google button - DISABLED
                            Opacity(
                              opacity: 0.5,
                              child: GestureDetector(
                                onTap: _handleGoogleLogin,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            // Facebook button - DISABLED
                            Opacity(
                              opacity: 0.5,
                              child: GestureDetector(
                                onTap: _handleFacebookLogin,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'f',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum punya akun? ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: _handleRegister,
                              child: const Text(
                                'Daftar Sekarang!',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Bottom indicator
                        Center(
                          child: Container(
                            width: 140,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
