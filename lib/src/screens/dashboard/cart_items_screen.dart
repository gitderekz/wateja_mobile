import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../widgets/payment_dialog.dart';
import '../../widgets/receipt_dialog.dart';
import '../../providers/settings_provider.dart';

class CartItemsScreen extends StatefulWidget {
  const CartItemsScreen({super.key});

  @override
  State<CartItemsScreen> createState() => _CartItemsScreenState();
}

class _CartItemsScreenState extends State<CartItemsScreen> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => loading = true);
    try {
      final client = ApiClient();
      final resp = await client.get('/cart');
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final parsed = jsonDecode(resp.body);
        List<dynamic> list = [];
        if (parsed is Map && parsed['cartItems'] is List) {
          list = parsed['cartItems'];
        } else if (parsed is Map && parsed['data'] is Map && parsed['data']['cartItems'] is List) {
          list = parsed['data']['cartItems'];
        } else if (parsed is List) {
          list = parsed;
        }
        items = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load cart: $e');
    }
    setState(() => loading = false);
  }

  double get total => items.fold(0.0, (p, e) => p + ((e['price'] ?? 0) as num).toDouble() * ((e['quantity'] ?? 1) as num).toDouble());

  Future<void> _updateQty(String id, int qty) async {
    if (qty <= 0) return _remove(id);
    try {
      final client = ApiClient();
      await client.put('/cart/$id', body: {'quantity': qty});
      final idx = items.indexWhere((e) => (e['id'] ?? e['_id']).toString() == id.toString());
      if (idx >= 0) setState(() => items[idx]['quantity'] = qty);
    } catch (e) {
      debugPrint('Failed to update qty: $e');
    }
  }

  Future<void> _remove(String id) async {
    try {
      final client = ApiClient();
      await client.delete('/cart/$id');
      setState(() => items.removeWhere((e) => (e['id'] ?? e['_id']).toString() == id.toString()));
    } catch (e) {
      debugPrint('Failed to remove cart item: $e');
    }
  }

  Future<void> _checkout() async {
    // open payment dialog first
    final paid = await showDialog<bool>(context: context, builder: (_) => PaymentDialog(amount: total));
    if (paid != true) return;

    try {
      final client = ApiClient();
      final body = {
        'items': items.map((it) => {
          'itemId': it['id'] ?? it['_id'],
          'itemType': it['itemType'] ?? 'lesson',
          'name': it['name'] ?? it['title'] ?? '',
          'price': it['price'] ?? 0,
          'quantity': it['quantity'] ?? 1,
        }).toList(),
        'totalAmount': total,
        'currency': 'USD',
        'createReceipt': true,
      };
      final resp = await client.post('/orders', body: body);
      if (!mounted) return;
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // Try to extract created receipt
        Map<String, dynamic>? createdReceipt;
        try {
          final p = jsonDecode(resp.body);
          if (p is Map && p['receipt'] != null) createdReceipt = Map<String, dynamic>.from(p['receipt']);
        } catch (_) {}
        setState(() => items = []);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order created')));
        if (createdReceipt != null) await showDialog(context: context, builder: (_) => ReceiptDialog(receipt: createdReceipt!));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create order')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart Items')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.shopping_cart, size: 64, color: Colors.grey), const SizedBox(height: 8), const Text('Your cart is empty')]))
                : Column(children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final it = items[i];
                          final id = (it['id'] ?? it['_id']).toString();
                          return ListTile(
                            leading: it['image'] != null ? Image.network(it['image'].toString(), width: 56, height: 56, fit: BoxFit.cover) : const Icon(Icons.shopping_bag),
                            title: Text(it['name'] ?? it['title'] ?? ''),
                            subtitle: Text(settings.formatCurrency(it['price'] ?? 0)),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _updateQty(id, ((it['quantity'] ?? 1) as num).toInt() - 1)),
                              Text('${it['quantity'] ?? 1}'),
                              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _updateQty(id, ((it['quantity'] ?? 1) as num).toInt() + 1)),
                              const SizedBox(width: 8),
                              IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _remove(id)),
                            ]),
                          );
                        },
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total', style: TextStyle(color: Colors.grey[700])), Text(settings.formatCurrency(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                          ElevatedButton.icon(onPressed: _checkout, icon: const Icon(Icons.payments), label: const Text('Checkout'))
                        ]),
                      ),
                    )
                  ]),
      ),
    );
  }
}
