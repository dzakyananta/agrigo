import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Custom painter for symmetric green curve at top
class GreenCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF3AA02F)
      ..style = PaintingStyle.fill;

    Path path = Path();
    
    // Start from top-left
    path.moveTo(0, 0);
    // Go to top-right
    path.lineTo(size.width, 0);
    // Go down the right side
    path.lineTo(size.width, size.height * 0.6);
    
    // Create symmetric curve from right to left
    path.quadraticBezierTo(
      size.width * 0.5,        // Control point X (center)
      size.height * 1.2,       // Control point Y (below for curve down)
      0,                       // End point X (left side)
      size.height * 0.6,       // End point Y (same height as start)
    );
    
    // Close path back to start
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CommoditySearchPage extends StatefulWidget {
  const CommoditySearchPage({super.key});

  @override
  State<CommoditySearchPage> createState() => _CommoditySearchPageState();
}

class _CommoditySearchPageState extends State<CommoditySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CommodityData> allCommodities = [];
  List<CommodityData> filteredCommodities = [];

  @override
  void initState() {
    super.initState();
    _initializeCommodities();
    filteredCommodities = allCommodities;
  }

  void _initializeCommodities() {
    allCommodities = [
      // Tanaman Pangan
      CommodityData(
        name: 'Jagung',
        category: 'Tanaman Pangan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Padi',
        category: 'Tanaman Pangan',
        icon: Icons.grass,
      ),
      CommodityData(
        name: 'Kedelai',
        category: 'Tanaman Pangan',
        icon: Icons.eco,
      ),
      CommodityData(
        name: 'Kacang Tanah',
        category: 'Tanaman Pangan',
        icon: Icons.eco,
      ),
      CommodityData(
        name: 'Kacang Hijau',
        category: 'Tanaman Pangan',
        icon: Icons.eco,
      ),
      CommodityData(
        name: 'Ubi Kayu',
        category: 'Tanaman Pangan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Ubi Jalar',
        category: 'Tanaman Pangan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Kentang',
        category: 'Tanaman Pangan',
        icon: Icons.agriculture,
      ),

      // Sayuran
      CommodityData(
        name: 'Cabai Merah',
        category: 'Sayuran',
        icon: Icons.local_fire_department,
      ),
      CommodityData(
        name: 'Cabai Rawit',
        category: 'Sayuran',
        icon: Icons.local_fire_department,
      ),
      CommodityData(
        name: 'Bawang Merah',
        category: 'Sayuran',
        icon: Icons.circle,
      ),
      CommodityData(
        name: 'Bawang Putih',
        category: 'Sayuran',
        icon: Icons.circle,
      ),
      CommodityData(name: 'Tomat', category: 'Sayuran', icon: Icons.circle),
      CommodityData(
        name: 'Wortel',
        category: 'Sayuran',
        icon: Icons.agriculture,
      ),
      CommodityData(name: 'Kangkung', category: 'Sayuran', icon: Icons.grass),
      CommodityData(name: 'Bayam', category: 'Sayuran', icon: Icons.grass),
      CommodityData(name: 'Sawi', category: 'Sayuran', icon: Icons.grass),
      CommodityData(name: 'Kubis', category: 'Sayuran', icon: Icons.circle),
      CommodityData(name: 'Kol', category: 'Sayuran', icon: Icons.circle),
      CommodityData(
        name: 'Terong',
        category: 'Sayuran',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Timun',
        category: 'Sayuran',
        icon: Icons.agriculture,
      ),
      CommodityData(name: 'Labu', category: 'Sayuran', icon: Icons.agriculture),

      // Buah-buahan
      CommodityData(name: 'Jeruk', category: 'Buah-buahan', icon: Icons.circle),
      CommodityData(
        name: 'Mangga',
        category: 'Buah-buahan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Pisang',
        category: 'Buah-buahan',
        icon: Icons.agriculture,
      ),
      CommodityData(name: 'Apel', category: 'Buah-buahan', icon: Icons.circle),
      CommodityData(
        name: 'Pepaya',
        category: 'Buah-buahan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Semangka',
        category: 'Buah-buahan',
        icon: Icons.circle,
      ),
      CommodityData(name: 'Melon', category: 'Buah-buahan', icon: Icons.circle),
      CommodityData(
        name: 'Anggur',
        category: 'Buah-buahan',
        icon: Icons.circle,
      ),
      CommodityData(
        name: 'Alpukat',
        category: 'Buah-buahan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Durian',
        category: 'Buah-buahan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Rambutan',
        category: 'Buah-buahan',
        icon: Icons.circle,
      ),
      CommodityData(
        name: 'Manggis',
        category: 'Buah-buahan',
        icon: Icons.circle,
      ),

      // Tanaman Perkebunan
      CommodityData(
        name: 'Kopi',
        category: 'Tanaman Perkebunan',
        icon: Icons.coffee,
      ),
      CommodityData(
        name: 'Teh',
        category: 'Tanaman Perkebunan',
        icon: Icons.grass,
      ),
      CommodityData(
        name: 'Kakao',
        category: 'Tanaman Perkebunan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Kelapa',
        category: 'Tanaman Perkebunan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Kelapa Sawit',
        category: 'Tanaman Perkebunan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Karet',
        category: 'Tanaman Perkebunan',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Tebu',
        category: 'Tanaman Perkebunan',
        icon: Icons.grass,
      ),
      CommodityData(
        name: 'Tembakau',
        category: 'Tanaman Perkebunan',
        icon: Icons.grass,
      ),

      // Rempah-rempah
      CommodityData(
        name: 'Kunyit',
        category: 'Rempah-rempah',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Jahe',
        category: 'Rempah-rempah',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Lengkuas',
        category: 'Rempah-rempah',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Kencur',
        category: 'Rempah-rempah',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Serai',
        category: 'Rempah-rempah',
        icon: Icons.grass,
      ),
      CommodityData(
        name: 'Pala',
        category: 'Rempah-rempah',
        icon: Icons.circle,
      ),
      CommodityData(
        name: 'Cengkeh',
        category: 'Rempah-rempah',
        icon: Icons.agriculture,
      ),
      CommodityData(
        name: 'Lada',
        category: 'Rempah-rempah',
        icon: Icons.circle,
      ),

      // Tanaman Hias
      CommodityData(
        name: 'Anggrek',
        category: 'Tanaman Hias',
        icon: Icons.local_florist,
      ),
      CommodityData(
        name: 'Mawar',
        category: 'Tanaman Hias',
        icon: Icons.local_florist,
      ),
      CommodityData(
        name: 'Melati',
        category: 'Tanaman Hias',
        icon: Icons.local_florist,
      ),
      CommodityData(
        name: 'Kamboja',
        category: 'Tanaman Hias',
        icon: Icons.local_florist,
      ),
      CommodityData(
        name: 'Bougenville',
        category: 'Tanaman Hias',
        icon: Icons.local_florist,
      ),
    ];
  }

  void _filterCommodities(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCommodities = allCommodities;
      } else {
        filteredCommodities = allCommodities
            .where(
              (commodity) =>
                  commodity.name.toLowerCase().contains(query.toLowerCase()) ||
                  commodity.category.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  void _selectCommodity(CommodityData commodity) {
    Navigator.pop(context, commodity.name);
  }

  void _addNewCommodity() {
    _showAddCommodityDialog();
  }

  void _showAddCommodityDialog() {
    final nameController = TextEditingController();
    String selectedCategory = 'Tanaman Pangan';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Tambah Komoditas Baru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2E8B25),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nama komoditas',
                        prefixIcon: Icon(
                          Icons.agriculture,
                          color: Color(0xFF2E8B25),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category dropdown
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2E8B25),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        hintText: 'Pilih kategori',
                        prefixIcon: Icon(
                          Icons.category,
                          color: Color(0xFF2E8B25),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items:
                          [
                            'Tanaman Pangan',
                            'Sayuran',
                            'Buah-buahan',
                            'Tanaman Perkebunan',
                            'Rempah-rempah',
                            'Tanaman Hias',
                          ].map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      dropdownColor: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      setState(() {
                        allCommodities.add(
                          CommodityData(
                            name: nameController.text,
                            category: selectedCategory,
                            icon: Icons.agriculture,
                          ),
                        );
                        _filterCommodities(_searchController.text);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${nameController.text} berhasil ditambahkan',
                          ),
                          backgroundColor: const Color(0xFF2E8B25),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B25),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Green curve header with title (scrollable)
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                // Green curve background
                CustomPaint(
                  painter: GreenCurvePainter(),
                  size: const Size(double.infinity, 180),
                  child: Container(),
                ),
                // Title text positioned in green area
                Positioned(
                  left: 0,
                  right: 0,
                  top: 80,
                  child: Center(
                    child: Text(
                      'Pilih komoditas anda',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Container(
            width: double.infinity,
            color: const Color(0xFFF8F9FA),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Container(
              height: 56,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E8B25), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCommodities,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Cari komoditas anda',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF2E8B25),
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          // List content
          filteredCommodities.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'Tidak ada komoditas ditemukan',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredCommodities.length,
                  itemBuilder: (context, index) {
                      final commodity = filteredCommodities[index];
                      return Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 400),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _selectCommodity(commodity),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF3AA02F,
                                      ).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      commodity.icon,
                                      color: const Color(0xFF3AA02F),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          commodity.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          commodity.category,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Arrow icon
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
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
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCommodity,
        backgroundColor: const Color(0xFF2E8B25),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }
}

class CommodityData {
  final String name;
  final String category;
  final IconData icon;

  CommodityData({
    required this.name,
    required this.category,
    required this.icon,
  });
}
