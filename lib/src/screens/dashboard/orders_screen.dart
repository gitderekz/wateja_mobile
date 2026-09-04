import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/payment_dialog.dart';
import '../../widgets/receipt_dialog.dart';
import '../../widgets/transport_dialog.dart';
import '../../widgets/appointment_dialog.dart';
import '../../widgets/agent_assignment_dialog.dart';
import '../../widgets/pagination.dart';
// auth provider not required in this screen

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool loading = true;
  String search = '';
  String statusFilter = 'all';
  int page = 1;
  int perPage = 10;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => loading = true);
    try {
      final client = ApiClient();
      final resp = await client.get('/orders');
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final parsed = jsonDecode(resp.body);
        List<dynamic> list = [];
        if (parsed is Map && parsed['orders'] is List) {
          list = parsed['orders'];
        } else if (parsed is List) {
          list = parsed;
        }
        orders = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      // ignore
    }
    setState(() => loading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    var items = orders;
    if (search.isNotEmpty) {
      items = items.where((o) {
        final numStr = (o['orderNumber'] ?? o['id'] ?? '').toString().toLowerCase();
        final name = (o['userName'] ?? '').toString().toLowerCase();
        return numStr.contains(search.toLowerCase()) || name.contains(search.toLowerCase());
      }).toList();
    }
    if (statusFilter != 'all') {
      items = items.where((o) => (o['status'] ?? '').toString() == statusFilter).toList();
    }
    return items;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      case 'paid':
        return Colors.indigo.shade600;
      case 'processing':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Future<void> _showDetails(Map<String, dynamic> order) async {
    final rootContext = context;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text('Order ${order['orderNumber'] ?? order['id'] ?? ''}'),
        content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Customer: ${order['userName'] ?? order['customerName'] ?? ''}'),
          const SizedBox(height: 8),
          Text('Total: ${settings.formatCurrency(order['totalAmount'] ?? order['total'] ?? 0)}'),
          const SizedBox(height: 8),
          if ((order['isTransporting'] ?? false))
            Chip(
              label: Text('Transport Status: ${order['transportationStatus']?.toString().toUpperCase() ?? 'PENDING'}'),
              backgroundColor: Colors.orange.shade200,
            ),
          const SizedBox(height: 12),
          const Divider(),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...(order['items'] as List<dynamic>? ?? []).map((it) => ListTile(
            dense: true,
            title: Text(it['name']?.toString() ?? ''),
            subtitle: Text('Qty: ${it['quantity'] ?? 1} • ${settings.formatCurrency(it['price'] ?? 0)}'),
          )),
          if ((order['region'] ?? '').toString().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text('Delivery Location', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${order['region'] ?? ''}, ${order['district'] ?? ''}'),
                if ((order['townVillage'] ?? '').toString().isNotEmpty)
                  Text(order['townVillage'] ?? ''),
              ],
            ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            await showDialog(
              context: rootContext,
              builder: (_) => AppointmentDialog(
                order: order,
                isEditable: true,
                onUpdate: _loadOrders,
              ),
            );
          }, child: const Text('Appointment')),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            await showDialog(
              context: rootContext,
              builder: (_) => AgentAssignmentDialog(
                order: order,
                onUpdate: _loadOrders,
              ),
            );
          }, child: const Text('Assign Agent')),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            await showDialog(
              context: rootContext,
              builder: (_) => TransportDialog(
                order: order,
                isEditable: true,
                onUpdate: _loadOrders,
              ),
            );
          }, child: const Text('Transport')),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            final paid = await showDialog<bool>(context: rootContext, builder: (_) => PaymentDialog(orderId: (order['id'] ?? order['orderNumber'])?.toString(), amount: (order['totalAmount'] ?? order['total'] ?? 0) is num ? (order['totalAmount'] ?? order['total'] ?? 0).toDouble() : double.tryParse((order['totalAmount'] ?? order['total'] ?? 0).toString()) ?? 0));
            if (!mounted) return;
            if (paid == true) ScaffoldMessenger.of(rootContext).showSnackBar(const SnackBar(content: Text('Payment action sent')));
          }, child: const Text('Make Payment')),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            // attempt to view receipt
            Map<String, dynamic>? receipt;
            try {
              // try to fetch receipt by order id
              final client = ApiClient();
              final id = order['receiptId'] ?? order['receipt'] ?? order['receiptNumber'];
              if (id != null) {
                final resp = await client.get('/receipts/$id');
                if (resp.statusCode == 200 && resp.body.isNotEmpty) {
                  final p = jsonDecode(resp.body);
                  if (p is Map && p['receipt'] != null) receipt = Map<String, dynamic>.from(p['receipt']);
                  else if (p is Map) receipt = Map<String, dynamic>.from(p);
                }
              }
            } catch (_) {}
            if (!mounted) return;
            if (receipt != null) await showDialog(context: rootContext, builder: (_) => ReceiptDialog(receipt: receipt!));
            else ScaffoldMessenger.of(rootContext).showSnackBar(const SnackBar(content: Text('No receipt found')));
          }, child: const Text('View Receipt'))
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    // auth not needed here currently
    final filtered = _filtered;
    final totalPages = (filtered.length / perPage).ceil().clamp(1, 9999);
    final pageItems = filtered.skip((page - 1) * perPage).take(perPage).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search orders or customer'), onChanged: (v) { setState(() { search = v; page = 1; }); })),
            const SizedBox(width: 12),
            DropdownButton<String>(value: statusFilter, items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'payment', child: Text('Payment')),
              DropdownMenuItem(value: 'paid', child: Text('Paid')),
              DropdownMenuItem(value: 'processing', child: Text('Processing')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ], onChanged: (v) { setState(() { statusFilter = v ?? 'all'; page = 1; }); }),
          ]),
          const SizedBox(height: 12),

          if (loading) const Expanded(child: Center(child: CircularProgressIndicator())) else Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: pageItems.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final o = pageItems[i];
                  final status = (o['status'] ?? '').toString();
                  return ListTile(
                      onTap: () => _showDetails(o),
                    leading: CircleAvatar(backgroundColor: _statusColor(status).withAlpha(30), child: Icon(Icons.receipt_long, color: _statusColor(status))),
                    title: Text('Order ${o['orderNumber'] ?? o['id'] ?? ''}'),
                    subtitle: Text('${o['userName'] ?? ''} • ${settings.formatCurrency(o['totalAmount'] ?? o['total'] ?? 0)}'),
                      trailing: Column(mainAxisSize: MainAxisSize.min, children: [
                        Chip(label: Text(status.isNotEmpty ? status.toUpperCase() : '—', style: const TextStyle(color: Colors.white)), backgroundColor: _statusColor(status)),
                        const SizedBox(height: 6),
                        PopupMenuButton<int>(itemBuilder: (ctx) => [
                          PopupMenuItem(value: 1, child: const Text('Appointment')),
                          PopupMenuItem(value: 2, child: const Text('Assign Agent')),
                          PopupMenuItem(value: 3, child: const Text('Transport')),
                          PopupMenuItem(value: 4, child: const Text('Make Payment')),
                          PopupMenuItem(value: 5, child: const Text('View Receipt'))
                        ], onSelected: (v) async {
                          if (v == 1) {
                            await showDialog(
                              context: context,
                              builder: (_) => AppointmentDialog(
                                order: o,
                                isEditable: true,
                                onUpdate: _loadOrders,
                              ),
                            );
                          } else if (v == 2) {
                            await showDialog(
                              context: context,
                              builder: (_) => AgentAssignmentDialog(
                                order: o,
                                onUpdate: _loadOrders,
                              ),
                            );
                          } else if (v == 3) {
                            await showDialog(
                              context: context,
                              builder: (_) => TransportDialog(
                                order: o,
                                isEditable: true,
                                onUpdate: _loadOrders,
                              ),
                            );
                          } else if (v == 4) {
                            final paid = await showDialog<bool>(context: context, builder: (_) => PaymentDialog(orderId: (o['id'] ?? o['orderNumber'])?.toString(), amount: (o['totalAmount'] ?? o['total'] ?? 0) is num ? (o['totalAmount'] ?? o['total'] ?? 0).toDouble() : double.tryParse((o['totalAmount'] ?? o['total'] ?? 0).toString()) ?? 0));
                            if (paid == true && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment action sent')));
                          } else if (v == 5) {
                            Map<String, dynamic>? receipt;
                            try {
                              final client = ApiClient();
                              final id = o['receiptId'] ?? o['receipt'] ?? o['receiptNumber'];
                              if (id != null) {
                                final resp = await client.get('/receipts/$id');
                                if (resp.statusCode == 200 && resp.body.isNotEmpty) {
                                  final p = jsonDecode(resp.body);
                                  if (p is Map && p['receipt'] != null) receipt = Map<String, dynamic>.from(p['receipt']);
                                  else if (p is Map) receipt = Map<String, dynamic>.from(p);
                                }
                              }
                            } catch (_) {}
                            if (receipt != null) await showDialog(context: context, builder: (_) => ReceiptDialog(receipt: receipt!));
                            else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No receipt found')));
                          }
                        })
                      ]),
                  );
                },
              ),
            ),
          ),

          // Pagination
          const SizedBox(height: 8),
          Pagination(page: page, totalPages: totalPages, onPage: (p) => setState(() => page = p))
        ]),
      ),
    );
  }
}
