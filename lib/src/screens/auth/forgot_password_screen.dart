import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _success = false;
  String _error = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    setState(() { _loading = true; _error = ''; });
    final auth = AuthService();
    final res = await auth.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() { _loading = false; });
    if (res['success'] == true) {
      setState(() { _success = true; });
    } else {
      setState(() { _error = res['error'] ?? 'Failed to send reset email'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEFFAF0), Color(0xFFEDF9F2)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(children: const [Icon(Icons.spa, size: 56, color: Color(0xFF16A34A)), SizedBox(height: 8), Text('Phoisec', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))) ]),
                  const SizedBox(height: 12),
                  Text(_success ? 'Check Your Email' : 'Reset your password', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _success ? _buildSuccess(context) : _buildForm(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(children: [
      Row(children: [IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/login')), const SizedBox(width: 8), const Text('Reset Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))]),
      const SizedBox(height: 10),
      const Text('Enter your email address and we\'ll send you a link to reset your password.', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      if (_error.isNotEmpty) Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.red[50], border: Border.all(color: Colors.red[200]!), borderRadius: BorderRadius.circular(8)), child: Text(_error, style: const TextStyle(color: Colors.red))),
      const SizedBox(height: 6),
      TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', hintText: 'Enter your email')),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _sendReset, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(vertical: 14)), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Reset Link')))
    ]);
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 8),
      Icon(Icons.check_circle, size: 64, color: Colors.green[600]),
      const SizedBox(height: 12),
      const Text('Email Sent!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('If an account with ${_emailCtrl.text} exists, we\'ve sent a password reset link to that email address.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: () => context.go('/login'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)), child: const Text('Back to Login'))
    ]);
  }
}
