import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class DatabaseSeeder {
  static Future<void> seedInitialData() async {
    try {
      print('🌱 Memulai seeding data...');

      await _seedRegions();
      await _seedCommodities();
      await _seedSampleUsers();

      print('✅ Seeding data selesai!');
    } catch (e) {
      print('❌ Error saat seeding: $e');
    }
  }

  // Seed wilayah/daerah di Lampung
  static Future<void> _seedRegions() async {
    print('📍 Seeding regions...');

    List<Map<String, dynamic>> regions = [
      {
        'name': 'Bandar Lampung',
        'province': 'Lampung',
        'coordinates': {'lat': -5.4292, 'lon': 105.2611},
      },
      {
        'name': 'Metro',
        'province': 'Lampung',
        'coordinates': {'lat': -5.1135, 'lon': 105.3067},
      },
      {
        'name': 'Lampung Selatan',
        'province': 'Lampung',
        'coordinates': {'lat': -5.6667, 'lon': 105.5000},
      },
      {
        'name': 'Lampung Tengah',
        'province': 'Lampung',
        'coordinates': {'lat': -4.8833, 'lon': 105.2833},
      },
      {
        'name': 'Lampung Utara',
        'province': 'Lampung',
        'coordinates': {'lat': -4.5833, 'lon': 104.7500},
      },
      {
        'name': 'Lampung Timur',
        'province': 'Lampung',
        'coordinates': {'lat': -5.0000, 'lon': 105.5000},
      },
      {
        'name': 'Pringsewu',
        'province': 'Lampung',
        'coordinates': {'lat': -5.3581, 'lon': 104.9681},
      },
      {
        'name': 'Tanggamus',
        'province': 'Lampung',
        'coordinates': {'lat': -5.3500, 'lon': 104.6333},
      },
    ];

    for (var region in regions) {
      await FirebaseService.addRegion(
        name: region['name'],
        province: region['province'],
        coordinates: region['coordinates'],
      );
    }

    print('✅ Regions seeded successfully');
  }

  // Seed komoditas pertanian
  static Future<void> _seedCommodities() async {
    print('🌾 Seeding commodities...');

    List<Map<String, dynamic>> commodities = [
      // Pangan Pokok
      {
        'name': 'Padi IR64',
        'category': 'Pangan',
        'currentPrice': 5500.0,
        'region': 'Bandar Lampung',
        'unit': 'kg',
        'description': 'Padi varietas IR64, cocok untuk sawah irigasi',
        'imageUrl': 'https://example.com/padi.jpg',
      },
      {
        'name': 'Padi Ciherang',
        'category': 'Pangan',
        'currentPrice': 5800.0,
        'region': 'Metro',
        'unit': 'kg',
        'description': 'Padi varietas Ciherang, tahan hama',
        'imageUrl': 'https://example.com/padi-ciherang.jpg',
      },
      {
        'name': 'Jagung Hibrida',
        'category': 'Pangan',
        'currentPrice': 4200.0,
        'region': 'Lampung Tengah',
        'unit': 'kg',
        'description': 'Jagung hibrida produktivitas tinggi',
        'imageUrl': 'https://example.com/jagung.jpg',
      },
      {
        'name': 'Singkong',
        'category': 'Pangan',
        'currentPrice': 1800.0,
        'region': 'Lampung Selatan',
        'unit': 'kg',
        'description': 'Singkong segar kualitas ekspor',
        'imageUrl': 'https://example.com/singkong.jpg',
      },

      // Hortikultura
      {
        'name': 'Cabai Merah Keriting',
        'category': 'Hortikultura',
        'currentPrice': 35000.0,
        'region': 'Bandar Lampung',
        'unit': 'kg',
        'description': 'Cabai merah keriting segar',
        'imageUrl': 'https://example.com/cabai-merah.jpg',
      },
      {
        'name': 'Cabai Rawit',
        'category': 'Hortikultura',
        'currentPrice': 45000.0,
        'region': 'Metro',
        'unit': 'kg',
        'description': 'Cabai rawit super pedas',
        'imageUrl': 'https://example.com/cabai-rawit.jpg',
      },
      {
        'name': 'Tomat',
        'category': 'Hortikultura',
        'currentPrice': 8500.0,
        'region': 'Lampung Utara',
        'unit': 'kg',
        'description': 'Tomat segar grade A',
        'imageUrl': 'https://example.com/tomat.jpg',
      },
      {
        'name': 'Bawang Merah',
        'category': 'Hortikultura',
        'currentPrice': 28000.0,
        'region': 'Tanggamus',
        'unit': 'kg',
        'description': 'Bawang merah lokal berkualitas',
        'imageUrl': 'https://example.com/bawang-merah.jpg',
      },

      // Buah-buahan
      {
        'name': 'Pisang Cavendish',
        'category': 'Buah',
        'currentPrice': 12000.0,
        'region': 'Pringsewu',
        'unit': 'kg',
        'description': 'Pisang Cavendish kualitas ekspor',
        'imageUrl': 'https://example.com/pisang.jpg',
      },
      {
        'name': 'Durian Montong',
        'category': 'Buah',
        'currentPrice': 25000.0,
        'region': 'Lampung Timur',
        'unit': 'kg',
        'description': 'Durian montong matang pohon',
        'imageUrl': 'https://example.com/durian.jpg',
      },
      {
        'name': 'Mangga Gedong Gincu',
        'category': 'Buah',
        'currentPrice': 18000.0,
        'region': 'Lampung Selatan',
        'unit': 'kg',
        'description': 'Mangga gedong gincu manis',
        'imageUrl': 'https://example.com/mangga.jpg',
      },

      // Kopi
      {
        'name': 'Kopi Robusta',
        'category': 'Perkebunan',
        'currentPrice': 22000.0,
        'region': 'Tanggamus',
        'unit': 'kg',
        'description': 'Kopi robusta Lampung biji kering',
        'imageUrl': 'https://example.com/kopi-robusta.jpg',
      },
      {
        'name': 'Kopi Arabika',
        'category': 'Perkebunan',
        'currentPrice': 35000.0,
        'region': 'Lampung Utara',
        'unit': 'kg',
        'description': 'Kopi arabika premium dari dataran tinggi',
        'imageUrl': 'https://example.com/kopi-arabika.jpg',
      },

      // Rempah-rempah
      {
        'name': 'Lada Putih',
        'category': 'Rempah',
        'currentPrice': 95000.0,
        'region': 'Lampung Timur',
        'unit': 'kg',
        'description': 'Lada putih Lampung kualitas ekspor',
        'imageUrl': 'https://example.com/lada-putih.jpg',
      },
      {
        'name': 'Lada Hitam',
        'category': 'Rempah',
        'currentPrice': 85000.0,
        'region': 'Lampung Timur',
        'unit': 'kg',
        'description': 'Lada hitam Lampung grade 1',
        'imageUrl': 'https://example.com/lada-hitam.jpg',
      },
    ];

    for (var commodity in commodities) {
      await FirebaseService.addCommodity(
        name: commodity['name'],
        category: commodity['category'],
        currentPrice: commodity['currentPrice'],
        region: commodity['region'],
        unit: commodity['unit'],
        description: commodity['description'],
        imageUrl: commodity['imageUrl'],
      );
    }

    print('✅ Commodities seeded successfully');
  }

  // Seed sample users untuk testing
  static Future<void> _seedSampleUsers() async {
    print('👥 Seeding sample users...');

    // Note: Dalam implementasi nyata, users dibuat saat registrasi
    // Ini hanya contoh struktur data
    List<Map<String, dynamic>> sampleUsers = [
      {
        'id': 'farmer_001',
        'name': 'Budi Santoso',
        'email': 'budi.santoso@email.com',
        'phone': '+628123456789',
        'region': 'Bandar Lampung',
        'crops': ['padi', 'jagung'],
        'role': 'farmer',
      },
      {
        'id': 'farmer_002',
        'name': 'Siti Rahayu',
        'email': 'siti.rahayu@email.com',
        'phone': '+628123456790',
        'region': 'Metro',
        'crops': ['cabai', 'tomat'],
        'role': 'farmer',
      },
      {
        'id': 'farmer_003',
        'name': 'Ahmad Wijaya',
        'email': 'ahmad.wijaya@email.com',
        'phone': '+628123456791',
        'region': 'Lampung Tengah',
        'crops': ['kopi', 'lada'],
        'role': 'farmer',
      },
      {
        'id': 'admin_001',
        'name': 'Admin AgriGo',
        'email': 'admin@agrigo.com',
        'phone': '+628123456792',
        'region': 'Bandar Lampung',
        'crops': [],
        'role': 'admin',
      },
    ];

    // Dalam implementasi nyata, data ini akan dibuat saat user registrasi
    print('ℹ️  Sample user data structure ready for registration');
    print('✅ Sample users structure defined');
  }

  // Seed notifikasi contoh
  static Future<void> seedSampleNotifications(String userId) async {
    print('🔔 Seeding sample notifications...');

    List<Map<String, dynamic>> notifications = [
      {
        'userId': userId,
        'title': 'Selamat Datang di AgriGo!',
        'message':
            'Terima kasih telah bergabung dengan komunitas petani digital',
        'type': 'system',
        'data': {},
      },
      {
        'userId': userId,
        'title': 'Harga Cabai Merah Naik',
        'message':
            'Harga cabai merah di Bandar Lampung naik menjadi Rp 35.000/kg',
        'type': 'priceAlert',
        'data': {
          'commodityId': 'cabai_merah',
          'newPrice': 35000,
          'region': 'Bandar Lampung',
        },
      },
      {
        'userId': userId,
        'title': 'Peringatan Cuaca',
        'message':
            'Prakiraan hujan deras hari ini, pastikan tanaman terlindungi',
        'type': 'weather',
        'data': {'weatherCondition': 'heavy_rain', 'region': 'Bandar Lampung'},
      },
    ];

    for (var notification in notifications) {
      await FirebaseService.createNotification(
        userId: notification['userId'],
        title: notification['title'],
        message: notification['message'],
        type: notification['type'],
        data: notification['data'],
      );
    }

    print('✅ Sample notifications seeded successfully');
  }

  // Helper function untuk mendapatkan daftar komoditas berdasarkan region
  static Future<List<Map<String, dynamic>>> getCommoditiesByRegion(
    String region,
  ) async {
    try {
      var commodities = await FirebaseService.getCommodities(region: region);
      return commodities.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting commodities: $e');
      return [];
    }
  }

  // Helper function untuk update harga komoditas
  static Future<void> updateCommodityPrices() async {
    print('💰 Updating commodity prices...');

    // Simulasi update harga (dalam aplikasi nyata, ini bisa dari API atau admin panel)
    Map<String, double> priceUpdates = {
      'Cabai Merah Keriting': 38000.0,
      'Padi IR64': 5600.0,
      'Lada Putih': 98000.0,
      'Tomat': 9000.0,
    };

    try {
      var allCommodities = await FirebaseService.getCommodities();

      for (var doc in allCommodities.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String commodityName = data['name'];

        if (priceUpdates.containsKey(commodityName)) {
          await FirebaseService.updateCommodityPrice(
            commodityId: doc.id,
            newPrice: priceUpdates[commodityName]!,
          );
          print(
            'Updated $commodityName price to ${priceUpdates[commodityName]}',
          );
        }
      }

      print('✅ Commodity prices updated successfully');
    } catch (e) {
      print('❌ Error updating prices: $e');
    }
  }

  // Clean up function untuk development
  static Future<void> clearAllData() async {
    print('🗑️  Clearing all data...');

    final firestore = FirebaseFirestore.instance;

    // Hati-hati: ini akan menghapus semua data!
    List<String> collections = [
      'users',
      'commodities',
      'transactions',
      'weather_data',
      'notifications',
      'regions',
    ];

    for (String collection in collections) {
      var snapshot = await firestore.collection(collection).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('Cleared $collection collection');
    }

    print('✅ All data cleared');
  }
}
