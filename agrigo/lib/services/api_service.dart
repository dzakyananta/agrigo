import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan URL server Laravel Anda
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ========== COMMODITIES ==========

  /// Get all active commodities
  static Future<List<dynamic>> getCommodities() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commodities'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting commodities: $e');
      return [];
    }
  }

  /// Get commodity by ID
  static Future<Map<String, dynamic>?> getCommodity(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commodities/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error getting commodity: $e');
      return null;
    }
  }

  /// Get commodities by type
  static Future<List<dynamic>> getCommoditiesByType(String type) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commodities/type/$type'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting commodities by type: $e');
      return [];
    }
  }

  /// Get all commodity types
  static Future<List<String>> getCommodityTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/commodity-types'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting commodity types: $e');
      return [];
    }
  }

  // ========== TRANSACTIONS ==========

  /// Get all transactions for current user
  static Future<List<dynamic>> getTransactions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  /// Create new transaction (will auto-sync to admin)
  static Future<Map<String, dynamic>?> createTransaction({
    required String type, // 'income' or 'expense'
    String? source, // Source of income/expense
    required double amount,
    required String description,
    required String date, // Format: YYYY-MM-DD
    int? commodityId,
    String? commodityName, // If commodity not in database yet
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'type': type,
        if (source != null && source.isNotEmpty) 'source': source,
        'amount': amount,
        'description': description,
        'date': date,
        if (commodityId != null) 'commodity_id': commodityId,
        if (commodityName != null && commodityName.isNotEmpty)
          'commodity_name': commodityName,
      };

      print('📡 POST $baseUrl/transactions');
      print('📦 Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: headers,
        body: json.encode(body),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        print('❌ Validation error: ${data['message']}');
        return null;
      } else {
        print('❌ Unexpected status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating transaction: $e');
      return null;
    }
  }

  /// Update existing transaction
  static Future<Map<String, dynamic>?> updateTransaction({
    required int id,
    required String type,
    required double amount,
    required String description,
    required String date,
    int? commodityId,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'type': type,
        'amount': amount,
        'description': description,
        'date': date,
        if (commodityId != null) 'commodity_id': commodityId,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error updating transaction: $e');
      return null;
    }
  }

  /// Delete transaction
  static Future<bool> deleteTransaction(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }

  /// Get financial summary
  static Future<Map<String, dynamic>?> getFinancialSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/summary'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error getting financial summary: $e');
      return null;
    }
  }

  // ========== SCHEDULES ==========

  /// Get all schedules for current user
  static Future<List<dynamic>> getSchedules() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/schedules'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting schedules: $e');
      return [];
    }
  }

  /// Create new schedule
  static Future<Map<String, dynamic>?> createSchedule({
    required int commodityId,
    required String startDate,
    required String endDate,
    String? notes,
    String status = 'active',
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'commodity_id': commodityId,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
        if (notes != null) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error creating schedule: $e');
      return null;
    }
  }

  /// Update schedule
  static Future<Map<String, dynamic>?> updateSchedule({
    required int id,
    required int commodityId,
    required String startDate,
    required String endDate,
    String? notes,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'commodity_id': commodityId,
        'start_date': startDate,
        'end_date': endDate,
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/schedules/$id'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error updating schedule: $e');
      return null;
    }
  }

  /// Delete schedule
  static Future<bool> deleteSchedule(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/schedules/$id'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }

  // ========== AUTH ==========

  /// Login user
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Save token to SharedPreferences
        if (data['data']?['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['data']['token']);
        }

        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  /// Register new user
  static Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Save token to SharedPreferences
        if (data['data']?['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['data']['token']);
        }

        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  /// Logout user
  static Future<bool> logout() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Clear token from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        return true;
      }
      return false;
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>?> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? location,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (address != null) body['address'] = address;
      if (location != null) body['location'] = location;

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  // ========== CHATBOT FAQs ==========

  /// Get all active FAQs
  static Future<List<dynamic>> getChatbotFaqs() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/faqs'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting chatbot FAQs: $e');
      return [];
    }
  }

  /// Get FAQs by category
  static Future<List<dynamic>> getChatbotFaqsByCategory(String category) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/faqs/category/$category'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting FAQs by category: $e');
      return [];
    }
  }

  /// Get all FAQ categories
  static Future<List<String>> getChatbotCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/faqs/categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting chatbot categories: $e');
      return [];
    }
  }

  /// Search FAQs by keyword
  static Future<List<dynamic>> searchChatbotFaqs(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/chatbot/faqs/search?q=${Uri.encodeComponent(query)}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error searching FAQs: $e');
      return [];
    }
  }

  /// Smart search - Find best matching FAQ based on keywords
  static Future<List<dynamic>> smartSearchChatbot(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/chatbot/faqs/smart-search?q=${Uri.encodeComponent(query)}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error smart searching: $e');
      return [];
    }
  }

  /// Get FAQ by ID (increments usage count)
  static Future<Map<String, dynamic>?> getChatbotFaq(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/faqs/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error getting FAQ: $e');
      return null;
    }
  }
}
