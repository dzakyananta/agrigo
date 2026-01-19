import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../services/user_data_store.dart';
import 'package:intl/intl.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  bool _loading = true;
  int totalIncome = 0;
  int totalExpense = 0;
  List<dynamic> _transactions = [];
  List<String> commodityOptions = ['Semua Komoditas'];
  String selectedCommodity = 'Semua Komoditas';
  List<String> periodOptions = [];
  String selectedPeriod = '${DateTime.now().year}';
  List<String> scheduleOptions = ['Semua Jadwal'];
  String selectedSchedule = 'Semua Jadwal';
  bool showIncome = true;
  bool showExpense = true;
  bool showProductivity = true;
  List<String> months = [];
  List<String> monthsShort = [];
  List<double> incomeByMonth = [];
  List<double> expenseByMonth = [];
  List<Map<String, dynamic>> commodityStats = [];
  // Additional computed metrics
  int txCount = 0;
  double avgIncomePerTx = 0.0;
  double avgExpensePerTx = 0.0;
  num totalProfit = 0;
  double profitMargin = 0.0;
  Map<String, Map<String, num>> scheduleTotals =
      {}; // scheduleId/name -> {income, expense}

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
    // Failsafe: if still loading after 12s, stop spinner to avoid infinite loading
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted && _loading) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _loading = true;
    });

    try {
      // Try API first (preferred). API returns summary and transactions endpoints.
      // get summary with short timeout and safe fallback
      final summary = await ApiService.getTransactionSummary().timeout(
          const Duration(seconds: 8),
          onTimeout: () => <String, dynamic>{});
      // summary is expected to contain keys like 'income' and 'expense'
      if (summary != null) {
        totalIncome = _safeToInt(summary['income']);
        totalExpense = _safeToInt(summary['expense']);
      }

      // Fetch transactions with timeout and compute series
      List<dynamic> txList = <dynamic>[];
      try {
        final remote = await ApiService.getTransactions()
            .timeout(const Duration(seconds: 10), onTimeout: () => <dynamic>[]);
        if (remote is List && remote.isNotEmpty) txList = remote;
      } catch (_) {
        // ignore - we'll fallback to local
      }

      // If remote returned empty, try per-user storage then global SharedPreferences
      if (txList.isEmpty) {
        final uid = FirebaseService.userId;
        if (uid != null) {
          final userList = await UserDataStore.instance
              .loadList(uid, 'finance_transactions');
          if (userList.isNotEmpty) txList = userList;
          // IMPORTANT: do NOT fall back to global shared prefs when a user is signed in.
          // New users should start with empty data; only guests (uid==null) use global prefs.
        } else {
          final prefs = await SharedPreferences.getInstance();
          final raw = prefs.getString('finance_transactions') ??
              prefs.getString('finance_tx') ??
              '';
          if (raw.isNotEmpty) {
            try {
              final parsed = json.decode(raw);
              if (parsed is List) txList = parsed;
            } catch (e) {
              // sometimes it's stored as JSON string of list of maps
              try {
                final fallback = json.decode('[' + raw + ']');
                if (fallback is List) txList = fallback;
              } catch (_) {}
            }
          }
        }
      }

      // store transactions for further filtering in UI
      _transactions = txList;

      // populate commodity options from transactions
      final Set<String> opts = {'Semua Komoditas'};
      for (var t in _transactions) {
        final name = (t['commodity_name'] ?? t['komoditas'] ?? '').toString();
        if (name.isNotEmpty) opts.add(name);
      }
      commodityOptions = opts.toList();

      // populate schedule options from transactions
      final Set<String> sopts = {'Semua Jadwal'};
      for (var t in _transactions) {
        final scheduleKey = (t['schedule'] ??
                t['jadwal'] ??
                t['schedule_id'] ??
                t['id_jadwal'] ??
                t['schedule_name'] ??
                t['nama_jadwal'] ??
                '')
            .toString();
        if (scheduleKey.isNotEmpty) sopts.add(scheduleKey);
      }
      scheduleOptions = sopts.toList();

      _computeSeriesFromTransactions(_transactions);

      // compute additional metrics from the full set initially
      _computeMetrics(_transactions);

      // If API summary didn't provide totals, compute from series
      final double totalIncomeDouble =
          incomeByMonth.fold(0.0, (prev, e) => prev + e);
      final double totalExpenseDouble =
          expenseByMonth.fold(0.0, (prev, e) => prev + e);
      if (totalIncome == 0 && totalIncomeDouble > 0)
        totalIncome = totalIncomeDouble.toInt();
      if (totalExpense == 0 && totalExpenseDouble > 0)
        totalExpense = totalExpenseDouble.toInt();

      // Try to fetch commodity list to show productivity-like stats; if not, compute from txs
      List<dynamic> commodities = <dynamic>[];
      try {
        final remoteCom = await ApiService.getCommodities()
            .timeout(const Duration(seconds: 8), onTimeout: () => <dynamic>[]);
        if (remoteCom is List) commodities = remoteCom;
      } catch (_) {}

      _computeCommodityStats(commodities, txList);
    } catch (e) {
      // If API fails, fall back to empty state but don't crash
      debugPrint('Analysis load failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _computeSeriesFromTransactions(List<dynamic> txList) {
    // If a specific year is selected, show 12 months for that year;
    // otherwise default to last 6 months.
    final now = DateTime.now();
    final yearMatch = RegExp(r'^\d{4}\$');
    if (yearMatch.hasMatch(selectedPeriod)) {
      final year = int.tryParse(selectedPeriod) ?? now.year;
      monthsShort = List.generate(12, (i) {
        final dt = DateTime(year, i + 1);
        try {
          return DateFormat('MMM', 'id').format(dt);
        } catch (_) {
          return _shortMonth(dt.month);
        }
      });
      months = List.filled(12, year.toString());
      incomeByMonth = List.filled(12, 0.0);
      expenseByMonth = List.filled(12, 0.0);
    } else {
      // Prepare last 6 months labels
      months = List.generate(6, (i) {
        final dt = DateTime(now.year, now.month - (5 - i));
        // store year only (e.g., 2026)
        try {
          return DateFormat('yyyy').format(dt);
        } catch (_) {
          return dt.year.toString();
        }
      });
      monthsShort = List.generate(6, (i) {
        final dt = DateTime(now.year, now.month - (5 - i));
        try {
          return DateFormat('MMM', 'id').format(dt);
        } catch (_) {
          return _shortMonth(dt.month);
        }
      });
      incomeByMonth = List.filled(6, 0.0);
      expenseByMonth = List.filled(6, 0.0);
    }

    for (var t in txList) {
      try {
        final dateStr = t['date'] ?? t['tanggal'] ?? t['created_at'] ?? '';
        DateTime dt;
        if (dateStr is int) {
          dt = DateTime.fromMillisecondsSinceEpoch(dateStr);
        } else if (dateStr is String && dateStr.isNotEmpty) {
          try {
            dt = DateTime.parse(dateStr);
          } catch (_) {
            // try common local format used by FinancePage: dd/MM/yyyy
            try {
              dt = DateFormat('dd/MM/yyyy').parse(dateStr);
            } catch (_) {
              // try dd/MM/yyyy HH:mm
              try {
                dt = DateFormat('dd/MM/yyyy HH:mm').parse(dateStr);
              } catch (_) {
                continue;
              }
            }
          }
        } else if (t['date'] is Map && t['date']['_seconds'] != null) {
          // Firestore timestamp map
          dt = DateTime.fromMillisecondsSinceEpoch(
              (t['date']['_seconds'] * 1000).toInt());
        } else {
          continue;
        }

        final monthIndex = _monthIndexFromDate(dt);
        if (monthIndex < 0 || monthIndex >= incomeByMonth.length) continue;

        final type = (t['type'] ?? t['jenis'] ?? 'income').toString();
        final amountRaw =
            t['amount'] ?? t['totalHarga'] ?? t['total'] ?? t['amount_rp'];
        final amount = _parseAmount(amountRaw);

        if (type == 'expense') {
          expenseByMonth[monthIndex] += amount;
        } else {
          incomeByMonth[monthIndex] += amount;
        }
      } catch (e) {
        // ignore individual parse errors
      }
    }
  }

  void _applyFilters() {
    // Filter by commodity and period then recompute series and commodity stats
    List<dynamic> filtered = _transactions;

    if (selectedCommodity.isNotEmpty &&
        selectedCommodity != 'Semua Komoditas') {
      filtered = filtered.where((t) {
        final name = (t['commodity_name'] ?? t['komoditas'] ?? '').toString();
        return name == selectedCommodity;
      }).toList();
    }

    // period filter: per-year selection or 'Semua'
    if (selectedPeriod != 'Semua' && filtered.isNotEmpty) {
      final yearMatch = RegExp(r'^\d{4}\$');
      if (yearMatch.hasMatch(selectedPeriod)) {
        final year = int.tryParse(selectedPeriod) ?? DateTime.now().year;
        filtered = filtered.where((t) {
          try {
            final dateStr = t['date'] ?? t['tanggal'] ?? t['created_at'] ?? '';
            DateTime dt;
            if (dateStr is int)
              dt = DateTime.fromMillisecondsSinceEpoch(dateStr);
            else if (dateStr is String && dateStr.isNotEmpty)
              dt = DateTime.tryParse(dateStr) ??
                  DateFormat('dd/MM/yyyy').parse(dateStr);
            else if (t['date'] is Map && t['date']['_seconds'] != null)
              dt = DateTime.fromMillisecondsSinceEpoch(
                  (t['date']['_seconds'] * 1000).toInt());
            else
              return false;
            return dt.year == year;
          } catch (_) {
            return false;
          }
        }).toList();
      }
    }

    // recompute series and totals from filtered
    _computeSeriesFromTransactions(filtered);

    // recompute additional metrics from filtered
    _computeMetrics(filtered);

    // recompute totals
    totalIncome = incomeByMonth.fold(0, (p, e) => p + e.toInt());
    totalExpense = expenseByMonth.fold(0, (p, e) => p + e.toInt());

    // commodity stats should reflect filtered set
    _computeCommodityStats([], filtered);
    setState(() {});
  }

  void _computeCommodityStats(List<dynamic> commodities, List<dynamic> txList) {
    // Map commodity id/name to total income (as a proxy for productivity)
    final Map<String, double> totals = {};

    for (var t in txList) {
      final name =
          (t['commodity_name'] ?? t['komoditas'] ?? 'Lainnya').toString();
      final type = (t['type'] ?? 'income').toString();
      if (type != 'income') continue;
      final amount = _parseAmount(t['amount'] ?? t['totalHarga']);
      totals[name] = (totals[name] ?? 0) + amount;
    }

    // Convert top 3 commodities into display rows
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    commodityStats = sorted.take(3).map((e) {
      final progress =
          (sorted.isEmpty) ? 0.0 : (e.value / (sorted.first.value + 1));
      return {
        'name': e.key,
        'value': e.value,
        'progress': progress.clamp(0.0, 1.0),
      };
    }).toList();
  }

  void _computeMetrics(List<dynamic> txList) {
    // reset
    txCount = 0;
    avgIncomePerTx = 0.0;
    avgExpensePerTx = 0.0;
    totalProfit = 0;
    profitMargin = 0.0;
    scheduleTotals = {};

    if (txList.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    double incomeSum = 0.0;
    double expenseSum = 0.0;
    int incomeCount = 0;
    int expenseCount = 0;

    for (var t in txList) {
      try {
        final type = (t['type'] ?? t['jenis'] ?? 'income').toString();
        final amount = _parseAmount(
            t['amount'] ?? t['totalHarga'] ?? t['total'] ?? t['amount_rp']);

        // schedule/key detection
        String scheduleKey = (t['schedule'] ??
                t['jadwal'] ??
                t['schedule_id'] ??
                t['id_jadwal'] ??
                '')
            .toString();
        if (scheduleKey.isEmpty) {
          // try to derive readable name
          scheduleKey =
              (t['schedule_name'] ?? t['nama_jadwal'] ?? 'Umum').toString();
        }

        final entry =
            scheduleTotals[scheduleKey] ?? {'income': 0, 'expense': 0};

        if (type == 'expense') {
          expenseSum += amount;
          expenseCount++;
          entry['expense'] = (entry['expense'] ?? 0) + amount;
        } else {
          incomeSum += amount;
          incomeCount++;
          entry['income'] = (entry['income'] ?? 0) + amount;
        }

        scheduleTotals[scheduleKey] = entry;
        txCount++;
      } catch (_) {
        // ignore bad rows
      }
    }

    avgIncomePerTx = incomeCount > 0 ? (incomeSum / incomeCount) : 0.0;
    avgExpensePerTx = expenseCount > 0 ? (expenseSum / expenseCount) : 0.0;
    totalProfit = (incomeSum - expenseSum).toInt();
    profitMargin = incomeSum > 0 ? ((incomeSum - expenseSum) / incomeSum) : 0.0;

    if (mounted) setState(() {});
  }

  int _monthIndexFromDate(DateTime dt) {
    // If months is a full year (12 entries), index is month-1
    if (months.length == 12) return dt.month - 1;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 5);
    final monthsDiff = (dt.year - start.year) * 12 + (dt.month - start.month);
    return monthsDiff;
  }

  String _shortMonth(int m) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return labels[(m - 1) % 12];
  }

  double _parseAmount(dynamic v) {
    // Use the same robust parsing as FinancePage to handle Indonesian formats
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();

    String amountStr = v.toString();
    if (amountStr.isEmpty) return 0.0;

    // Remove non-numeric except dot and comma
    String clean = amountStr.replaceAll(RegExp(r'[^0-9.,]'), '');

    if (clean.contains('.') && clean.contains(',')) {
      // assume dot thousand separators, comma decimal
      clean = clean.replaceAll('.', '');
      clean = clean.replaceAll(',', '.');
    } else if (clean.contains('.') && !clean.contains(',')) {
      final parts = clean.split('.');
      final lastLen = parts.isNotEmpty ? parts.last.length : 0;
      if (lastLen == 3) {
        // dots are thousand separators
        clean = clean.replaceAll('.', '');
      }
      // else leave dot as decimal separator
    } else {
      // replace comma with dot if present
      clean = clean.replaceAll(',', '.');
    }

    return double.tryParse(clean) ?? 0.0;
  }

  int _safeToInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    final s = v.toString().replaceAll(RegExp(r'[^0-9-]'), '');
    return int.tryParse(s) ?? 0;
  }

  String _formatRp(num value) {
    final intVal = value.toInt();
    return 'Rp${intVal.toString()}';
  }

  String _formatRpCompact(num value) {
    try {
      final nf = NumberFormat.compact(locale: 'id');
      return 'Rp${nf.format(value)}';
    } catch (_) {
      return _formatRp(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Custom header placed directly under status bar to eliminate gap
                Builder(builder: (ctx) {
                  final top = MediaQuery.of(ctx).padding.top;
                  return Container(
                    color: Colors.white,
                    height: top + 44,
                    padding: EdgeInsets.only(top: top, left: 8, right: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black87),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text('Analisis',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20)),
                          ),
                        ),
                        // spacer to balance the back button
                        const SizedBox(width: 48),
                      ],
                    ),
                  );
                }),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filters row with commodity & period dropdowns + metric chips
                        Row(children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade200)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedCommodity,
                                  items: commodityOptions
                                      .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600))))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      selectedCommodity = v;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade200)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedPeriod,
                                  items: (['Semua'] +
                                          List.generate(
                                              6,
                                              (i) => (DateTime.now().year - i)
                                                  .toString()))
                                      .map((p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(p,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600))))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      selectedPeriod = v;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ),
                            ),
                          )
                        ]),

                        const SizedBox(height: 12),

                        // Metric toggles removed per request (icons above totals)
                        const SizedBox.shrink(),

                        const SizedBox(height: 16),

                        // Summary cards
                        Row(children: [
                          Expanded(
                              child: _summaryCard('Total Pendapatan',
                                  _formatRp(totalIncome), true)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _summaryCard('Total Biaya',
                                  _formatRp(totalExpense), false)),
                        ]),

                        const SizedBox(height: 18),

                        const Text('Produktivitas per Komoditas',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6)
                                ]),
                            child: Column(
                                children: commodityStats.isNotEmpty
                                    ? commodityStats
                                        .map((c) => Column(children: [
                                              _buildCommodityRow(
                                                  c['name'],
                                                  c['progress'],
                                                  _formatRp(c['value'])),
                                              const SizedBox(height: 8)
                                            ]))
                                        .toList()
                                    : [
                                        _buildCommodityRow(
                                            'Tidak ada data', 0.0, '-')
                                      ])),

                        const SizedBox(height: 18),

                        const Text('Pendapatan vs Biaya',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),

                        // Simple grouped bar chart using computed series (horizontally scrollable)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6)
                              ]),
                          height: 260,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Legend
                                Row(children: [
                                  // small color markers only (no text)
                                  Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF3CB043),
                                          borderRadius:
                                              BorderRadius.circular(2))),
                                  const SizedBox(width: 8),
                                  Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(2))),
                                  const Spacer(),
                                  // Totals summary on the right (compact) - keep on single line
                                  Row(children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              _formatRpCompact(incomeByMonth
                                                  .fold(0.0, (p, e) => p + e)),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700)),
                                          Text('Pendapatan',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12))
                                        ]),
                                    const SizedBox(width: 16),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              _formatRpCompact(expenseByMonth
                                                  .fold(0.0, (p, e) => p + e)),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.red)),
                                          Text('Biaya',
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12))
                                        ]),
                                  ]),
                                ]),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children:
                                          List.generate(months.length, (index) {
                                        final combined = <double>[]
                                          ..addAll(incomeByMonth)
                                          ..addAll(expenseByMonth);
                                        final maxVal = combined.isEmpty
                                            ? 0.0
                                            : combined.reduce(
                                                (a, b) => a > b ? a : b);
                                        final maxBarHeight = 160.0;
                                        final greenH = maxVal == 0
                                            ? 0.0
                                            : (incomeByMonth[index] / maxVal) *
                                                maxBarHeight;
                                        final redH = maxVal == 0
                                            ? 0.0
                                            : (expenseByMonth[index] / maxVal) *
                                                maxBarHeight;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                // fixed-height area so all bars share same baseline
                                                Container(
                                                  width: 48,
                                                  height: maxBarHeight,
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      if (showIncome)
                                                        Container(
                                                            width: 12,
                                                            height: greenH,
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                    0xFF3CB043),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6))),
                                                      if (showIncome)
                                                        const SizedBox(
                                                            width: 6),
                                                      if (showExpense)
                                                        Container(
                                                            width: 12,
                                                            height: redH,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6))),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                // small month abbrev
                                                Text(monthsShort[index],
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors
                                                            .grey.shade600)),
                                                // year label
                                                Text(months[index],
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ]),
                                        );
                                      }),
                                    ),
                                  ),
                                )
                              ]),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryCard(String title, String value, bool positive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityRow(String name, double progress, String value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF3CB043)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
