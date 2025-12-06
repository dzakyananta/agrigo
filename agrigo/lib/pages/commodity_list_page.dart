import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommodityListPage extends StatefulWidget {
  final String selectedCommodity;

  const CommodityListPage({super.key, required this.selectedCommodity});

  @override
  State<CommodityListPage> createState() => _CommodityListPageState();
}

class _CommodityListPageState extends State<CommodityListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CommodityItem> allItems = [];
  List<CommodityItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _initializeItems();
    filteredItems = allItems;
  }

  void _initializeItems() {
    // Initialize with sample data based on selected commodity
    allItems = List.generate(
      8,
      (index) => CommodityItem(
        name: widget.selectedCommodity,
        location: 'Lokasi ${index + 1}',
        price: '${15000 + (index * 1000)}/kg',
        supplier: 'Petani ${index + 1}',
      ),
    );
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = allItems;
      } else {
        filteredItems = allItems
            .where(
              (item) =>
                  item.name.toLowerCase().contains(query.toLowerCase()) ||
                  item.location.toLowerCase().contains(query.toLowerCase()) ||
                  item.supplier.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _addNewItem() {
    // TODO: Navigate to add new commodity page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur tambah komoditas akan segera tersedia'),
        duration: Duration(seconds: 2),
      ),
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
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black12,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Pilih Komoditas',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
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
                onChanged: _filterItems,
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
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada komoditas ditemukan',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
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
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name} dipilih'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: const Color(0xFF2E8B25),
                                ),
                              );
                            },
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
                                    child: const Icon(
                                      Icons.agriculture,
                                      color: Color(0xFF3AA02F),
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
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.location,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.supplier,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Price
                                  Text(
                                    item.price,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2E8B25),
                                    ),
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
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewItem,
        backgroundColor: const Color(0xFF2E8B25),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }
}

class CommodityItem {
  final String name;
  final String location;
  final String price;
  final String supplier;

  CommodityItem({
    required this.name,
    required this.location,
    required this.price,
    required this.supplier,
  });
}
