import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:live_score/src/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class AuthProvider with ChangeNotifier {
  String? _token;
  double _balance = 0.0;
  String _subscriptionTier = "FREE";
  
  // Tự động đổi IP cho Android Emulator (10.0.2.2) hoặc Web/iOS (127.0.0.1)
  String get baseUrl {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1/gamification';
    } catch (e) {}
    return 'http://127.0.0.1:8000/api/v1/gamification';
  }

  String? get token => _token;
  double get balance => _balance;
  bool get isAuthenticated => _token != null;
  String get subscriptionTier => _subscriptionTier;
  bool get isPremium => _subscriptionTier == "PREMIUM";

  // Trả về null nếu thành công, trả về string nếu có lỗi
  Future<String?> login(String username, String password) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users/login'));
      request.fields.addAll({'username': username, 'password': password});
      
      var response = await request.send();
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      
      if (response.statusCode == 200) {
        _token = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await fetchMyProfile(); 
        return null; // Thành công
      } else {
        return data['detail'] ?? 'Sai tài khoản hoặc mật khẩu';
      }
    } catch (e) {
      return "Lỗi kết nối Server: Bật Backend chưa Sếp?";
    }
  }

  // Trả về null nếu thành công, trả về string nếu có lỗi
  Future<String?> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _token = data['access_token']; 
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await fetchMyProfile();
        return null; // Thành công
      } else {
         return data['detail'] ?? 'Lỗi từ Server Backend';
      }
    } catch (e) {
      return "Lỗi kết nối Server: Bật Backend chưa Sếp?";
    }
  }

  Future<void> fetchMyProfile() async {
    if (_token == null) return;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _balance = (data['balance'] as num).toDouble();
        _subscriptionTier = data['subscription_tier'] ?? "FREE";
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Lỗi fetch profile: $e");
    }
  }
  
  void logout() async {
    _token = null;
    _balance = 0.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }

  void updateBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }
}
