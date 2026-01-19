// ============================================================
// CARA MENGGUNAKAN MIGRATION HELPER DI FINANCE PAGE
// ============================================================
//
// LANGKAH 1: Import migration helper
// Tambahkan di bagian atas lib/pages/finance_page.dart:
//
//     import '../utils/migration_helper.dart';
//
// LANGKAH 2: Tambahkan method migration
// Copy method ini ke dalam _FinancePageState class:
//
// Contoh implementasi method:
//
// Future<void> _checkAndMigrateData() async {
//   try {
//     // Check if migration already done
//     final isCompleted = await DataMigrationHelper.isMigrationCompleted();
//
//     if (isCompleted) {
//       print('✅ Migration already completed');
//       return;
//     }
//
//     // Show loading dialog
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(width: 20),
//               Text('Migrasi data ke Firebase...'),
//             ],
//           ),
//         ),
//       );
//     }
//
//     // Perform migration
//     final result = await DataMigrationHelper.migrateLocalTransactionsToFirebase(
//       userId,
//     );
//
//     // Close loading dialog
//     if (mounted) {
//       Navigator.of(context).pop();
//     }
//
//     // Mark as completed
//     if (result['success']) {
//       await DataMigrationHelper.markMigrationCompleted();
//
//       // Show success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               '✅ Migrasi berhasil: ${result['migrated']} transaksi',
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } else {
//       // Show error message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('❌ Migrasi gagal: ${result['message']}'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       }
//     }
//   } catch (e) {
//     print('❌ Migration check error: $e');
//
//     // Close loading dialog if still open
//     if (mounted) {
//       Navigator.of(context, rootNavigator: true).pop();
//     }
//   }
// }
//
// ------------------------------------------------------------
// LANGKAH 3: Panggil di initState()
// Update method initState() di _FinancePageState:
//
// @override
// void initState() {
//   super.initState();
//   _loadUserId();
//   _loadUserSchedules();
//   _listenToFirebaseTransactions();
//
//   // Tambahkan ini untuk auto-migration
//   Future.delayed(const Duration(seconds: 2), () {
//     _checkAndMigrateData();
//   });
// }
//
// ============================================================
// CONTOH MANUAL MIGRATION BUTTON (OPTIONAL)
// ============================================================
//
// Tambahkan widget button ini di finance_page untuk manual migration.
// Bisa ditaruh di AppBar actions atau di body:
//
// Widget _buildMigrationButton() {
//   return ElevatedButton.icon(
//     onPressed: () async {
//       // Confirm migration
//       final confirm = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Migrasi Data'),
//           content: const Text(
//             'Apakah Anda ingin memigrasikan data transaksi lokal ke Firebase?\n\n'
//             'Data lokal akan dihapus setelah migrasi berhasil.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Batal'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Migrasikan'),
//             ),
//           ],
//         ),
//       );
//
//       if (confirm == true) {
//         _checkAndMigrateData();
//       }
//     },
//     icon: const Icon(Icons.cloud_upload),
//     label: const Text('Migrasi ke Firebase'),
//   );
// }
//
// ============================================================
// CONTOH RESET MIGRATION (FOR TESTING)
// ============================================================
//
// Future<void> _resetMigration() async {
//   await DataMigrationHelper.resetMigrationFlag();
//   if (mounted) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Migration flag reset'),
//         backgroundColor: Colors.orange,
//       ),
//     );
//   }
// }
//
// ============================================================
// CONTOH SHOW MIGRATION INFO
// ============================================================
//
// Future<void> _showMigrationInfo() async {
//   final info = await DataMigrationHelper.getMigrationInfo();
//   final backups = await DataMigrationHelper.listBackups();
//
//   if (!mounted) return;
//
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Migration Info'),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Completed: ${info['completed']}'),
//             Text('Date: ${info['date'] ?? '-'}'),
//             const SizedBox(height: 16),
//             const Text('Backups:', style: TextStyle(fontWeight: FontWeight.bold)),
//             ...backups.map((backup) => Text('- ${backup['date']}')),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('OK'),
//         ),
//       ],
//     ),
//   );
// }
//
// ============================================================
// QUICK START - COPY PASTE READY
// ============================================================
//
// 1. Import di finance_page.dart:
//    import '../utils/migration_helper.dart';
//
// 2. Tambahkan ke initState():
//    Future.delayed(const Duration(seconds: 2), () async {
//      final completed = await DataMigrationHelper.isMigrationCompleted();
//      if (!completed && mounted) {
//        final result = await DataMigrationHelper.migrateLocalTransactionsToFirebase(userId);
//        if (result['success']) {
//          await DataMigrationHelper.markMigrationCompleted();
//        }
//      }
//    });
//
// 3. Run app dan data akan otomatis migrate ke Firebase!
