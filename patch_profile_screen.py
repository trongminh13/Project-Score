import os

filepath = "lib/src/features/profile/presentation/screens/profile_screen.dart"
with open(filepath, "r") as f:
    content = f.read()

import_new = """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../../../config/app_route.dart';
import '../../../../providers/auth_provider.dart';"""

old_imports = """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../../../config/app_route.dart';
import '../../../../providers/auth_provider.dart';"""

# Check if imports already there
if "package:http/http.dart" not in content:
    pass # Wait, it is there in the truncated file.

claim_daily_func = """
  Future<void> _claimDailyBonus() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;
    
    try {
      final res = await http.post(
        Uri.parse('http://localhost:8000/api/v1/gamification/claim-daily'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.yellow),
                const SizedBox(width: 8),
                Text('Ting Ting! ${data["message"]}'),
              ],
            ),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          )
        );
        _fetchProfile(); // Refresh balance
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["detail"] ?? "Lỗi nhận quà")),
        );
      }
    } catch (e) {
      print(e);
    }
  }
"""

if "_claimDailyBonus" not in content:
    content = content.replace("  Future<void> _fetchProfile() async {", claim_daily_func + "\n  Future<void> _fetchProfile() async {", 1)


old_balance = """                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.yellow, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          '${(_profileData!['balance'] as num).toInt()} ĐIỂM',
                          style: const TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),"""

new_balance = """                  GestureDetector(
                    onTap: _claimDailyBonus,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2)
                        ]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.yellow, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                '${(_profileData!['balance'] as num).toInt()} ĐIỂM',
                                style: const TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text("Nhấn để nhận quà hằng ngày 🎁", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),"""

content = content.replace(old_balance, new_balance, 1)

with open(filepath, "w") as f:
    f.write(content)
