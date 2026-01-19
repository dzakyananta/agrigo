import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'change_phone_number_page.dart';
import '../services/user_service.dart';
import '../services/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String? userEmail;
  final String? userPhone;
  final String? userLocation;

  const ProfilePage({
    Key? key,
    required this.userName,
    this.userEmail,
    this.userPhone,
    this.userLocation,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userLocation;
  String? userEmail;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    final profile = await UserService.getUserProfile();
    setState(() {
      userLocation = profile['location'] ?? widget.userLocation;
      userEmail = profile['email'] ?? widget.userEmail;
      userPhone = profile['phone'] ?? widget.userPhone;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar'),
              style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()));
        await FirebaseService.logout();
        await UserService.clearUserData();
        if (mounted) {
          Navigator.of(context).pop(); // close loading
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
        }
      }
    }
  }

  Widget _buildProfileOption(IconData icon, String title,
      {VoidCallback? onTap, bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withOpacity(0.1)
                : const Color(0xFF3CB043).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: isLogout ? Colors.red : const Color(0xFF3CB043)),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red : Colors.black87)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
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
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white)),
                  const Expanded(
                      child: Text('Profil',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF3CB043),
                          child: Text(
                              widget.userName.isNotEmpty
                                  ? widget.userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold))),
                      const SizedBox(height: 16),
                      Text(widget.userName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          userLocation ??
                              widget.userLocation ??
                              'Lokasi tidak tersedia',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 32),
                      _buildProfileOption(Icons.person, 'Edit Profil',
                          onTap: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                    userName: widget.userName,
                                    userEmail: userEmail ?? '',
                                    userPhone: userPhone ?? '',
                                    userLocation: userLocation ?? '')));
                        if (result != null) {
                          await UserService.saveUserProfile(
                              name: result['name'] ?? widget.userName,
                              email: result['email'] ?? '',
                              phone: result['phone'] ?? '',
                              location: result['location'] ?? '');
                          await _loadValues();
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Profil berhasil diperbarui!'),
                                    backgroundColor: Color(0xFF3CB043)));
                        }
                      }),
                      _buildProfileOption(Icons.phone, 'Ganti Nomor Telepon',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangePhoneNumberPage(
                                      currentPhone: userPhone ?? '')))),
                      _buildProfileOption(Icons.lock, 'Ubah Password',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ChangePasswordPage()))),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                              onPressed: () => _handleLogout(context),
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.red, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: const Text('Keluar',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))),
                        ),
                      ),
                    ],
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
