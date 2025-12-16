import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';
import '../services/firestore_service.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({Key? key}) : super(key: key);

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  final FirestoreService _firestore = FirestoreService();
  String _selectedFilter = 'all'; // all, ongoing, planned, completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Tanam'),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'planned', child: Text('Direncanakan')),
              const PopupMenuItem(value: 'ongoing', child: Text('Sedang Berjalan')),
              const PopupMenuItem(value: 'completed', child: Text('Selesai')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<ScheduleModel>>(
        stream: _firestore.streamUserSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var schedules = snapshot.data ?? [];

          // Apply filter
          if (_selectedFilter != 'all') {
            schedules = schedules.where((s) => s.status == _selectedFilter).toList();
          }

          // Sort by start date
          schedules.sort((a, b) => b.startDate.compareTo(a.startDate));

          if (schedules.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              return _buildScheduleCard(schedules[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddScheduleDialog,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Jadwal Baru'),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
    final statusColor = _getStatusColor(schedule.status);
    final statusIcon = _getStatusIcon(schedule.status);
    final daysRemaining = schedule.endDate.difference(DateTime.now()).inDays;
    final progress = _calculateProgress(schedule);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showScheduleDetails(schedule),
        onLongPress: () => _showScheduleOptions(schedule),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule.crop,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(schedule.status),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              if (schedule.description.isNotEmpty) ...[
                Text(
                  schedule.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Dates
              Row(
                children: [
                  Expanded(
                    child: _buildDateInfo(
                      'Mulai',
                      schedule.startDate,
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateInfo(
                      'Selesai',
                      schedule.endDate,
                      Icons.event_available,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Bar
              if (schedule.status == 'ongoing') ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      daysRemaining > 0
                          ? '$daysRemaining hari lagi'
                          : daysRemaining == 0
                              ? 'Berakhir hari ini'
                              : 'Telah lewat ${-daysRemaining} hari',
                      style: TextStyle(
                        color: daysRemaining >= 0 ? Colors.green.shade700 : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Area Info
              if (schedule.area > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.landscape, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Luas: ${schedule.area} ${schedule.unit}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada jadwal tanam',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat jadwal tanam pertama Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planned':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'planned':
        return Icons.schedule;
      case 'ongoing':
        return Icons.agriculture;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'planned':
        return 'Direncanakan';
      case 'ongoing':
        return 'Berjalan';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  double _calculateProgress(ScheduleModel schedule) {
    final now = DateTime.now();
    if (now.isBefore(schedule.startDate)) return 0.0;
    if (now.isAfter(schedule.endDate)) return 1.0;

    final total = schedule.endDate.difference(schedule.startDate).inDays;
    final elapsed = now.difference(schedule.startDate).inDays;

    return (elapsed / total).clamp(0.0, 1.0);
  }

  void _showAddScheduleDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final commodityController = TextEditingController();
    final areaController = TextEditingController();
    final startDateController = ValueNotifier<DateTime>(DateTime.now());
    final endDateController = ValueNotifier<DateTime>(
      DateTime.now().add(const Duration(days: 90)),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jadwal Tanam Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Jadwal *',
                  hintText: 'Misal: Tanam Padi Musim Hujan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commodityController,
                decoration: const InputDecoration(
                  labelText: 'Komoditas *',
                  hintText: 'Padi, Jagung, Cabai, dll',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Luas Lahan (Opsional)',
                  border: OutlineInputBorder(),
                  suffixText: 'hektar',
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<DateTime>(
                valueListenable: startDateController,
                builder: (context, date, _) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Tanggal Mulai'),
                    subtitle: Text(DateFormat('dd MMMM yyyy').format(date)),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        startDateController.value = picked;
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<DateTime>(
                valueListenable: endDateController,
                builder: (context, date, _) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_available),
                    title: const Text('Tanggal Selesai'),
                    subtitle: Text(DateFormat('dd MMMM yyyy').format(date)),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: startDateController.value,
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        endDateController.value = picked;
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || commodityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mohon isi judul dan komoditas')),
                );
                return;
              }

              final schedule = ScheduleModel(
                id: '',
                userId: _firestore.currentUserId!,
                title: titleController.text,
                description: descriptionController.text,
                startDate: startDateController.value,
                endDate: endDateController.value,
                status: DateTime.now().isAfter(startDateController.value)
                    ? 'ongoing'
                    : 'planned',
                crop: commodityController.text,
                area: areaController.text.isEmpty ? 0.0 : double.parse(areaController.text),
                unit: 'hektar',
                notes: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              final success = await _firestore.addSchedule(schedule);

              if (context.mounted) {
                Navigator.pop(context);
                if (success != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Jadwal berhasil ditambahkan')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDetails(ScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    schedule.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(schedule.status),
                  const SizedBox(height: 20),
                  if (schedule.description.isNotEmpty) ...[
                    const Text(
                      'Keterangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(schedule.description),
                    const SizedBox(height: 20),
                  ],
                  const Text(
                    'Detail',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Komoditas', schedule.crop),
                  _buildDetailRow(
                    'Tanggal Mulai',
                    DateFormat('dd MMMM yyyy').format(schedule.startDate),
                  ),
                  _buildDetailRow(
                    'Tanggal Selesai',
                    DateFormat('dd MMMM yyyy').format(schedule.endDate),
                  ),
                  if (schedule.area > 0)
                    _buildDetailRow('Luas', '${schedule.area} ${schedule.unit}'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showUpdateStatusDialog(schedule);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Update Status'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteScheduleDialog(schedule);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Hapus'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleOptions(ScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Update Status'),
                onTap: () {
                  Navigator.pop(context);
                  _showUpdateStatusDialog(schedule);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Jadwal', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteScheduleDialog(schedule);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateStatusDialog(ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption('planned', 'Direncanakan', schedule),
            _buildStatusOption('ongoing', 'Sedang Berjalan', schedule),
            _buildStatusOption('completed', 'Selesai', schedule),
            _buildStatusOption('cancelled', 'Dibatalkan', schedule),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String status, String label, ScheduleModel schedule) {
    final color = _getStatusColor(status);
    final isSelected = schedule.status == status;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: color,
      ),
      title: Text(label),
      onTap: () async {
        await _firestore.updateSchedule(
          schedule.id,
          {'status': status, 'updatedAt': Timestamp.now()},
        );
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status diubah menjadi $label')),
          );
        }
      },
    );
  }

  void _showDeleteScheduleDialog(ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Yakin ingin menghapus jadwal "${schedule.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.deleteSchedule(schedule.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jadwal dihapus')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
