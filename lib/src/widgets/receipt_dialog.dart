import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ReceiptDialog extends StatefulWidget {
  final Map<String, dynamic> receipt;
  const ReceiptDialog({super.key, required this.receipt});

  @override
  State<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<ReceiptDialog> {
  bool downloading = false;

  Future<void> _downloadPdf() async {
    setState(() => downloading = true);
    try {
      final client = ApiClient();
      final id = widget.receipt['id'] ?? widget.receipt['receiptNumber'];
      final resp = await client.get('/receipts/$id/download');
      if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
        final dir = Directory.systemTemp.createTempSync('wateja_receipt_');
        final file = File('${dir.path}/receipt-${id}.pdf');
        await file.writeAsBytes(resp.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No PDF available')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    } finally {
      if (mounted) setState(() => downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.receipt;
    return AlertDialog(
      title: Text('Receipt ${r['receiptNumber'] ?? r['id'] ?? ''}'),
      content: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Customer: ${r['customerName'] ?? r['customer']?['name'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Amount: ${r['amount']?.toString() ?? ''}'),
          const SizedBox(height: 8),
          const Divider(),
          if (r['items'] != null) ...[const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...(r['items'] as List).map((it) => ListTile(dense: true, title: Text(it['name'] ?? ''), subtitle: Text('Qty: ${it['quantity'] ?? 1} • ${it['total'] ?? it['price'] ?? ''}')))],
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        TextButton(onPressed: downloading ? null : _downloadPdf, child: downloading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Download PDF'))
      ],
    );
  }
}
