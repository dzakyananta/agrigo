import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CommodityDetailPage extends StatefulWidget {
  const CommodityDetailPage({Key? key}) : super(key: key);

  @override
  State<CommodityDetailPage> createState() => _CommodityDetailPageState();
}

class _CommodityDetailPageState extends State<CommodityDetailPage> {
  List<Map<String, dynamic>> transactions = [];
  Map<String, Map<String, dynamic>> commoditySummary = {};

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    // Load sample data similar to finance_page.dart
    _loadSampleData();
  }

  void _loadSampleData() {
    // Add same sample transactions as finance_page.dart
    transactions = [
      {
        'type': 'income',
        'commodity': 'Padi',
        'tanggal': '15/11/2025',
        'target': 'Penjualan Padi',
        'kuantitas': '100',
        'satuan': 'kg',
        'harga': '60000',
        'totalHarga': '6000000',
        'amount': 6000000,
        'catatan': 'Penjualan padi hasil panen',
        'timestamp': DateTime(2025, 11, 15).millisecondsSinceEpoch,
      },
      {
        'type': 'income',
        'commodity': 'Jagung',
        'tanggal': '10/11/2025',
        'target': 'Penjualan Jagung',
        'kuantitas': '70',
        'satuan': 'kg',
        'harga': '50000',
        'totalHarga': '3500000',
        'amount': 3500000,
        'catatan': 'Penjualan jagung ke pasar',
        'timestamp': DateTime(2025, 11, 10).millisecondsSinceEpoch,
      },
      {
        'type': 'expense',
        'commodity': 'Padi',
        'tanggal': '05/11/2025',
        'target': 'Pembelian Bibit',
        'itemPengeluaran': 'Bibit Padi Unggul',
        'namaVendor': 'Toko Pertanian Jaya',
        'kuantitas': '50',
        'satuan': 'kg',
        'harga': '20000',
        'totalHarga': '1000000',
        'amount': 1000000,
        'catatan': 'Pembelian bibit untuk musim tanam',
        'timestamp': DateTime(2025, 11, 5).millisecondsSinceEpoch,
      },
      {
        'type': 'expense',
        'commodity': 'Jagung',
        'tanggal': '08/11/2025',
        'target': 'Pembelian Pupuk',
        'itemPengeluaran': 'Pupuk NPK',
        'namaVendor': 'CV. Pupuk Sejahtera',
        'kuantitas': '40',
        'satuan': 'kg',
        'harga': '30000',
        'totalHarga': '1200000',
        'amount': 1200000,
        'catatan': 'Pembelian pupuk untuk jagung',
        'timestamp': DateTime(2025, 11, 8).millisecondsSinceEpoch,
      },
      {
        'type': 'expense',
        'commodity': 'Cabai',
        'tanggal': '12/11/2025',
        'target': 'Pembelian Pestisida',
        'itemPengeluaran': 'Pestisida Organik',
        'kuantitas': '5',
        'satuan': 'liter',
        'harga': '80000',
        'totalHarga': '400000',
        'amount': 400000,
        'catatan': 'Pestisida untuk cabai',
        'timestamp': DateTime(2025, 11, 12).millisecondsSinceEpoch,
      },
      // Tambahkan data untuk berbagai bulan untuk menampilkan riwayat lengkap
      {
        'type': 'income',
        'commodity': 'Padi',
        'tanggal': '01/12/2025',
        'target': 'Penjualan Padi',
        'kuantitas': '80',
        'satuan': 'kg',
        'harga': '65000',
        'totalHarga': '5200000',
        'amount': 5200000,
        'catatan': 'Penjualan padi desember',
        'timestamp': DateTime(2025, 12, 1).millisecondsSinceEpoch,
      },
      {
        'type': 'expense',
        'commodity': 'Jagung',
        'tanggal': '20/10/2025',
        'target': 'Pembelian Bibit',
        'itemPengeluaran': 'Bibit Jagung Hibrida',
        'namaVendor': 'Toko Bibit Unggul',
        'kuantitas': '30',
        'satuan': 'kg',
        'harga': '25000',
        'totalHarga': '750000',
        'amount': 750000,
        'catatan': 'Persiapan tanam jagung',
        'timestamp': DateTime(2025, 10, 20).millisecondsSinceEpoch,
      },
      {
        'type': 'income',
        'commodity': 'Cabai',
        'tanggal': '28/10/2025',
        'target': 'Penjualan Cabai',
        'kuantitas': '25',
        'satuan': 'kg',
        'harga': '45000',
        'totalHarga': '1125000',
        'amount': 1125000,
        'catatan': 'Penjualan cabai ke pasar induk',
        'timestamp': DateTime(2025, 10, 28).millisecondsSinceEpoch,
      },
      {
        'type': 'income',
        'commodity': 'Padi',
        'tanggal': '15/09/2025',
        'target': 'Penjualan Padi',
        'kuantitas': '120',
        'satuan': 'kg',
        'harga': '58000',
        'totalHarga': '6960000',
        'amount': 6960000,
        'catatan': 'Panen padi musim kemarau',
        'timestamp': DateTime(2025, 9, 15).millisecondsSinceEpoch,
      },
      {
        'type': 'expense',
        'commodity': 'Padi',
        'tanggal': '03/09/2025',
        'target': 'Pembelian Pupuk',
        'itemPengeluaran': 'Pupuk Urea',
        'namaVendor': 'Koperasi Tani Makmur',
        'kuantitas': '60',
        'satuan': 'kg',
        'harga': '15000',
        'totalHarga': '900000',
        'amount': 900000,
        'catatan': 'Pemupukan padi fase vegetatif',
        'timestamp': DateTime(2025, 9, 3).millisecondsSinceEpoch,
      },
    ];
    _calculateCommoditySummary();
  }

  void _calculateCommoditySummary() {
    commoditySummary.clear();

    // Use all transactions without month filtering
    for (var transaction in transactions) {
      final commodity = transaction['commodity'] as String? ??
          transaction['komoditas'] as String? ??
          'Lainnya';
      final amount = (transaction['amount'] as num?)?.toDouble() ??
          double.tryParse(transaction['totalHarga']?.toString() ?? '0') ??
          0.0;
      final type = transaction['type'] as String;

      if (!commoditySummary.containsKey(commodity)) {
        commoditySummary[commodity] = {
          'commodity': commodity,
          'totalIncome': 0.0,
          'totalExpense': 0.0,
          'transactions': <Map<String, dynamic>>[],
        };
      }

      commoditySummary[commodity]!['transactions'].add(transaction);

      if (type == 'income') {
        commoditySummary[commodity]!['totalIncome'] += amount;
      } else {
        commoditySummary[commodity]!['totalExpense'] += amount;
      }
    }
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  List<Map<String, dynamic>> _getAllSortedTransactions() {
    // Sort all transactions by timestamp (newest first)
    final sortedTransactions = List<Map<String, dynamic>>.from(transactions);
    sortedTransactions.sort(
      (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int),
    );
    return sortedTransactions;
  }

  Color _getCommodityColor(String commodity) {
    switch (commodity.toLowerCase()) {
      case 'padi':
        return AppColors.primary;
      case 'jagung':
        return Colors.orange;
      case 'cabai':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _getCommodityIcon(String commodity) {
    switch (commodity.toLowerCase()) {
      case 'padi':
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.grass, color: AppColors.primary, size: 20),
        );
      case 'jagung':
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.eco, color: Colors.orange, size: 20),
        );
      case 'cabai':
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.local_fire_department, color: Colors.red, size: 20),
        );
      default:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.agriculture, color: Colors.blue, size: 20),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedCommodities = commoditySummary.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rincian per Komoditas',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Transaction List
          Expanded(
            child: commoditySummary.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada transaksi',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _getAllSortedTransactions().length,
                    itemBuilder: (context, index) {
                      final transaction = _getAllSortedTransactions()[index];
                      final commodity = transaction['commodity'] as String? ??
                          transaction['komoditas'] as String? ??
                          'Lainnya';
                      final amount =
                          (transaction['amount'] as num?)?.toDouble() ??
                              double.tryParse(
                                transaction['totalHarga']?.toString() ?? '0',
                              ) ??
                              0.0;
                      final type = transaction['type'] as String;
                      final isIncome = type == 'income';
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        transaction['timestamp'],
                      );
                      final formattedDate = DateFormat(
                        'dd/MM/yyyy',
                      ).format(date);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _getCommodityIcon(commodity),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      commodity,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$formattedDate • ${transaction['kuantitas']} ${transaction['satuan']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (!isIncome &&
                                        transaction['itemPengeluaran'] !=
                                            null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Item: ${transaction['itemPengeluaran']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                    if (!isIncome &&
                                        transaction['namaVendor'] != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Vendor: ${transaction['namaVendor']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '${isIncome ? '+' : '-'}${_formatCurrency(amount)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isIncome ? AppColors.primary : Colors.red,
                                ),
                              ),
                            ],
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
}
