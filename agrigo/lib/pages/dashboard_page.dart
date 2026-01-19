import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'weather_page.dart';
import 'analysis_page.dart';
import 'commodity_selection_page.dart';
import 'chatbot_page.dart';
import 'finance_page.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'change_phone_number_page.dart';
import 'schedule_page.dart';
import 'notification_page.dart';
import 'login_page.dart';
import '../screens/transactions_screen.dart';
import '../screens/schedules_screen.dart';
import '../services/user_service.dart';
import '../services/schedule_service.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';
import '../services/chat_session.dart';
import 'profile_page.dart';

class DashboardPage extends StatefulWidget {
  final String userName;

  const DashboardPage({super.key, required this.userName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // Form state variables
  String? selectedKomoditas;
  DateTime? startDate;
  DateTime? endDate;

  // User profile variables
  String? userLocation;
  String? userEmail;
  String? userPhone;
  String displayName = '';

  // Notification variables
  List<NotificationItem> notifications = [];
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    displayName = widget.userName;
    _loadUserProfile();
    _initializeNotifications();
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserService.getUserProfile();
    if (mounted) {
      setState(() {
        userLocation = profile?['location'];
        userEmail = profile?['email'];
        userPhone = profile?['phone'];
        // Prefer stored name, otherwise email, otherwise passed name
        final String? storedName = profile?['name'] as String?;
        final String? storedEmail = profile?['email'] as String?;
        if (storedName != null && storedName.isNotEmpty) {
          displayName = storedName;
        } else if (storedEmail != null && storedEmail.isNotEmpty) {
          displayName = storedEmail;
        } else {
          displayName = widget.userName;
        }
      });
    }
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.generateSmartNotifications(force: true);
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final loadedNotifications = await NotificationService.getNotifications();
    final count = await NotificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        notifications = loadedNotifications;
        unreadCount = count;
      });
    }
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Keluar')),
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
        // Clear local non-user profile cache
        await UserService.clearUserData();
        // Clear in-memory chat/session data so next account starts fresh
        try {
          ChatSession.instance.clear();
        } catch (_) {}
        // Clear current in-memory notifications
        setState(() {
          notifications = [];
          unreadCount = 0;
        });
        if (mounted) {
          Navigator.of(context).pop(); // close loading
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false);
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Gagal logout: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildBerandaPage();
      case 1:
        return _buildKeuanganPage();
      case 2:
        return _buildChatbotPage();
      case 3:
        return _buildCuacaPage();
      case 4:
        return const AnalysisPage();
      default:
        return _buildBerandaPage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _initializeNotifications();
    }
  }

  Widget _buildBerandaPage() {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return RefreshIndicator(
      onRefresh: _initializeNotifications,
      color: const Color(0xFF3CB043),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: isTablet ? 24 : 16,
          right: isTablet ? 24 : 16,
          bottom: isTablet ? 24 : 8,
          top: 37,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header with Notification - only on dashboard
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile section (left side) - tappable to open profile
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            userName: widget.userName,
                            userEmail: userEmail,
                            userPhone: userPhone,
                            userLocation: userLocation,
                          ),
                        ),
                      );

                      // Reload profile after returning
                      _loadUserProfile();
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF3CB043),
                          child: Text(
                            widget.userName.isNotEmpty
                                ? widget.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat datang kembali,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Notification Bell (right side - only appears on dashboard)
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationPage(
                            notifications: notifications,
                            onNotificationRead: () => _loadNotifications(),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3CB043).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF3CB043),
                            size: 24,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3CB043),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Jadwal Terdekat Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jadwal Terdekat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SchedulePage()),
                    );
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: Color(0xFF3CB043),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal jadwal cards
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildJadwalCard(
                    title: 'Penyemprotan\nCabai Rawit',
                    date: '25 Okt',
                    category: 'Tanam',
                    imageUrl:
                        'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?w=400&h=300&fit=crop',
                    categoryColor: const Color(0xFF3CB043),
                  ),
                  const SizedBox(width: 12),
                  _buildJadwalCard(
                    title: 'Panem Padi',
                    date: '30 Okt',
                    category: 'Panen',
                    imageUrl:
                        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=400&h=300&fit=crop',
                    categoryColor: const Color(0xFFFF8C00),
                  ),
                  const SizedBox(width: 12),
                  _buildJadwalCard(
                    title: 'Panem Padi',
                    date: '30 Okt',
                    category: 'Panen',
                    imageUrl:
                        'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?w=400&h=300&fit=crop',
                    categoryColor: const Color(0xFFFF8C00),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Jadwal Tanam & Komoditas Section
            const Text(
              'Jadwal Tanam & Komoditas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Form Section
            Container(
              constraints: const BoxConstraints(minHeight: 240),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Komoditas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showKomoditasBottomSheet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedKomoditas ?? 'Pilih Komoditas Anda',
                            style: TextStyle(
                              fontSize: 14,
                              color: selectedKomoditas != null
                                  ? Colors.black87
                                  : Colors.grey[600],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mulai Tanam',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _selectStartDate,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      startDate != null
                                          ? '${startDate!.day.toString().padLeft(2, '0')}/${startDate!.month.toString().padLeft(2, '0')}/${startDate!.year}'
                                          : 'dd/mm/yyyy',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: startDate != null
                                            ? Colors.black87
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Perkiraan Panen',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _selectEndDate,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      endDate != null
                                          ? '${endDate!.day.toString().padLeft(2, '0')}/${endDate!.month.toString().padLeft(2, '0')}/${endDate!.year}'
                                          : 'dd/mm/yyyy',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: endDate != null
                                            ? Colors.black87
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Simpan Jadwal Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saveSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CB043),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Simpan Jadwal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Removed extra bottom spacing so content fills available space
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalCard({
    required String title,
    required String date,
    required String category,
    required String imageUrl,
    required Color categoryColor,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category == 'Tanam' ? Icons.agriculture : Icons.grass,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildNotificationItemFromData(NotificationItem notification) {
    return _buildNotificationItem(
      notification.title,
      notification.description,
      notification.time,
      _getIconFromType(notification.iconType),
      _getColorFromType(notification.colorType),
      notification.isUnread,
    );
  }

  IconData _getIconFromType(String type) {
    switch (type) {
      case 'water':
        return Icons.water_drop;
      case 'fertilizer':
        return Icons.eco;
      case 'pest':
        return Icons.bug_report;
      case 'harvest':
        return Icons.agriculture;
      case 'plant':
        return Icons.grass;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorFromType(String type) {
    switch (type) {
      case 'red':
        return Colors.red;
      case 'green':
        return const Color(0xFF3CB043);
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      default:
        return const Color(0xFF3CB043);
    }
  }

  Widget _buildNotificationItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
    bool isUnread,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUnread
            ? Border.all(color: color.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeuanganPage() {
    return const FinancePage();
  }

  Widget _buildChatbotPage() {
    return const ChatbotPage();
  }

  Widget _buildCuacaPage() {
    return const WeatherPage();
  }

  Widget _buildProfilPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.userName}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            userLocation ?? 'Lokasi tidak tersedia',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Profile Options
          _buildProfileOption(
            Icons.person,
            'Edit Profil',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    userName: widget.userName,
                    userEmail: userEmail ?? '',
                    userPhone: userPhone ?? '',
                    userLocation: userLocation ?? '',
                  ),
                ),
              );

              if (result != null) {
                // Update user profile after edit
                await UserService.saveUserProfile(
                  name: result['name'] ?? widget.userName,
                  email: result['email'] ?? '',
                  phone: result['phone'] ?? '',
                  location: result['location'] ?? '',
                );
                _loadUserProfile(); // Reload profile data

                // Handle updated profile data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil berhasil diperbarui!'),
                    backgroundColor: Color(0xFF3CB043),
                  ),
                );
              }
            },
          ),
          _buildProfileOption(
            Icons.phone,
            'Ganti Nomor Telepon',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePhoneNumberPage(
                    currentPhone: userPhone ?? '082834286785',
                  ),
                ),
              );
            },
          ),
          _buildProfileOption(
            Icons.lock,
            'Ubah Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => _handleLogout(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
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
          child: Icon(
            icon,
            color: isLogout ? Colors.red : const Color(0xFF3CB043),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
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
      backgroundColor: Colors.grey[50],
      appBar: _selectedIndex == 4
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
              automaticallyImplyLeading: false,
            )
          : null,
      body: _getSelectedPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3CB043),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Keuangan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chatbot',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.thunderstorm_outlined),
              activeIcon: Icon(Icons.thunderstorm),
              label: 'Cuaca',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analisis',
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuka halaman pemilihan komoditas
  Future<void> _showKomoditasBottomSheet() async {
    print('===== DASHBOARD: Opening Commodity Selection =====');
    final selectedCommodity = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CommoditySelectionPage(
          isFromDashboard: true,
          selectedCommodity: selectedKomoditas,
        ),
      ),
    );

    if (selectedCommodity != null) {
      setState(() {
        selectedKomoditas = selectedCommodity;
      });
    }
  }

  // Fungsi untuk memilih tanggal mulai tanam
  Future<void> _selectStartDate() async {
    print('===== DASHBOARD: Opening Start Date Picker =====');
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3CB043),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        endDate = picked.add(const Duration(days: 90));
      });
    }
  }

  // Fungsi untuk memilih tanggal perkiraan panen
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ??
          (startDate?.add(const Duration(days: 90)) ??
              DateTime.now().add(const Duration(days: 90))),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3CB043),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  // Fungsi untuk menyimpan jadwal
  Future<void> _saveSchedule() async {
    if (selectedKomoditas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih komoditas terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal mulai tanam'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal perkiraan panen'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal panen harus setelah tanggal tanam'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final schedule = Schedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        komoditas: selectedKomoditas!,
        startDate: startDate!,
        endDate: endDate!,
        createdAt: DateTime.now(),
      );

      // Debug: log current user and existing schedules before save
      try {
        print('🔵 DASHBOARD: userId=${FirebaseService.userId}');
        final before = await ScheduleService.getSchedules();
        print('🔵 DASHBOARD: schedules before save count=${before.length}');
        try {
          final beforeJson = jsonEncode(before.map((s) => s.toMap()).toList());
          print('🔵 DASHBOARD: schedules before save json=$beforeJson');
        } catch (_) {}
      } catch (e) {
        print('⚠️ DASHBOARD: could not read schedules before save: $e');
      }

      print('🔵 DASHBOARD: saving schedule ${jsonEncode(schedule.toMap())}');

      try {
        await ScheduleService.saveSchedule(schedule);
      } on MissingPluginException catch (mpe) {
        // Likely plugin not registered (shared_preferences). Provide actionable message.
        final msg = 'MissingPluginException while saving schedule: ${mpe.message}';
        print('❌ DASHBOARD: $msg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan jadwal: $msg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      // Verify saved schedules to ensure persistence worked
      try {
        final saved = await ScheduleService.getSchedules();
        print('🔵 DASHBOARD: schedules after save count=${saved.length}');
        try {
          final afterJson = jsonEncode(saved.map((s) => s.toMap()).toList());
          print('🔵 DASHBOARD: schedules after save json=$afterJson');
        } catch (_) {}

        final found = saved.any((s) => s.id == schedule.id);

        if (!found) {
          // Saving failed for unknown reasons
          print('❌ DASHBOARD: Saved schedule not found after save (id=${schedule.id})');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan jadwal — coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        print('❌ DASHBOARD: error verifying saved schedules: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memverifikasi penyimpanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Reset form
      setState(() {
        selectedKomoditas = null;
        startDate = null;
        endDate = null;
      });

      // Show confirmation dialog (popup) instead of navigating
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Jadwal Disimpan'),
          content: Text('Jadwal tanam ${schedule.komoditas} berhasil disimpan!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ DASHBOARD: unexpected error saving schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan jadwal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
