import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/schedule_service.dart';
import 'edit_schedule_page.dart';
import 'half_screen_edit_schedule.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Schedule> schedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => isLoading = true);
    try {
      final loadedSchedules = await ScheduleService.getSchedules();
      setState(() {
        schedules = loadedSchedules;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading schedules: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editSchedule(Schedule schedule) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditSchedulePage(schedule: schedule),
      ),
    );

    if (result == true) {
      _loadSchedules(); // Refresh the list after successful edit
    }
  }

  Future<void> _deleteSchedule(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Jadwal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus jadwal ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ScheduleService.deleteSchedule(id);
      _loadSchedules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showHalfScreenEdit(Schedule schedule) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HalfScreenEditSchedule(schedule: schedule),
    );

    if (result == true) {
      _loadSchedules(); // Refresh the list after successful edit
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Jadwal Tanam dan Panen',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : schedules.isEmpty
          ? _buildEmptyState()
          : _buildScheduleList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Jadwal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tambahkan jadwal tanam dari halaman beranda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return RefreshIndicator(
      onRefresh: _loadSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return _buildScheduleCard(schedule);
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    final now = DateTime.now();

    // Get commodity icon
    IconData commodityIcon = _getCommodityIcon(schedule.komoditas);
    Color commodityColor = _getCommodityColor(schedule.komoditas);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Commodity icon - sesuai desain
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: commodityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(commodityIcon, size: 32, color: commodityColor),
                ),

                const SizedBox(width: 16),

                // Content area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Commodity name - besar sesuai desain
                      Text(
                        schedule.komoditas,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      const SizedBox(height: 8),

                      // Dates section dengan layout vertikal sesuai desain
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Mulai Tanam',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Perkiraan Panen',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          // Start date
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(schedule.startDate),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // End date
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_available,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(schedule.endDate),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Edit and Delete buttons side by side
            Row(
              children: [
                // Edit button - kiri
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showHalfScreenEdit(schedule),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Delete button - kanan
                Expanded(
                  child: GestureDetector(
                    onTap: () => _deleteSchedule(schedule.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
          ],
        ),
      ),
    );
  }

  IconData _getCommodityIcon(String commodity) {
    switch (commodity.toLowerCase()) {
      case 'cabai':
      case 'cabai rawit':
        return Icons.local_fire_department;
      case 'padi':
        return Icons.grass;
      case 'jagung':
      case 'jagung manis':
        return Icons.eco;
      case 'tomat':
        return Icons.circle;
      case 'bayam':
        return Icons.eco_outlined;
      case 'kangkung':
        return Icons.grass_outlined;
      case 'sawi':
        return Icons.local_florist;
      default:
        return Icons.agriculture;
    }
  }

  Color _getCommodityColor(String commodity) {
    switch (commodity.toLowerCase()) {
      case 'cabai':
      case 'cabai rawit':
        return Colors.red;
      case 'padi':
        return Colors.amber;
      case 'jagung':
      case 'jagung manis':
        return Colors.orange;
      case 'tomat':
        return Colors.red;
      case 'bayam':
        return Colors.green;
      case 'kangkung':
        return Colors.green[700]!;
      case 'sawi':
        return Colors.lightGreen;
      default:
        return Colors.green;
    }
  }
}
