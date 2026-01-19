import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../services/firebase_service.dart';

/// Utility untuk migrasi data transaksi dari Local Storage ke Firebase
/// Gunakan sekali saja saat pertama kali implementasi Firebase
class DataMigrationHelper {
  /// Migrate semua transaksi dari SharedPreferences ke Firestore
  static Future<Map<String, dynamic>> migrateLocalTransactionsToFirebase(
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('finance_transactions');

    if (transactionsJson == null) {
      print('ℹ️ No local transactions to migrate');
      return {
        'success': true,
        'migrated': 0,
        'failed': 0,
        'message': 'No data to migrate'
      };
    }

    try {
      final List<dynamic> decoded = jsonDecode(transactionsJson);
      print('🔄 Starting migration of ${decoded.length} transactions...');

      int successCount = 0;
      int failedCount = 0;
      List<String> errors = [];

      for (var i = 0; i < decoded.length; i++) {
        try {
          final transaction = decoded[i];

          // Parse tanggal dari format 'dd/MM/yyyy'
          final tanggal = transaction['tanggal'] as String;
          final dateParts = tanggal.split('/');
          final date = DateTime(
            int.parse(dateParts[2]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[0]), // day
          );

          // Parse amount
          final amountStr = transaction['totalHarga']?.toString() ?? '0';
          final amount = double.tryParse(
                amountStr.replaceAll('.', '').replaceAll(',', '.'),
              ) ??
              0;

          // Create transaction in Firebase
          final result = await FirebaseService.createTransaction(
            userId: userId,
            type: transaction['type'] ?? 'income',
            source: transaction['target'] ?? '',
            amount: amount,
            description: transaction['catatan'] ?? '',
            date: date,
            commodityName: transaction['komoditas'] ?? '',
          );

          successCount++;
          print(
            '✅ [$successCount/${decoded.length}] Migrated: ${transaction['komoditas']} - ${transaction['tanggal']}',
          );
        } catch (e) {
          failedCount++;
          final errorMsg = 'Failed to migrate transaction ${i + 1}: $e';
          errors.add(errorMsg);
          print('❌ $errorMsg');
        }
      }

      print(
          '🎉 Migration completed: $successCount/${decoded.length} successful, $failedCount failed');

      // Backup data lama sebelum hapus
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(
        'finance_transactions_backup_$timestamp',
        transactionsJson,
      );
      print('💾 Backup saved with timestamp: $timestamp');

      // Hapus data lama dari SharedPreferences
      await prefs.remove('finance_transactions');
      print('🗑️ Local transactions cleared');

      return {
        'success': true,
        'migrated': successCount,
        'failed': failedCount,
        'total': decoded.length,
        'errors': errors,
        'message':
            'Migration completed: $successCount successful, $failedCount failed'
      };
    } catch (e) {
      print('❌ Migration error: $e');
      return {
        'success': false,
        'migrated': 0,
        'failed': 0,
        'message': e.toString()
      };
    }
  }

  /// Check if migration has been done before
  static Future<bool> isMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('transactions_migrated') ?? false;
  }

  /// Mark migration as completed
  static Future<void> markMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('transactions_migrated', true);
    await prefs.setInt(
      'migration_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Reset migration flag (for testing purposes)
  static Future<void> resetMigrationFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transactions_migrated');
    await prefs.remove('migration_timestamp');
    print('🔄 Migration flag reset');
  }

  /// Get migration info
  static Future<Map<String, dynamic>> getMigrationInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('transactions_migrated') ?? false;
    final timestamp = prefs.getInt('migration_timestamp');

    return {
      'completed': completed,
      'timestamp': timestamp,
      'date': timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp).toString()
          : null
    };
  }

  /// Restore backup if migration failed
  static Future<bool> restoreFromBackup(int backupTimestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupKey = 'finance_transactions_backup_$backupTimestamp';
      final backup = prefs.getString(backupKey);

      if (backup == null) {
        print('❌ Backup not found for timestamp: $backupTimestamp');
        return false;
      }

      await prefs.setString('finance_transactions', backup);
      print('✅ Restored transactions from backup');
      return true;
    } catch (e) {
      print('❌ Restore failed: $e');
      return false;
    }
  }

  /// List all available backups
  static Future<List<Map<String, dynamic>>> listBackups() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final backups = <Map<String, dynamic>>[];

    for (var key in keys) {
      if (key.startsWith('finance_transactions_backup_')) {
        final timestamp = int.tryParse(
          key.replaceFirst('finance_transactions_backup_', ''),
        );
        if (timestamp != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          backups.add({
            'timestamp': timestamp,
            'date': DateFormat('dd/MM/yyyy HH:mm:ss').format(date),
            'key': key,
          });
        }
      }
    }

    // Sort by timestamp descending (newest first)
    backups.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return backups;
  }
}
