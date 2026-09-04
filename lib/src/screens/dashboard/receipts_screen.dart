import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/receipt_dialog.dart';
import '../../widgets/transport_dialog.dart';
import '../../widgets/pagination.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  List<Map<String, dynamic>> receipts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    setState(() => loading = true);
    try {
      final client = ApiClient();
      final resp = await client.get('/receipts');
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final parsed = jsonDecode(resp.body);
        List<dynamic> list = [];
        if (parsed is Map && parsed['receipts'] is List) {
          list = parsed['receipts'];
        } else if (parsed is List) {
          list = parsed;
        }
        receipts = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load receipts: $e');
    }
    setState(() => loading = false);
  }

  Future<void> _showReceipt(Map<String, dynamic> r) async {
    await showDialog(context: context, builder: (ctx) => ReceiptDialog(receipt: r));
  }

  Future<void> _showOrderTransport(Map<String, dynamic> receipt) async {
    try {
      final client = ApiClient();
      final orderId = receipt['orderId'];
      if (orderId != null) {
        final resp = await client.get('/orders/$orderId');
        if (resp.statusCode == 200 && resp.body.isNotEmpty) {
          final parsed = jsonDecode(resp.body);
          Map<String, dynamic> order = {};
          if (parsed is Map && parsed['order'] != null) {
            order = Map<String, dynamic>.from(parsed['order']);
          } else if (parsed is Map) {
            order = Map<String, dynamic>.from(parsed);
          }
          if (mounted && order.isNotEmpty) {
            await showDialog(
              context: context,
              builder: (_) => TransportDialog(
                order: order,
                isEditable: false,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transport info: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Receipts')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : receipts.isEmpty
                ? const Center(child: Text('No receipts found'))
                : Column(children: [
                  Card(child: ListView.separated(itemCount: receipts.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (ctx, i) {
                    final r = receipts[i];
                    final status = (r['status'] ?? '').toString();
                    final bg = status == 'completed'
                      ? Colors.green.shade600
                      : status == 'pending'
                        ? Colors.orange.shade600
                        : status == 'cancelled'
                          ? Colors.red.shade600
                          : Colors.grey.shade600;
                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(r['receiptNumber']?.toString() ?? r['id']?.toString() ?? ''),
                      subtitle: Text('${r['customerName'] ?? ''} • ${settings.formatCurrency(r['amount'] ?? 0)}'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Chip(label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white)), backgroundColor: bg),
                        PopupMenuButton<int>(
                          itemBuilder: (ctx) => [
                            PopupMenuItem(value: 1, child: const Text('View Receipt')),
                            if ((r['orderId'] ?? null) != null) PopupMenuItem(value: 2, child: const Text('View Transport')),
                          ],
                          onSelected: (v) async {
                            if (v == 1) {
                              await _showReceipt(r);
                            } else if (v == 2) {
                              await _showOrderTransport(r);
                            }
                          },
                        ),
                      ]),
                      onTap: () => _showReceipt(r),
                    );
                  })),
                  const SizedBox(height: 8),
                  // simple pagination placeholder (client-side)
                  Pagination(page: 1, totalPages: 1, onPage: (_) {}),
                ]),
      ),
    );
  }
}
