import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../providers/auth_provider.dart';
import '../../../../../../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        context.read<NotificationProvider>().fetchNotifications(auth.token!);
      }
    });
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'GAMIFICATION': return Icons.monetization_on;
      case 'MATCH_ALERT': return Icons.sports_soccer;
      case 'ANALYTICS': return Icons.auto_graph;
      default: return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'GAMIFICATION': return Colors.yellow;
      case 'MATCH_ALERT': return Colors.greenAccent;
      case 'ANALYTICS': return Colors.purpleAccent;
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationProvider>().notifications;
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Báo'),
        backgroundColor: const Color(0xFF0B1F3A),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: notifs.isEmpty
          ? const Center(child: Text("Bạn chưa có thông báo nào", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: notifs.length,
              itemBuilder: (ctx, i) {
                final n = notifs[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColor(n.type).withOpacity(0.2),
                    child: Icon(_getIcon(n.type), color: _getColor(n.type)),
                  ),
                  title: Text(n.title, style: TextStyle(color: Colors.white, fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(n.message, style: TextStyle(color: n.isRead ? Colors.grey : Colors.white70)),
                  tileColor: n.isRead ? Colors.transparent : Colors.grey.withOpacity(0.1),
                  onTap: () {
                    if (!n.isRead && auth.token != null) {
                      context.read<NotificationProvider>().markAsRead(auth.token!, n.id);
                    }
                  },
                );
              },
            ),
    );
  }
}
