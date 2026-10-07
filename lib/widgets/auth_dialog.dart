import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({Key? key}) : super(key: key);

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;

  void _submit() async {
    if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    String? errorMsg;
    
    if (_isLoginMode) {
      errorMsg = await auth.login(_userCtrl.text, _passCtrl.text);
    } else {
      errorMsg = await auth.register(_userCtrl.text, _passCtrl.text);
    }
    
    if (errorMsg == null && mounted) {
      context.read<NotificationProvider>().startPolling(auth);
      Navigator.pop(context); // Tắt popup khi thành công
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vào sân thành công!')));
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg ?? 'Lỗi không xác định')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isAuthenticated) {
      return const SizedBox.shrink();
    }

    // Nếu CHƯA đăng nhập -> Hiển thị Form Mini
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Text(_isLoginMode ? "ĐĂNG NHẬP" : "ĐĂNG KÝ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _userCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Username',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
            child: Text(
              _isLoginMode ? "Chưa có tài khoản? Tạo ngay" : "Đã có tài khoản? Đăng nhập",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white)) : const Text("Chốt", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
