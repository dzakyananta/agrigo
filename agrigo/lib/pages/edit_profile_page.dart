import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userLocation;

  const EditProfilePage({
    Key? key,
    required this.userName,
    this.userEmail = '',
    this.userPhone = '',
    this.userLocation = '',
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
    _phoneController = TextEditingController(text: widget.userPhone);
    _locationController = TextEditingController(text: widget.userLocation);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Update Firebase Auth (email & password) if user is signed in
      try {
        final user = FirebaseService.currentUser;
        if (user != null) {
          // Update email if changed
          final newEmail = _emailController.text.trim();
          if (newEmail.isNotEmpty && newEmail != user.email) {
            try {
              await user.updateEmail(newEmail);
            } catch (e) {
              // Email update may require recent login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memperbarui email: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }

          // Update password if provided
          final newPassword = _passwordController.text.trim();
          if (newPassword.isNotEmpty) {
            try {
              await user.updatePassword(newPassword);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memperbarui password: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }

        // Update Firestore profile
        final uid = FirebaseService.userId;
        if (uid != null) {
          await FirebaseService.updateUserProfile(
            userId: uid,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            region: _locationController.text.trim(),
            email: _emailController.text.trim(),
          );
        }

        // Save to local prefs
        await UserService.saveUserProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          location: _locationController.text.trim(),
        );

        // Show success dialog (popup) and return when user confirms
        final resultData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
        };

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Profil berhasil disimpan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        Navigator.pop(context, resultData);
      } catch (e) {
        // Show error dialog so user sees the popup on failure too
        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text('Gagal'),
            content: Text('Terjadi kesalahan saat menyimpan: $e'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: const Color(0xFF3CB043)),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3CB043), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3CB043),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 20),

                                // Nama Lengkap
                                _buildTextField(
                                  controller: _nameController,
                                  hintText: 'Nama Lengkap Anda',
                                  icon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nama lengkap harus diisi';
                                    }
                                    return null;
                                  },
                                ),

                                // Email
                                _buildTextField(
                                  controller: _emailController,
                                  hintText: 'Kirim Email Anda',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email harus diisi';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                ),

                                // Nomor Telepon
                                _buildTextField(
                                  controller: _phoneController,
                                  hintText: 'Nomor Telepon',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nomor telepon harus diisi';
                                    }
                                    return null;
                                  },
                                ),

                                // Lokasi
                                _buildTextField(
                                  controller: _locationController,
                                  hintText: 'Lokasi',
                                  icon: Icons.location_on,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lokasi harus diisi';
                                    }
                                    return null;
                                  },
                                ),

                                // Password
                                _buildTextField(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  icon: Icons.lock,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        value.length < 6) {
                                      return 'Password minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),

                        // Save Button
                        Container(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3CB043),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
