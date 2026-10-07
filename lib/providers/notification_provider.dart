import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/models/notification_model.dart';
import 'auth_provider.dart'; // To get token

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  List<NotificationModel> _notifications = [];
  Timer? _pollingTimer;

  int get unreadCount => _unreadCount;
  List<NotificationModel> get notifications => _notifications;

  String get baseUrl {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1/notifications';
    } catch (e) {}
    return 'http://127.0.0.1:8000/api/v1/notifications';
  }

  void startPolling(AuthProvider auth) {
    _pollingTimer?.cancel();
    if (!auth.isAuthenticated) return;
    
    // Fetch immediately
    fetchUnreadCount(auth.token!);
    
    // Poll every 1 minute
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (auth.isAuthenticated) {
        fetchUnreadCount(auth.token!);
      } else {
        timer.cancel();
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> fetchUnreadCount(String token) async {
    try {
      final res = await http.get(Uri.parse('\$baseUrl/unread-count'), headers: {
        'Authorization': 'Bearer \$token'
      });
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          _unreadCount = data['unread_count'];
          notifyListeners();
        }
      }
    } catch (e) {
      // Ignore network errors on background poll
    }
  }

  Future<void> fetchNotifications(String token) async {
    try {
      final res = await http.get(Uri.parse(baseUrl), headers: {
        'Authorization': 'Bearer \$token'
      });
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          _notifications = (data['data'] as List)
              .map((j) => NotificationModel.fromJson(j))
              .toList();
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAsRead(String token, int notifId) async {
    try {
      final res = await http.put(Uri.parse('\$baseUrl/\$notifId/read'), headers: {
        'Authorization': 'Bearer \$token'
      });
      if (res.statusCode == 200) {
        // Optimistic update
        final idx = _notifications.indexWhere((n) => n.id == notifId);
        if (idx != -1 && !_notifications[idx].isRead) {
          _notifications[idx] = NotificationModel(
            id: _notifications[idx].id,
            title: _notifications[idx].title,
            message: _notifications[idx].message,
            type: _notifications[idx].type,
            isRead: true,
            createdAt: _notifications[idx].createdAt,
          );
          if (_unreadCount > 0) _unreadCount--;
          notifyListeners();
        }
      }
    } catch (e) {
      // Ignore
    }
  }
}
