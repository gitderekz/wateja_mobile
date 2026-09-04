import 'package:flutter/material.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  final List<Map<String, dynamic>> _products = const [
    {
      'name': 'Premium Tomato Seeds',
      'status': 'Approved',
      'price': 15.00,
      'quantity': 500,
      'category': 'Seeds',
      'image': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=900',
      'description': 'High-quality tomato seeds from my farm, excellent germination rate',
    },
    {
      'name': 'Organic Fertilizer Mix',
      'status': 'Pending',
      'price': 25.00,
      'quantity': 200,
      'category': 'Fertilizer',
      'image': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900',
      'description': 'Natural fertilizer made from compost and organic materials',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.separated(
          itemCount: _products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = _products[index];
            final statusColor = product['status'] == 'Approved' ? Colors.green : Colors.orange;
            return Card(
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.network(product['image'], fit: BoxFit.cover),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(product['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              Chip(label: Text(product['status']), backgroundColor: statusColor.withAlpha(30)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(product['description'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text('Category: ${product['category']}', style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 16),
                              Text('Qty: ${product['quantity']}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TZS ${product['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              TextButton(onPressed: () {}, child: const Text('Edit')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
