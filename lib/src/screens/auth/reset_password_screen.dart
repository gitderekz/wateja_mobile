import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;
  final String? email;
  const ResetPasswordScreen({super.key, this.token, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;
  bool _loading = false;
  bool _success = false;
  String _error = '';

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    setState(() { _error=''; });
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (_newCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() => _loading = true);
    final auth = AuthService();
    final token = widget.token ?? Uri.base.queryParameters['token'] ?? '';
    final email = widget.email ?? Uri.base.queryParameters['email'] ?? '';
    final res = await auth.resetPassword(email, token, _newCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      setState(() { _success = true; });
      // redirect after short delay
      Timer(const Duration(seconds: 2), () => GoRouter.of(context).go('/login'));
    } else {
      setState(() { _error = res['error'] ?? 'Reset failed'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // if token/email not provided, redirect to forgot-password
    final token = widget.token ?? Uri.base.queryParameters['token'];
    final email = widget.email ?? Uri.base.queryParameters['email'];
    if (token == null || email == null) {
      // navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) => GoRouter.of(context).go('/forgot-password'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEFFAF0), Color(0xFFEDF9F2)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Column(children: const [Icon(Icons.spa, size: 56, color: Color(0xFF16A34A)), SizedBox(height: 8), Text('Phoisec', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))) ]),
                const SizedBox(height: 12),
                Text(_success ? 'Password Reset Successful!' : 'Set a new password', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 8, child: Padding(padding: const EdgeInsets.all(20), child: _success ? _successView() : _formView(email))),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formView(String email) {
    return Column(children: [
      Row(children: [IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => GoRouter.of(context).go('/login')), const SizedBox(width: 8), const Text('Reset Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))]),
      const SizedBox(height: 10),
      Text('Enter a new password for $email', style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      if (_error.isNotEmpty) Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.red[50], border: Border.all(color: Colors.red[200]!), borderRadius: BorderRadius.circular(8)), child: Text(_error, style: const TextStyle(color: Colors.red))),
      const SizedBox(height: 6),
      Stack(children: [TextField(controller: _newCtrl, obscureText: !_showNew, decoration: const InputDecoration(labelText: 'New Password', hintText: 'Enter new password')), Positioned(right: 0, top: 6, child: IconButton(icon: Icon(_showNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]), onPressed: () => setState(()=>_showNew = !_showNew)))]),
      const SizedBox(height: 10),
      Stack(children: [TextField(controller: _confirmCtrl, obscureText: !_showConfirm, decoration: const InputDecoration(labelText: 'Confirm Password', hintText: 'Confirm new password')), Positioned(right: 0, top: 6, child: IconButton(icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]), onPressed: () => setState(()=>_showConfirm = !_showConfirm)))]),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _reset, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(vertical: 14)), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Reset Password')))
    ]);
  }

  Widget _successView() {
    return Column(children: [
      const SizedBox(height: 8),
      Icon(Icons.check_circle, size: 64, color: Colors.green[600]),
      const SizedBox(height: 12),
      const Text('Password Reset!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('Your password has been successfully reset.', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 8),
      const Text('Redirecting to login page...', style: TextStyle(color: Colors.grey)),
    ]);
  }
}
