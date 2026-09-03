import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Register fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _otpChannel = 'email';
  bool _showPassword = false;
  bool _showConfirm = false;
  String _error = '';
  bool _loading = false;

  // OTP step
  bool _otpSent = false;
  String _otpCode = '';
  int _countdown = 0;
  Timer? _timer;
  String? _registeredUserId;
  final _auth = AuthService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_countdown <= 1) {
          _countdown = 0;
          t.cancel();
        } else {
          _countdown--;
        }
      });
    });
  }

  Future<void> _register() async {
    setState(() {
      _error = '';
    });
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _loading = true);
    final payload = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'otpChannel': _otpChannel,
    };
    final res = await _auth.register(payload);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>?;
      setState(() {
        _otpSent = true;
        _registeredUserId = data?['userId']?.toString();
      });
      _startCountdown();
    } else {
      setState(() => _error = res['error'] ?? 'Registration failed');
    }
  }

  Future<void> _verifyOtp() async {
    if (_registeredUserId == null) {
      setState(() => _error = 'Missing user id for verification');
      return;
    }
    setState(() => _loading = true);
    final res = await _auth.verifyOtp(_registeredUserId!, _otpCode);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      context.go('/dashboard/home');
    } else {
      setState(() => _error = res['error'] ?? 'Verification failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFEFFAF0), Color(0xFFEDF9F2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
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
                  const Text('Create your account', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _otpSent ? _buildOtpStep() : _buildRegisterStep(),
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

  Widget _buildRegisterStep() {
    return Column(
      children: [
        const Align(alignment: Alignment.centerLeft, child: Text('Sign up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
        const SizedBox(height: 12),
        if (_error.isNotEmpty) Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.red[50], border: Border.all(color: Colors.red[200]!), borderRadius: BorderRadius.circular(8)), child: Text(_error, style: const TextStyle(color: Colors.red))),

        TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full name', hintText: 'Enter your full name')),
        const SizedBox(height: 10),
        TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', hintText: 'Enter your email')),
        const SizedBox(height: 10),
        TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (optional)', hintText: '+255 XXX XXX XXX')),
        const SizedBox(height: 12),

        Align(alignment: Alignment.centerLeft, child: const Text('Verification Method')),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _otpChannel == 'email' ? const Color(0xFFECFDF5) : null, foregroundColor: _otpChannel == 'email' ? const Color(0xFF064E3B) : null), onPressed: () => setState(() => _otpChannel = 'email'), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.mail, size: 18), SizedBox(width: 6), Text('Email')])) ,),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _otpChannel == 'sms' ? const Color(0xFFECFDF5) : null, foregroundColor: _otpChannel == 'sms' ? const Color(0xFF064E3B) : null), onPressed: () => setState(() => _otpChannel = 'sms'), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.smartphone, size: 18), SizedBox(width: 6), Text('SMS')])) ,),
        ]),

        const SizedBox(height: 12),
        Stack(children: [
          TextField(controller: _passwordCtrl, obscureText: !_showPassword, decoration: const InputDecoration(labelText: 'Password', hintText: 'Enter your password')),
          Positioned(right: 0, top: 6, child: IconButton(icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]), onPressed: () => setState(() => _showPassword = !_showPassword)))
        ]),
        const SizedBox(height: 10),
        Stack(children: [
          TextField(controller: _confirmCtrl, obscureText: !_showConfirm, decoration: const InputDecoration(labelText: 'Confirm Password', hintText: 'Confirm password')),
          Positioned(right: 0, top: 6, child: IconButton(icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]), onPressed: () => setState(() => _showConfirm = !_showConfirm)))
        ]),

        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _register, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(vertical: 14)), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign Up'))),

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Already have account? '), TextButton(onPressed: () => context.go('/login'), child: const Text('Sign in', style: TextStyle(color: Color(0xFF16A34A))))])
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(children: [
      const Align(alignment: Alignment.centerLeft, child: Text('Enter Verification Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
      const SizedBox(height: 8),
      const Text('A 6-digit code was sent to your selected channel', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 12),
      if (_error.isNotEmpty) Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.red[50], border: Border.all(color: Colors.red[200]!), borderRadius: BorderRadius.circular(8)), child: Text(_error, style: const TextStyle(color: Colors.red))),

      TextField(textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 6, onChanged: (v) => setState(() => _otpCode = v.replaceAll(RegExp('[^0-9]'), '').padRight(0)), decoration: const InputDecoration(counterText: '' ,hintText: '000000',), style: const TextStyle(letterSpacing: 8, fontFamily: 'monospace', fontSize: 20)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Via: ${_otpChannel.toUpperCase()}'), Row(children: [TextButton(onPressed: _otpChannel=='email' ? null : () => setState(()=>_otpChannel='email'), child: const Text('Email')), TextButton(onPressed: _otpChannel=='sms' ? null : () => setState(()=>_otpChannel='sms'), child: const Text('SMS'))])]),

      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: (_loading || _otpCode.length!=6) ? null : _verifyOtp, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(vertical: 14)), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify Account'))),

      const SizedBox(height: 12),
      TextButton(onPressed: (_countdown>0) ? null : () { _startCountdown(); /* TODO: resend OTP */ }, child: Text(_countdown>0 ? 'Resend in ${_countdown}s' : 'Resend Code')),
      const SizedBox(height: 8),
      TextButton(onPressed: () => setState(()=> _otpSent=false), child: const Text('← Back to registration'))
    ]);
  }
}
