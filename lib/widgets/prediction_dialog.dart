import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:live_score/src/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';

class PredictionDialog extends StatefulWidget {
  final int matchId;
  final String homeName;
  final String awayName;

  const PredictionDialog({Key? key, required this.matchId, required this.homeName, required this.awayName}) : super(key: key);

  @override
  State<PredictionDialog> createState() => _PredictionDialogState();
}

class _PredictionDialogState extends State<PredictionDialog> {
  String _selectedResult = "HOME";
  double _stake = 100.0;
  bool _isLoading = false;

  Future<void> _placeBet() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      final response = await http.post(
        Uri.parse(Uri.parse('${AppConstants.backendBaseUrl}/gamification/predict/place').toString()),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}',
        },
        body: json.encode({
          'match_id': widget.matchId,
          'predicted_result': _selectedResult,
          'points_staked': _stake,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        auth.updateBalance(data['balance_remaining']);
        Navigator.pop(context, "Dự đoán thành công! Chờ thưởng: ${data['potential_reward']}");
      } else {
        Navigator.pop(context, "Lỗi: ${data['detail']}");
      }
    } catch (e) {
      Navigator.pop(context, "Lỗi mạng");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Chốt dự đoán"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: _selectedResult,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: "HOME", child: Text("Thắng: ${widget.homeName}")),
              const DropdownMenuItem(value: "DRAW", child: Text("Hòa")),
              DropdownMenuItem(value: "AWAY", child: Text("Thắng: ${widget.awayName}")),
            ],
            onChanged: (val) => setState(() => _selectedResult = val!),
          ),
          const SizedBox(height: 20),
          Text("Điểm cược: ${_stake.toInt()}"),
          Slider(
            value: _stake,
            min: 10,
            max: 1000,
            divisions: 99,
            onChanged: (val) => setState(() => _stake = val),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: _isLoading ? null : _placeBet,
          child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : const Text("Chốt"),
        ),
      ],
    );
  }
}
