import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _status = 'Belum dicoba';
  bool _isLoading = false;
  List<dynamic> _commodities = [];
  List<dynamic> _transactions = [];

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
    });

    try {
      // Test 1: Get Commodities (tidak perlu token)
      final commodities = await ApiService.getCommodities();
      
      setState(() {
        _commodities = commodities;
        _status = '✅ Connection SUCCESS!\n${commodities.length} komoditas ditemukan';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Connection FAILED!\n\nError: $e\n\nPastikan:\n1. Laravel server running (php artisan serve)\n2. Base URL sesuai (10.0.2.2:8000 untuk emulator)\n3. Database sudah di-migrate';
        _isLoading = false;
      });
    }
  }

  Future<void> _testTransactions() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading transactions...';
    });

    try {
      final transactions = await ApiService.getTransactions();
      
      setState(() {
        _transactions = transactions;
        _status = '✅ Transactions loaded!\n${transactions.length} transaksi ditemukan';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed!\n\nError: $e\n\nNote: Endpoint ini butuh authentication token';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Base URL Info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laravel API Base URL:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ApiService.baseUrl,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tips:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('• Emulator: 10.0.2.2:8000'),
                    const Text('• Physical device: IP network Anda'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testConnection,
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Test Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testTransactions,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Test Transactions (Need Token)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Text(_status),
                  ],
                ),
              ),
            ),

            // Commodities List
            if (_commodities.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Komoditas:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _commodities.length,
                itemBuilder: (context, index) {
                  final commodity = _commodities[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.agriculture, color: Colors.green),
                      title: Text(commodity['name'] ?? 'Unknown'),
                      subtitle: Text(commodity['type'] ?? ''),
                      trailing: Text('#${commodity['id']}'),
                    ),
                  );
                },
              ),
            ],

            // Transactions List
            if (_transactions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Transaksi:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  final isIncome = transaction['type'] == 'income';
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                      title: Text(transaction['description'] ?? 'No description'),
                      subtitle: Text(transaction['date'] ?? ''),
                      trailing: Text(
                        'Rp ${transaction['amount']}',
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
