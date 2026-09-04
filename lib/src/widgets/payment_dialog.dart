import 'package:flutter/material.dart';
import '../services/api_client.dart';

class PaymentDialog extends StatefulWidget {
  final String? orderId;
  final double amount;
  const PaymentDialog({super.key, this.orderId, required this.amount});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String provider = 'mpesa';
  String method = 'mobile_money';
  bool loading = false;
  final _phoneCtl = TextEditingController();

  Future<void> _submit() async {
    setState(() => loading = true);
    try {
      final client = ApiClient();
      final body = {
        'paymentMethod': method,
        'paymentProvider': provider,
        'customerPhone': _phoneCtl.text,
        'amount': widget.amount,
      };
      // Try endpoint: /orders/:id/pay or fallback /payments
      if (widget.orderId != null) {
        await client.post('/orders/${widget.orderId}/pay', body: body);
      } else {
        await client.post('/payments', body: body);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      Navigator.pop(context, false);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Make Payment'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Amount: ${widget.amount.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        TextField(controller: _phoneCtl, decoration: const InputDecoration(labelText: 'Phone')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(initialValue: provider, items: const [
          DropdownMenuItem(value: 'mpesa', child: Text('MPESA')),
          DropdownMenuItem(value: 'tigo', child: Text('Tigo Pesa')),
          DropdownMenuItem(value: 'card', child: Text('Card')),
        ], onChanged: (v) => setState(() => provider = v ?? provider)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: loading ? null : _submit, child: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Pay'))
      ],
    );
  }
}
