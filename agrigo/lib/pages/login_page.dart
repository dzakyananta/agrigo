import 'package:flutter/material.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import 'forgot_password_page.dart';

// Custom painter for top large circle with P-wave
class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF3AA02F)
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Start from top-left corner
    path.moveTo(0, 0);
    // Go along entire top
    path.lineTo(size.width, 0);
    // Go down right side to start wave
    path.lineTo(size.width, size.height * 0.3);

    // Create more natural wave with multiple curves
    // First curve down and left
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.5, // Control point
      size.width * 0.7,
      size.height * 0.55, // End point
    );

    // Second curve creating the wave bulge
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.65, // Control point for bulge
      size.width * 0.3,
      size.height * 0.6, // Mid point
    );

    // Third curve back to left side
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.55, // Control point
      0,
      size.height * 0.4, // End at left edge
    );

    // Close back to start
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for bottom large circle
class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF2E8B25)
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Start from bottom-left
    path.moveTo(0, size.height);
    // Create gentle wave curve
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.6, // Control point for curve up
      size.width * 0.6,
      size.height * 0.7, // Mid point
    );

    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.75, // Control point
      size.width,
      size.height * 0.85, // End at right edge
    );

    // Complete the shape
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
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
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));

      // Validasi dengan akun yang terdaftar
      final identifier = _emailController.text.trim();
      final password = _passwordController.text.trim();

      bool loginSuccess = _validateCredentials(identifier, password);

      setState(() {
        _isLoading = false;
      });

      if (loginSuccess) {
        print('===== LOGIN SUCCESS: Navigating to Dashboard =====');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DashboardPage(userName: _getUserName(identifier)),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email/No. Handphone atau password salah!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  bool _validateCredentials(String identifier, String password) {
    // Akun yang terdaftar di sistem dengan email dan nomor handphone
    final Map<String, Map<String, String>> registeredAccounts = {
      // Login dengan email
      'admin@agrigo.com': {
        'password': 'admin123',
        'name': 'Admin Agrigo',
        'role': 'admin',
      },
      'budi@farmer.com': {
        'password': 'password123',
        'name': 'Budi Santoso',
        'role': 'farmer',
      },
      'siti@farmer.com': {
        'password': 'password123',
        'name': 'Siti Rahayu',
        'role': 'farmer',
      },
      'buyer@agromandiri.com': {
        'password': 'password123',
        'name': 'PT Agro Mandiri',
        'role': 'buyer',
      },
      'ahmad@farmer.com': {
        'password': 'password123',
        'name': 'Ahmad Wijaya',
        'role': 'farmer',
      },
      'test@agrigo.com': {
        'password': 'test123',
        'name': 'User Test',
        'role': 'farmer',
      },
      // Login dengan nomor handphone
      '08123456789': {
        'password': 'admin123',
        'name': 'Admin Agrigo',
        'role': 'admin',
      },
      '08234567890': {
        'password': 'password123',
        'name': 'Budi Santoso',
        'role': 'farmer',
      },
      '08345678901': {
        'password': 'password123',
        'name': 'Siti Rahayu',
        'role': 'farmer',
      },
      '08456789012': {
        'password': 'password123',
        'name': 'PT Agro Mandiri',
        'role': 'buyer',
      },
      '08567890123': {
        'password': 'password123',
        'name': 'Ahmad Wijaya',
        'role': 'farmer',
      },
      '08987654321': {
        'password': 'test123',
        'name': 'User Test',
        'role': 'farmer',
      },
    };

    // Normalize phone number (remove spaces, dashes)
    String normalizedIdentifier = identifier.replaceAll(RegExp(r'[\s-]'), '');

    return registeredAccounts.containsKey(normalizedIdentifier) &&
        registeredAccounts[normalizedIdentifier]!['password'] == password;
  }

  String _getUserName(String identifier) {
    final Map<String, String> userNames = {
      // Email mapping
      'admin@agrigo.com': 'Admin Agrigo',
      'budi@farmer.com': 'Budi Santoso',
      'siti@farmer.com': 'Siti Rahayu',
      'buyer@agromandiri.com': 'PT Agro Mandiri',
      'ahmad@farmer.com': 'Ahmad Wijaya',
      'test@agrigo.com': 'User Test',
      // Phone mapping
      '08123456789': 'Admin Agrigo',
      '08234567890': 'Budi Santoso',
      '08345678901': 'Siti Rahayu',
      '08456789012': 'PT Agro Mandiri',
      '08567890123': 'Ahmad Wijaya',
      '08987654321': 'User Test',
    };

    // Normalize phone number
    String normalizedIdentifier = identifier.replaceAll(RegExp(r'[\s-]'), '');

    return userNames[normalizedIdentifier] ??
        (identifier.contains('@') ? identifier.split('@')[0] : 'User');
  }

  Future<void> _handleGoogleLogin() async {
    // TODO: Implement Google login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google login belum diimplementasi'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleFacebookLogin() async {
    // TODO: Implement Facebook login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facebook login belum diimplementasi'),
        duration: Duration(seconds: 2),
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
              // Top wave background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: isDesktop ? 280 : size.height * 0.35,
                  child: CustomPaint(
                    painter: TopWavePainter(),
                    size: Size(
                      size.width,
                      isDesktop ? 280 : size.height * 0.35,
                    ),
                  ),
                ),
              ),

              // Bottom wave background
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: isDesktop ? 150 : size.height * 0.2,
                  child: CustomPaint(
                    painter: BottomWavePainter(),
                    size: Size(size.width, isDesktop ? 150 : size.height * 0.2),
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
                        SizedBox(height: isDesktop ? 80 : size.height * 0.12),

                        // Login title positioned in green area
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: isDesktop ? 120 : size.height * 0.18),

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
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Ketik password anda',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF2E8B25),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: const Color(0xFF2E8B25),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
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
                            onPressed: _isLoading ? null : _handleLogin,
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
                            // Google button
                            GestureDetector(
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

                            const SizedBox(width: 20),

                            // Facebook button
                            GestureDetector(
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
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Kredensial info
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Akun untuk Testing:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildCredentialItem(
                                'Admin',
                                'admin@agrigo.com',
                                'admin123',
                              ),
                              _buildCredentialItem(
                                'Admin HP',
                                '08123456789',
                                'admin123',
                              ),
                              _buildCredentialItem(
                                'Budi',
                                'budi@farmer.com',
                                'password123',
                              ),
                              _buildCredentialItem(
                                'Budi HP',
                                '08234567890',
                                'password123',
                              ),
                              _buildCredentialItem(
                                'Testing',
                                'test@agrigo.com',
                                'test123',
                              ),
                              _buildCredentialItem(
                                'Test HP',
                                '08987654321',
                                'test123',
                              ),
                            ],
                          ),
                        ),

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
