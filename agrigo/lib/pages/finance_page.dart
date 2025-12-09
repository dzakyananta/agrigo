import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transaction_form_page.dart';
import 'commodity_detail_page.dart';
import '../services/schedule_service.dart';
import '../services/api_service.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  DateTime selectedDate = DateTime.now();
  Schedule? selectedSchedule;
  List<Schedule> userSchedules = [];

  // Dynamic data that can be updated
  List<Map<String, dynamic>> transactions = [];

  // Helper function to parse amount with Indonesian formatting
  double _parseAmount(dynamic amountValue) {
    // Handle null
    if (amountValue == null) return 0;

    // Handle if already a number
    if (amountValue is num) {
      return amountValue.toDouble();
    }

    // Handle string
    String? amountStr = amountValue.toString();
    if (amountStr.isEmpty) return 0;

    // Remove any non-numeric characters except dots and commas
    String cleanAmount = amountStr.replaceAll(RegExp(r'[^\d.,]'), '');

    // Handle Indonesian style numbers
    if (cleanAmount.contains('.') && cleanAmount.contains(',')) {
      cleanAmount = cleanAmount.replaceAll('.', '');
      cleanAmount = cleanAmount.replaceAll(',', '.');
    } else if (cleanAmount.contains('.') && !cleanAmount.contains(',')) {
      final parts = cleanAmount.split('.');
      final lastLen = parts.isNotEmpty ? parts.last.length : 0;
      if (lastLen == 3) {
        // dots are thousand separators
        cleanAmount = cleanAmount.replaceAll('.', '');
      }
    } else {
      // replace comma with dot if present
      cleanAmount = cleanAmount.replaceAll(',', '.');
    }

    final result = double.tryParse(cleanAmount) ?? 0;
    print('🔢 Parsing amount: $amountValue -> $result');
    return result;
  }

  // Calculate finance data based on selected period/schedule
  Map<String, dynamic> get financeData {
    print('📊 Calculating finance data...');
    print('📊 Total transactions: ${transactions.length}');
    print(
      '📊 Selected schedule: ${selectedSchedule?.komoditas ?? "Semua Transaksi"}',
    );

    List<Map<String, dynamic>> periodTransactions;

    if (selectedSchedule != null) {
      // Filter HANYA berdasarkan komoditas (tidak filter tanggal)
      // Ini agar semua transaksi cabai muncul meski diluar periode schedule
      final scheduleKomoditas = selectedSchedule!.komoditas
          .toLowerCase()
          .trim();

      periodTransactions = transactions.where((t) {
        // Check if matching commodity
        final transactionKomoditas = (t['komoditas']?.toString() ?? '')
            .toLowerCase()
            .trim();
        final transactionTarget = (t['target']?.toString() ?? '')
            .toLowerCase()
            .trim();

        // Match berdasarkan komoditas saja
        // Lebih fleksibel: exact match atau contains
        final isMatchingCommodity =
            transactionKomoditas == scheduleKomoditas ||
            transactionTarget == scheduleKomoditas ||
            transactionKomoditas.contains(scheduleKomoditas) ||
            transactionTarget.contains(scheduleKomoditas) ||
            scheduleKomoditas.contains(transactionKomoditas);

        print(
          '📊 Transaction: ${t['komoditas'] ?? t['target']} | Type: ${t['type']} | Matching: $isMatchingCommodity',
        );

        return isMatchingCommodity;
      }).toList();

      print(
        '📊 Filtered ${periodTransactions.length} transactions for ${selectedSchedule!.komoditas}',
      );
    } else {
      // Show all transactions if no specific schedule selected
      periodTransactions = transactions;
      print('📊 Showing all ${periodTransactions.length} transactions');
    }

    print('📊 Period transactions: ${periodTransactions.length}');

    final incomeTransactions = periodTransactions
        .where((t) => t['type'] == 'income')
        .toList();
    final expenseTransactions = periodTransactions
        .where((t) => t['type'] == 'expense')
        .toList();

    print('📊 Income transactions: ${incomeTransactions.length}');
    print('📊 Expense transactions: ${expenseTransactions.length}');

    final totalIncome = incomeTransactions.fold<double>(0, (sum, t) {
      final amount = _parseAmount(t['totalHarga']);
      print('📊 Adding income: ${t['komoditas']} = Rp $amount');
      return sum + amount;
    });
    final totalExpense = expenseTransactions.fold<double>(0, (sum, t) {
      final amount = _parseAmount(t['totalHarga']);
      print('📊 Adding expense: ${t['target']} = Rp $amount');
      return sum + amount;
    });

    print('📊 Total Income: Rp $totalIncome');
    print('📊 Total Expense: Rp $totalExpense');
    print('📊 Profit/Loss: Rp ${totalIncome - totalExpense}');

    // Group by commodity
    final incomeByCategory = <String, double>{};
    final expenseByCategory = <String, double>{};

    for (var transaction in incomeTransactions) {
      final komoditas = transaction['komoditas'] ?? 'Lainnya';
      incomeByCategory[komoditas] =
          (incomeByCategory[komoditas] ?? 0) +
          _parseAmount(transaction['totalHarga']);
    }

    for (var transaction in expenseTransactions) {
      final target = transaction['target'] ?? 'Lainnya';
      expenseByCategory[target] =
          (expenseByCategory[target] ?? 0) +
          _parseAmount(transaction['totalHarga']);
    }

    final colors = [
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.blue,
      Colors.purple,
      Colors.amber,
      Colors.teal,
      Colors.pink,
    ];

    return {
      'totalProfitLoss': (totalIncome - totalExpense).toInt(),
      'totalIncome': totalIncome.toInt(),
      'totalExpense': totalExpense.toInt(),
      'incomeCategories': incomeByCategory.entries.map((e) {
        final index = incomeByCategory.keys.toList().indexOf(e.key);
        return {
          'name': e.key,
          'amount': e.value.toInt(),
          'color': colors[index % colors.length],
        };
      }).toList(),
      'expenseCategories': expenseByCategory.entries.map((e) {
        final index = expenseByCategory.keys.toList().indexOf(e.key);
        return {
          'name': e.key,
          'amount': e.value.toInt(),
          'color': colors[index % colors.length],
        };
      }).toList(),
    };
  }

  @override
  void initState() {
    super.initState();
    _loadTransactionsFromStorage();
    _loadUserSchedules();
  }

  Future<void> _loadUserSchedules() async {
    final schedules = await ScheduleService.getSchedules();
    setState(() {
      userSchedules = schedules;
    });
  }

  Future<void> _loadTransactionsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('finance_transactions');

    if (transactionsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(transactionsJson);
        setState(() {
          transactions = decoded.cast<Map<String, dynamic>>();
        });
        print('✅ Loaded ${transactions.length} transactions from storage');
        // Debug: print transactions
        for (var t in transactions) {
          print(
            'Transaction: ${t['komoditas']} - ${t['type']} - ${t['totalHarga']}',
          );
        }
      } catch (e) {
        print('⚠️ Error loading transactions: $e');
        setState(() {
          transactions = [];
        });
      }
    } else {
      print('ℹ️ No saved transactions found');
      setState(() {
        transactions = [];
      });
    }
  }

  Future<void> _saveTransactionsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = jsonEncode(transactions);
      await prefs.setString('finance_transactions', transactionsJson);
      print('✅ Saved ${transactions.length} transactions to storage');
    } catch (e) {
      print('⚠️ Error saving transactions: $e');
    }
  }

  Future<void> _addTransaction(Map<String, dynamic> transaction) async {
    try {
      // Simpan langsung ke local storage (offline mode)
      print('💾 Saving transaction offline...');

      // Convert API format to local display format
      final localTransaction = {
        'type': transaction['type'],
        'komoditas': transaction['commodity_name'],
        'tanggal': DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.parse(transaction['date'])),
        'target': transaction['source'] ?? '-',
        'totalHarga': transaction['amount'].toString(),
        'catatan': transaction['description'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      setState(() {
        transactions.add(localTransaction);
      });
      await _saveTransactionsToStorage();

      print('✅ Transaction saved offline successfully');
    } catch (e) {
      print('❌ Error saving transaction: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _deleteTransaction(int index) async {
    setState(() {
      transactions.removeAt(index);
    });
    await _saveTransactionsToStorage();
  }

  void _loadSampleData() {
    // Deprecated - data now loaded from storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Keuangan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),
            const SizedBox(height: 16),

            // Total Savings Card
            _buildTotalProfitLossCard(),
            const SizedBox(height: 24),

            // Income and Expense Summary
            _buildIncomeExpenseSummary(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 24),

            // Recent Transactions
            if (transactions.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildRecentTransactions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Periode Analisis',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showPeriodPicker(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            selectedSchedule == null
                                ? 'Semua Transaksi'
                                : '${selectedSchedule!.komoditas} (${DateFormat('dd MMM yy').format(selectedSchedule!.startDate)} - ${DateFormat('dd MMM yy').format(selectedSchedule!.endDate)})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.green.shade700,
                          size: 20,
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
    );
  }

  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Pilih Periode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade50,
                      child: Icon(
                        Icons.all_inclusive,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Semua Transaksi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Tampilkan semua data'),
                    trailing: selectedSchedule == null
                        ? Icon(Icons.check_circle, color: Colors.green.shade700)
                        : null,
                    onTap: () {
                      setState(() => selectedSchedule = null);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey[100]),
                  ...userSchedules.map((schedule) {
                    final isSelected = selectedSchedule == schedule;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(
                          schedule.status,
                        ).withOpacity(0.1),
                        child: Icon(
                          Icons.eco_rounded,
                          color: _getStatusColor(schedule.status),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        schedule.komoditas,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${DateFormat('dd MMM yyyy').format(schedule.startDate)} - ${DateFormat('dd MMM yyyy').format(schedule.endDate)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  schedule.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                schedule.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(schedule.status),
                                ),
                              ),
                            ),
                      onTap: () {
                        setState(() => selectedSchedule = schedule);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Akan Datang':
        return Colors.blue;
      case 'Sedang Berlangsung':
        return Colors.green;
      case 'Selesai':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTotalProfitLossCard() {
    final profitLoss = financeData['totalProfitLoss'] as int;
    final isProfit = profitLoss >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit
              ? [
                  const Color(0xFF4CAF50),
                  const Color(0xFF45A049),
                ] // Green for profit
              : [
                  const Color(0xFFf44336),
                  const Color(0xFFd32f2f),
                ], // Red for loss
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? Colors.green : Colors.red).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isProfit ? Icons.trending_up : Icons.trending_down,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Laba/Rugi',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (selectedSchedule != null)
                      Text(
                        selectedSchedule!.komoditas,
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
          const SizedBox(height: 8),
          Text(
            '${isProfit ? '+' : ''}Rp ${NumberFormat('#,###', 'en_US').format(profitLoss)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total\nPemasukan',
            financeData['totalIncome'],
            Colors.blue[600]!,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total\nPengeluaran',
            financeData['totalExpense'],
            Colors.red[600]!,
            Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    int amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${NumberFormat('#,###', 'en_US').format(amount)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Pemasukan',
                  Colors.green,
                  Icons.add_circle_outline,
                  () => _showTransactionDetail('income'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Pengeluaran',
                  Colors.red,
                  Icons.remove_circle_outline,
                  () => _showTransactionDetail('expense'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(String type) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => TransactionFormPage(type: type)),
    );

    if (result != null) {
      await _addTransaction(result);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                type == 'income' ? Icons.check_circle : Icons.info_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type == 'income'
                      ? 'Pemasukan berhasil disimpan!'
                      : 'Pengeluaran berhasil disimpan!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: type == 'income' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildRecentTransactions() {
    // Filter transactions based on selected schedule
    List<Map<String, dynamic>> filteredTransactions;

    if (selectedSchedule != null) {
      // Filter HANYA berdasarkan komoditas (tidak filter tanggal)
      final scheduleKomoditas = selectedSchedule!.komoditas
          .toLowerCase()
          .trim();

      filteredTransactions = transactions.where((t) {
        // Check commodity match
        final transactionKomoditas = (t['komoditas']?.toString() ?? '')
            .toLowerCase()
            .trim();
        final transactionTarget = (t['target']?.toString() ?? '')
            .toLowerCase()
            .trim();

        final isMatchingCommodity =
            transactionKomoditas == scheduleKomoditas ||
            transactionTarget == scheduleKomoditas ||
            transactionKomoditas.contains(scheduleKomoditas) ||
            transactionTarget.contains(scheduleKomoditas) ||
            scheduleKomoditas.contains(transactionKomoditas);

        return isMatchingCommodity;
      }).toList();
    } else {
      // Filter by selected month only
      filteredTransactions = transactions.where((t) {
        final transactionDate = DateTime.fromMillisecondsSinceEpoch(
          t['timestamp'],
        );
        return transactionDate.month == selectedDate.month &&
            transactionDate.year == selectedDate.year;
      }).toList();
    }

    // Sort filtered transactions by timestamp (newest first)
    final sortedTransactions = List<Map<String, dynamic>>.from(
      filteredTransactions,
    )..sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));

    // Take only the latest 5 transactions
    final recentTransactions = sortedTransactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedSchedule != null
                  ? 'Rincian ${selectedSchedule!.komoditas}'
                  : 'Rincian per komoditas',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommodityDetailPage(),
                  ),
                );
              },
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: const Center(
              child: Text(
                'Belum ada transaksi untuk bulan ini',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          )
        else
          ...recentTransactions
              .map((transaction) => _buildTransactionItem(transaction))
              .toList(),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isIncome = transaction['type'] == 'income';
    final date = DateTime.fromMillisecondsSinceEpoch(transaction['timestamp']);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final transactionIndex = transactions.indexOf(transaction);

    // Improved amount parsing - handle both String and num types
    double amount = 0;
    final totalHarga = transaction['totalHarga'];

    if (totalHarga != null) {
      if (totalHarga is String && totalHarga.isNotEmpty) {
        // Remove any non-numeric characters except dots and commas
        String cleanAmount = totalHarga.replaceAll(RegExp(r'[^\d.,]'), '');

        // Handle Indonesian style numbers:
        // - If contains both '.' and ',' then '.' are thousands and ',' is decimal -> remove '.' and replace ',' with '.'
        // - If contains only '.' and the last group length is 3 it's likely thousands (remove '.')
        // - Otherwise, treat '.' as decimal point
        if (cleanAmount.contains('.') && cleanAmount.contains(',')) {
          cleanAmount = cleanAmount.replaceAll('.', '');
          cleanAmount = cleanAmount.replaceAll(',', '.');
        } else if (cleanAmount.contains('.') && !cleanAmount.contains(',')) {
          final parts = cleanAmount.split('.');
          final lastLen = parts.isNotEmpty ? parts.last.length : 0;
          if (lastLen == 3) {
            // dots are thousand separators
            cleanAmount = cleanAmount.replaceAll('.', '');
          }
          // else keep dot as decimal separator
        } else {
          // replace comma with dot if present (e.g. "6,5")
          cleanAmount = cleanAmount.replaceAll(',', '.');
        }

        amount = double.tryParse(cleanAmount) ?? 0;
      } else if (totalHarga is num) {
        amount = totalHarga.toDouble();
      }
    }

    // Fallback: if totalHarga is 0 or null, try to calculate from harga * kuantitas
    if (amount == 0) {
      final harga = transaction['harga'];
      final kuantitas = transaction['kuantitas'];

      if (harga != null && kuantitas != null) {
        double hargaValue = 0;
        if (harga is String && harga.isNotEmpty) {
          String cleanHarga = harga.replaceAll(RegExp(r'[^\d.,]'), '');
          if (cleanHarga.contains('.') && cleanHarga.contains(',')) {
            cleanHarga = cleanHarga.replaceAll('.', '');
            cleanHarga = cleanHarga.replaceAll(',', '.');
          } else if (cleanHarga.contains('.') && !cleanHarga.contains(',')) {
            final partsH = cleanHarga.split('.');
            final lastLenH = partsH.isNotEmpty ? partsH.last.length : 0;
            if (lastLenH == 3) {
              cleanHarga = cleanHarga.replaceAll('.', '');
            }
          } else {
            cleanHarga = cleanHarga.replaceAll(',', '.');
          }
          hargaValue = double.tryParse(cleanHarga) ?? 0;
        } else if (harga is num) {
          hargaValue = harga.toDouble();
        }
        final kuantitasValue = (kuantitas is String)
            ? double.tryParse(kuantitas.replaceAll(RegExp(r'[^\d.,]'), '')) ?? 0
            : (kuantitas is num)
            ? kuantitas.toDouble()
            : 0;

        if (hargaValue > 0 && kuantitasValue > 0) {
          amount = (hargaValue * kuantitasValue).toDouble();
        }
      }
    }

    return Dismissible(
      key: Key('transaction_$transactionIndex'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Hapus Transaksi?'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await _deleteTransaction(transactionIndex);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Transaksi berhasil dihapus',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isIncome ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                color: isIncome ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['komoditas'] ??
                        transaction['target'] ??
                        'Transaksi',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (transaction['kuantitas'] != null &&
                          transaction['kuantitas'].toString().isNotEmpty) ...[
                        Text(
                          ' • ${transaction['kuantitas']} ${transaction['satuan'] ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (transaction['itemPengeluaran'] != null &&
                      transaction['itemPengeluaran'].toString().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Item: ${transaction['itemPengeluaran']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (transaction['namaVendor'] != null &&
                      transaction['namaVendor'].toString().isNotEmpty) ...[
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}Rp ${NumberFormat('#,###', 'en_US').format(amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '← Geser hapus',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
