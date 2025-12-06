import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// User Model
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String region;
  final String profileImage;
  final List<String> crops;
  final String role;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.region,
    required this.profileImage,
    required this.crops,
    required this.role,
    required this.createdAt,
    required this.isActive,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      region: data['region'] ?? '',
      profileImage: data['profileImage'] ?? '',
      crops: List<String>.from(data['crops'] ?? []),
      role: data['role'] ?? 'farmer',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'region': region,
      'profileImage': profileImage,
      'crops': crops,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}

// Commodity Model
class CommodityModel {
  final String id;
  final String name;
  final String category;
  final double currentPrice;
  final String region;
  final String unit;
  final String imageUrl;
  final String description;
  final List<PriceHistory> priceHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  CommodityModel({
    required this.id,
    required this.name,
    required this.category,
    required this.currentPrice,
    required this.region,
    required this.unit,
    required this.imageUrl,
    required this.description,
    required this.priceHistory,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory CommodityModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<PriceHistory> history = [];
    if (data['priceHistory'] != null) {
      history = (data['priceHistory'] as List)
          .map((item) => PriceHistory.fromMap(item))
          .toList();
    }

    return CommodityModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      currentPrice: (data['currentPrice'] ?? 0).toDouble(),
      region: data['region'] ?? '',
      unit: data['unit'] ?? 'kg',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      priceHistory: history,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'currentPrice': currentPrice,
      'region': region,
      'unit': unit,
      'imageUrl': imageUrl,
      'description': description,
      'priceHistory': priceHistory.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }
}

// Price History Model
class PriceHistory {
  final double price;
  final DateTime timestamp;

  PriceHistory({required this.price, required this.timestamp});

  factory PriceHistory.fromMap(Map<String, dynamic> map) {
    return PriceHistory(
      price: (map['price'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'price': price, 'timestamp': Timestamp.fromDate(timestamp)};
  }
}

// Transaction Model
class TransactionModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String commodityId;
  final String commodityName;
  final double quantity;
  final double pricePerUnit;
  final double totalAmount;
  final String notes;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.commodityId,
    required this.commodityName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      commodityId: data['commodityId'] ?? '',
      commodityName: data['commodityName'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      pricePerUnit: (data['pricePerUnit'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      notes: data['notes'] ?? '',
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'commodityId': commodityId,
      'commodityName': commodityName,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalAmount': totalAmount,
      'notes': notes,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

enum TransactionStatus { pending, confirmed, inProgress, completed, cancelled }

// Weather Model
class WeatherModel {
  final String id;
  final String region;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final int pressure;
  final String description;
  final String main;
  final String icon;
  final double windSpeed;
  final int windDegree;
  final int visibility;
  final int cloudiness;
  final DateTime sunrise;
  final DateTime sunset;
  final String cityName;
  final String country;
  final Map<String, double> coordinates;
  final DateTime timestamp;

  WeatherModel({
    required this.id,
    required this.region,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.description,
    required this.main,
    required this.icon,
    required this.windSpeed,
    required this.windDegree,
    required this.visibility,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
    required this.cityName,
    required this.country,
    required this.coordinates,
    required this.timestamp,
  });

  factory WeatherModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WeatherModel(
      id: doc.id,
      region: data['region'] ?? '',
      temperature: (data['temperature'] ?? 0).toDouble(),
      feelsLike: (data['feelsLike'] ?? 0).toDouble(),
      humidity: data['humidity'] ?? 0,
      pressure: data['pressure'] ?? 0,
      description: data['description'] ?? '',
      main: data['main'] ?? '',
      icon: data['icon'] ?? '',
      windSpeed: (data['windSpeed'] ?? 0).toDouble(),
      windDegree: data['windDegree'] ?? 0,
      visibility: data['visibility'] ?? 0,
      cloudiness: data['cloudiness'] ?? 0,
      sunrise: (data['sunrise'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sunset: (data['sunset'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cityName: data['cityName'] ?? '',
      country: data['country'] ?? '',
      coordinates: Map<String, double>.from(data['coordinates'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'region': region,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'pressure': pressure,
      'description': description,
      'main': main,
      'icon': icon,
      'windSpeed': windSpeed,
      'windDegree': windDegree,
      'visibility': visibility,
      'cloudiness': cloudiness,
      'sunrise': Timestamp.fromDate(sunrise),
      'sunset': Timestamp.fromDate(sunset),
      'cityName': cityName,
      'country': country,
      'coordinates': coordinates,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

// Notification Model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.general,
      ),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }
}

enum NotificationType { general, priceAlert, weather, transaction, system }

// Region Model
class RegionModel {
  final String id;
  final String name;
  final String province;
  final Map<String, double> coordinates;
  final bool isActive;
  final DateTime createdAt;

  RegionModel({
    required this.id,
    required this.name,
    required this.province,
    required this.coordinates,
    required this.isActive,
    required this.createdAt,
  });

  factory RegionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RegionModel(
      id: doc.id,
      name: data['name'] ?? '',
      province: data['province'] ?? '',
      coordinates: Map<String, double>.from(data['coordinates'] ?? {}),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'province': province,
      'coordinates': coordinates,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
