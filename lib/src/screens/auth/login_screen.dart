import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;
  String _error = '';
  bool _remember = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final _auth = AuthService();

  Future<void> _submit() async {
    setState(() {
      _error = '';
      _loading = true;
    });
    final res = await _auth.login(_emailController.text.trim(), _passwordController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      final user = (res['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>?;
      final role = user != null ? (user['role'] as String?) : null;
      if (role == 'client' || _emailController.text.contains('client')) {
        context.go('/dashboard/selling');
      } else {
        context.go('/dashboard/home');
      }
    } else {
      setState(() => _error = res['error'] ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFFAF0), Color(0xFFEDF9F2)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: const [
                      Icon(Icons.spa, size: 56, color: Color(0xFF16A34A)),
                      SizedBox(height: 8),
                      Text('Phoisec', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Sign in to access dashboard', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Align(alignment: Alignment.centerLeft, child: Text('Welcome back', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
                          const SizedBox(height: 12),
                          if (_error.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: Colors.red[50], border: Border.all(color: Colors.red[200]!), borderRadius: BorderRadius.circular(8)),
                              child: Text(_error, style: const TextStyle(color: Colors.red)),
                            ),

                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Email', hintText: 'Enter your email'),
                          ),
                          const SizedBox(height: 12),

                          Stack(
                            children: [
                              TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: const InputDecoration(labelText: 'Password', hintText: 'Enter your password'),
                              ),
                              Positioned(
                                right: 0,
                                top: 8,
                                child: IconButton(
                                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                                  onPressed: () => setState(() => _showPassword = !_showPassword),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                                  const Text('Remember me')
                                ],
                              ),
                              TextButton(onPressed: () => context.go('/forgot-password'), child: const Text('Forgot password', style: TextStyle(color: Color(0xFF16A34A))))
                            ],
                          ),

                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign In'),
                            ),
                          ),

                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('Don\'t have an account? '),
                            TextButton(onPressed: () => context.go('/signup'), child: const Text('Sign up', style: TextStyle(color: Color(0xFF16A34A))))
                          ])
                        ],
                      ),
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
}
