import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionFormPage extends StatefulWidget {
  final String type; // 'income' or 'expense'

  const TransactionFormPage({super.key, required this.type});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _tanggalController = TextEditingController();
  final _targetController = TextEditingController();
  final _sumberPengeluaranController = TextEditingController();
  final _itemPengeluaranController = TextEditingController();
  final _kuantitasController = TextEditingController();
  final _hargaController = TextEditingController();
  final _totalHargaController = TextEditingController();
  final _catatanController = TextEditingController();
  final _deskripsiController = TextEditingController();

  // Dropdown values
  String? selectedKomoditas;
  String? selectedTarget;
  String? selectedSumberPengeluaran;
  String? selectedItemPengeluaran;
  String? selectedSatuan;

  // Date
  DateTime? selectedDate;

  // Upload files
  List<String> uploadedFiles = [];

  // Commodity options
  List<String> komoditasOptions = [
    'Padi',
    'Jagung',
    'Cabai',
    'Tomat',
    'Singkong',
    'Kedelai',
    'Kacang Tanah',
    'Ubi Jalar',
    'Bayam',
    'Kangkung',
  ];

  // Satuan options
  final List<String> satuanOptions = [
    'Kg',
    'Ton',
    'Gram',
    'Kuintal',
    'Liter',
    'Karung',
    'Ikat',
    'Buah',
  ];

  // Harga options (per kg)
  final List<String> hargaOptions = [
    '1000',
    '2000',
    '3000',
    '4000',
    '5000',
    '7500',
    '10000',
    '15000',
    '20000',
    '25000',
  ];

  // Target options for income
  final List<String> targetPemasukanOptions = [
    'Panen Padi',
    'Panen Jagung',
    'Panen Cabai',
    'Panen Tomat',
    'Panen Singkong',
    'Panen Kedelai',
    'Panen Kacang Tanah',
    'Panen Ubi Jalar',
    'Panen Bayam',
    'Panen Kangkung',
    'Penjualan Bibit',
    'Penjualan Pupuk',
    'Konsultasi Pertanian',
    'Sewa Lahan',
    'Jasa Pengolahan',
    'Penjualan Alat Pertanian',
  ];

  // Source options for expense
  final List<String> sumberPengeluaranOptions = [
    'Pembelian Bibit',
    'Pembelian Pupuk',
    'Pembelian Pestisida',
    'Sewa Alat',
    'Upah Pekerja',
    'Biaya Transportasi',
  ];

  // Item options for expense
  final List<String> itemPengeluaranOptions = [
    'Bibit Padi Unggul',
    'Bibit Jagung Hibrida',
    'Bibit Cabai',
    'Bibit Tomat',
    'Pupuk Urea',
    'Pupuk NPK',
    'Pupuk Kompos',
    'Pestisida Organik',
    'Insektisida',
    'Fungisida',
    'Herbisida',
    'Traktor Mini',
    'Cangkul',
    'Sabit',
    'Sprayer',
    'Selang Air',
  ];

  @override
  void initState() {
    super.initState();
    _tanggalController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _targetController.dispose();
    _sumberPengeluaranController.dispose();
    _itemPengeluaranController.dispose();
    _kuantitasController.dispose();
    _hargaController.dispose();
    _totalHargaController.dispose();
    _catatanController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';
    final title = isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran';
    final buttonColor = isIncome ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Komoditas Terkait
              _buildSectionTitle(
                isIncome ? 'Komoditas' : 'Komoditas Terkait',
                isRequired: true,
              ),
              _buildKomoditasSelector(),
              const SizedBox(height: 16),

              // Tanggal
              _buildSectionTitle('Tanggal', isRequired: true),
              _buildDateField(),
              const SizedBox(height: 16),

              // Target (for income) / Sumber Pengeluaran (for expense)
              if (isIncome) ...[
                _buildSectionTitle('Target', isRequired: true),
                _buildTextField(
                  controller: _targetController,
                  hint: 'Masukkan Target Pemasukan',
                ),
              ] else ...[
                _buildSectionTitle('Sumber Pengeluaran', isRequired: true),
                _buildDropdownField(
                  value: selectedSumberPengeluaran,
                  items: sumberPengeluaranOptions,
                  hint: 'Pilih Sumber Pengeluaran',
                  onChanged: (value) {
                    setState(() {
                      selectedSumberPengeluaran = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Item Pengeluaran
                _buildSectionTitle('Item Pengeluaran', isRequired: true),
                _buildTextField(
                  controller: _itemPengeluaranController,
                  hint: 'Contoh: Bibit Padi Unggul',
                ),
              ],
              const SizedBox(height: 16),

              // Nama Vendor/Penyedia (for expense only)
              if (!isIncome) ...[
                _buildSectionTitle('Nama Vendor/Penyedia (Opsional)'),
                _buildTextField(
                  controller: _sumberPengeluaranController,
                  hint: 'Contoh: Toko Tani Makmur',
                ),
                const SizedBox(height: 16),
              ],

              // Nama Agen/Pembeli (for income only)
              if (isIncome) ...[
                _buildSectionTitle('Nama Agen/Pembeli (Opsional)'),
                _buildTextField(hint: 'Masukkan Nama Agen/Pembeli'),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),

              // Kuantitas
              _buildSectionTitle('Kuantitas', isRequired: true),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _kuantitasController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildDropdownField(
                      value: selectedSatuan,
                      items: satuanOptions,
                      hint: 'Satuan',
                      onChanged: (value) {
                        setState(() {
                          selectedSatuan = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Harga Per Unit/Beli
              _buildSectionTitle(
                isIncome ? 'Harga Satuan' : 'Harga Per Unit/Beli',
                isRequired: true,
              ),
              Row(
                children: [
                  const Text(
                    'Rp ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _hargaController,
                      hint: 'Masukkan harga',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ ${selectedSatuan ?? 'Satuan'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Harga
              _buildSectionTitle('Total Harga', isRequired: true),
              Row(
                children: [
                  const Text(
                    'Rp ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: _totalHargaController,
                      hint: 'Masukkan total harga',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Upload section
              _buildSectionTitle('Foto Bukti Pembelian (Opsional)'),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    _buildUploadSection(),
                    if (uploadedFiles.isNotEmpty)
                      ...uploadedFiles
                          .map((file) => _buildUploadedFileItem(file))
                          .toList(),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Deskripsi/Catatan
              _buildSectionTitle(
                isIncome ? 'Catatan (Opsional)' : 'Deskripsi (Opsional)',
              ),
              _buildTextField(
                controller: isIncome
                    ? _catatanController
                    : _deskripsiController,
                hint: isIncome ? 'Tambahkan catatan' : 'Tambahkan deskripsi',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isIncome ? 'Simpan Pemasukan' : 'Simpan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: isRequired
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2E8B25)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tanggalController.text.isEmpty
                  ? 'dd/mm/yyyy'
                  : _tanggalController.text,
              style: TextStyle(
                color: _tanggalController.text.isEmpty
                    ? Colors.grey[600]
                    : Colors.black87,
              ),
            ),
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return GestureDetector(
      onTap: _handleUpload,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green.shade300,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.green.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, color: Colors.green.shade600, size: 32),
            const SizedBox(height: 8),
            Text(
              'Klik untuk upload',
              style: TextStyle(
                color: Colors.green.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Maks 20 MB Foto. Video',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E8B25),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _tanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_validateForm()) {
      _showConfirmationDialog();
    }
  }

  bool _validateForm() {
    // Validate required fields
    if (selectedKomoditas == null) {
      _showSnackBar('Silakan pilih komoditas', Colors.red);
      return false;
    }

    if (_tanggalController.text.isEmpty) {
      _showSnackBar('Silakan pilih tanggal', Colors.red);
      return false;
    }

    if (widget.type == 'income' && _targetController.text.isEmpty) {
      _showSnackBar('Silakan masukkan target pemasukan', Colors.red);
      return false;
    }

    if (widget.type == 'expense' && selectedSumberPengeluaran == null) {
      _showSnackBar('Silakan pilih sumber pengeluaran', Colors.red);
      return false;
    }

    if (widget.type == 'expense' && _itemPengeluaranController.text.isEmpty) {
      _showSnackBar('Silakan masukkan item pengeluaran', Colors.red);
      return false;
    }

    if (_kuantitasController.text.isEmpty) {
      _showSnackBar('Silakan masukkan kuantitas', Colors.red);
      return false;
    }

    if (selectedSatuan == null) {
      _showSnackBar('Silakan pilih satuan', Colors.red);
      return false;
    }

    if (_hargaController.text.isEmpty) {
      _showSnackBar('Silakan masukkan harga satuan', Colors.red);
      return false;
    }

    return true;
  }

  void _showConfirmationDialog() {
    final isIncome = widget.type == 'income';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isIncome ? Icons.check_circle : Icons.save,
                color: isIncome ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Konfirmasi ${isIncome ? 'Pemasukan' : 'Pengeluaran'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menyimpan ${isIncome ? 'pemasukan' : 'pengeluaran'} ini?',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Komoditas', selectedKomoditas ?? ''),
                    _buildDetailRow('Tanggal', _tanggalController.text),
                    _buildDetailRow(
                      isIncome ? 'Target' : 'Sumber',
                      isIncome
                          ? _targetController.text
                          : (selectedSumberPengeluaran ?? ''),
                    ),
                    _buildDetailRow(
                      'Kuantitas',
                      '${_kuantitasController.text} ${selectedSatuan ?? ''}',
                    ),
                    _buildDetailRow('Harga', 'Rp ${_hargaController.text}/Kg'),
                    _buildDetailRow(
                      'Total',
                      'Rp ${_totalHargaController.text}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _saveTransaction();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncome ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Simpan',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black87 : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? (widget.type == 'income' ? Colors.green : Colors.red)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _saveTransaction() {
    // Validation: Check if required fields are filled
    if (selectedKomoditas == null || selectedKomoditas!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih komoditas terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_totalHargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi total harga'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create transaction data with proper data types
    final transactionData = {
      'type': widget.type,
      'komoditas': selectedKomoditas,
      'tanggal': _tanggalController.text,
      'target': widget.type == 'income'
          ? _targetController.text
          : selectedSumberPengeluaran,
      'itemPengeluaran': widget.type == 'expense'
          ? _itemPengeluaranController.text
          : null,
      'namaVendor': widget.type == 'expense'
          ? _sumberPengeluaranController.text
          : null,
      'kuantitas': _kuantitasController.text,
      'satuan': selectedSatuan,
      'harga': _hargaController.text,
      'totalHarga': _totalHargaController.text.trim(), // Ensure no whitespace
      'catatan': widget.type == 'income'
          ? _catatanController.text
          : _deskripsiController.text,
      'uploadedFiles': uploadedFiles,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Return the data to the previous screen
    Navigator.pop(context, transactionData);
  }

  Widget _buildKomoditasSelector() {
    return GestureDetector(
      onTap: _selectKomoditas,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedKomoditas ?? 'Pilih Komoditas Anda',
              style: TextStyle(
                color: selectedKomoditas != null
                    ? Colors.black87
                    : Colors.grey[600],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  String _searchQuery = '';

  Future<void> _selectKomoditas() async {
    _searchQuery = ''; // Reset search
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Pilih Komoditas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  onChanged: (value) {
                    setModalState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari komoditas anda',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              // Commodity list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _getFilteredKomoditas().length,
                  itemBuilder: (context, index) {
                    final komoditas = _getFilteredKomoditas()[index];
                    final isSelected = selectedKomoditas == komoditas;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedKomoditas = komoditas;
                            });
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2E8B25).withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2E8B25)
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    komoditas,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF2E8B25)
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2E8B25),
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Floating Action Button area
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        _showAddKomoditasDialog(setModalState);
                      },
                      backgroundColor: const Color(0xFF2E8B25),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getFilteredKomoditas() {
    if (_searchQuery.isEmpty) {
      return komoditasOptions;
    }
    return komoditasOptions
        .where((komoditas) => komoditas.toLowerCase().contains(_searchQuery))
        .toList();
  }

  void _showAddKomoditasDialog(StateSetter setModalState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Komoditas Baru'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nama komoditas',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setModalState(() {
                  komoditasOptions.add(controller.text.trim());
                });
                setState(() {
                  selectedKomoditas = controller.text.trim();
                });
                Navigator.pop(context); // Close add dialog
                Navigator.pop(context); // Close commodity selection
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B25),
            ),
            child: const Text('Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedFileItem(String filename) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              filename,
              style: TextStyle(color: Colors.green.shade700, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade400, size: 20),
            onPressed: () {
              setState(() {
                uploadedFiles.remove(filename);
              });
            },
          ),
        ],
      ),
    );
  }

  void _handleUpload() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Upload File',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildUploadOptionTile(
                      icon: Icons.camera_alt,
                      title: 'Ambil Foto',
                      subtitle: 'Gunakan kamera untuk mengambil foto',
                      onTap: () => _pickImageFromCamera(),
                    ),
                    const SizedBox(height: 8),
                    _buildUploadOptionTile(
                      icon: Icons.photo_library,
                      title: 'Pilih dari Galeri',
                      subtitle: 'Pilih foto dari galeri HP',
                      onTap: () => _pickImageFromGallery(),
                    ),
                    const SizedBox(height: 8),
                    _buildUploadOptionTile(
                      icon: Icons.videocam,
                      title: 'Pilih Video',
                      subtitle: 'Pilih video dari HP',
                      onTap: () => _pickVideo(),
                    ),
                    const SizedBox(height: 8),
                    _buildUploadOptionTile(
                      icon: Icons.insert_drive_file,
                      title: 'Pilih Dokumen',
                      subtitle: 'Pilih file dokumen (PDF, DOC, dll)',
                      onTap: () => _pickDocument(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8B25).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2E8B25), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _pickImageFromCamera() async {
    Navigator.of(context).pop(); // Close bottom sheet
    try {
      // Show loading
      _showLoadingDialog();

      // Simulate camera access (dalam implementasi nyata gunakan image_picker)
      await Future.delayed(const Duration(milliseconds: 800));

      Navigator.of(context).pop(); // Close loading

      // Simulate successful camera capture
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'camera_$timestamp.jpg';

      setState(() {
        uploadedFiles.add(filename);
      });

      _showSnackBar('Foto berhasil diambil: $filename', Colors.green);
    } catch (e) {
      Navigator.of(context).pop(); // Close loading if still open
      _showSnackBar('Gagal mengakses kamera', Colors.red);
    }
  }

  void _pickImageFromGallery() async {
    Navigator.of(context).pop(); // Close bottom sheet
    try {
      _showLoadingDialog();

      // Simulate gallery access
      await Future.delayed(const Duration(milliseconds: 600));

      Navigator.of(context).pop(); // Close loading

      // Simulate file selection from gallery
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'gallery_$timestamp.jpg';

      setState(() {
        uploadedFiles.add(filename);
      });

      _showSnackBar(
        'Foto berhasil dipilih dari galeri: $filename',
        Colors.green,
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackBar('Gagal mengakses galeri', Colors.red);
    }
  }

  void _pickVideo() async {
    Navigator.of(context).pop(); // Close bottom sheet
    try {
      _showLoadingDialog();

      // Simulate video selection
      await Future.delayed(const Duration(milliseconds: 1000));

      Navigator.of(context).pop(); // Close loading

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'video_$timestamp.mp4';

      setState(() {
        uploadedFiles.add(filename);
      });

      _showSnackBar('Video berhasil dipilih: $filename', Colors.green);
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackBar('Gagal memilih video', Colors.red);
    }
  }

  void _pickDocument() async {
    Navigator.of(context).pop(); // Close bottom sheet
    try {
      _showLoadingDialog();

      // Simulate document selection
      await Future.delayed(const Duration(milliseconds: 700));

      Navigator.of(context).pop(); // Close loading

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'document_$timestamp.pdf';

      setState(() {
        uploadedFiles.add(filename);
      });

      _showSnackBar('Dokumen berhasil dipilih: $filename', Colors.green);
    } catch (e) {
      Navigator.of(context).pop();
      _showSnackBar('Gagal memilih dokumen', Colors.red);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Mengakses file...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
