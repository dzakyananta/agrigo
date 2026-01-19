import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/user_data_store.dart';
import '../services/chat_session.dart';
import 'dashboard_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

// Painter latar belakang hijau bagian atas
class TopBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF3CB043)
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.45, 0);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.22,
      size.width * 0.1,
      size.height * 0.32,
    );
    path.quadraticBezierTo(
      0,
      size.height * 0.35,
      0,
      size.height * 0.42,
    );
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Painter latar belakang hijau bagian bawah
class BottomBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF3CB043)
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width * 0.5, size.height);
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.88,
      size.width * 0.88,
      size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width,
      size.height * 0.82,
      size.width,
      size.height * 0.72,
    );
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
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      final currentUserId = FirebaseService.userId;
        if (currentUserId != null && mounted) {
        final userDoc = await FirebaseService.getUser(currentUserId);
        String userName = userDoc.exists
          ? (userDoc.data() as Map<String, dynamic>)['name'] ?? 'User'
          : 'User';

        // Load per-account data (chat messages, schedules, etc.) into memory
        // so each user has their own stored app data. If no data exists,
        // the store will return empty structures.
        final loadedMessages = await UserDataStore.instance
          .loadChatMessages(currentUserId);
        ChatSession.instance.clear();
        ChatSession.instance.messages.addAll(loadedMessages);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(userName: userName)));
        }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // Map common FirebaseAuth error codes to Indonesian messages
        if (e.code == 'user-not-found') {
          _showLoginErrorDialog(
            title: 'Pendaftaran Diperlukan',
            message:
                'akun anda belum terdaftar harap daftar akun terlebih dahulu',
          );
        } else if (e.code == 'wrong-password') {
          _showLoginErrorDialog(
            title: 'Login Gagal',
            message: 'username atau password anda salah',
          );
        } else if (e.code == 'invalid-email') {
          _showLoginErrorDialog(
            title: 'Email Tidak Valid',
            message: 'Format email tidak valid. Periksa kembali alamat email Anda.',
          );
        } else if (e.code == 'user-disabled') {
          _showLoginErrorDialog(
            title: 'Akun Dinonaktifkan',
            message: 'Akun ini telah dinonaktifkan. Hubungi dukungan.',
          );
        } else {
          // For any other FirebaseAuthException code, show a generic Indonesian message
          _showLoginErrorDialog(
            title: 'Login Gagal',
            message: 'Terjadi kesalahan saat login. Silakan coba lagi.',
          );
        }
      }
    } catch (e) {
      // Catch-all for non-Firebase exceptions (e.g., recaptcha or network issues)
      if (mounted) {
        _showLoginErrorDialog(
          title: 'Login Gagal',
          message: 'Terjadi kesalahan saat login. Silakan coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLoginErrorDialog({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: TopBackgroundPainter())),
          Positioned.fill(
              child: CustomPaint(painter: BottomBackgroundPainter())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 50),
                              const Text(
                                'Masuk',
                                style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 140),

                              _buildInputBox(
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ketik email anda',
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: Colors.black),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              _buildInputBox(
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Ketik kata sandi anda',
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        color: Colors.black),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.black),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPasswordPage())),
                                  child: const Text('Lupa Password?',
                                      style: TextStyle(
                                          color: Color(0xFF4A90E2),
                                          fontSize: 13)),
                                ),
                              ),

                              const SizedBox(height: 10),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleEmailLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3CB043),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Text('Masuk',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                ),
                              ),

                              const SizedBox(height: 30),

                              Row(
                                children: [
                                  Expanded(
                                      child: Divider(color: Colors.grey[400])),
                                  const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Text('atau masuk dengan',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12))),
                                  Expanded(
                                      child: Divider(color: Colors.grey[400])),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialIcon(
                                      Icons.g_mobiledata, Colors.red),
                                  const SizedBox(width: 20),
                                  _buildSocialIcon(Icons.facebook, Colors.blue),
                                ],
                              ),

                              // Menambahkan jarak statis agar teks naik ke atas
                              const SizedBox(height: 60),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Belum punya akun? ',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.black)),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterPage())),
                                    child: const Text('Daftar Sekarang!',
                                        style: TextStyle(
                                            color: Color(0xFF4A90E2),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ),
                                ],
                              ),

                              // Memberikan padding bawah agar tidak terlalu mepet dasar layar
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3CB043), width: 1.5),
      ),
      child: child,
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!)),
      child: Icon(icon, size: 35, color: color),
    );
  }
}
