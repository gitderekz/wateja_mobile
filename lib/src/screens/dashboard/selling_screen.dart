import 'package:flutter/material.dart';

class SellingScreen extends StatelessWidget {
  const SellingScreen({super.key});

  final List<Map<String, dynamic>> _marketItems = const [
    {
      'name': 'Organic Seeds - Tomato',
      'category': 'Seeds',
      'price': 12.99,
      'stock': 1250,
      'image': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=900',
      'description': 'High-quality organic tomato seeds for optimal yield',
    },
    {
      'name': 'Fertilizer NPK 20-20-20',
      'category': 'Fertilizer',
      'price': 45.50,
      'stock': 85,
      'image': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900',
      'description': 'Balanced NPK fertilizer for all crops',
    },
    {
      'name': 'Garden Hoe',
      'category': 'Tools',
      'price': 28.00,
      'stock': 45,
      'image': 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=900',
      'description': 'Durable steel garden hoe',
    },
    {
      'name': 'Irrigation Pipes - 50m',
      'category': 'Equipment',
      'price': 125.00,
      'stock': 5,
      'image': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?w=900',
      'description': 'Heavy-duty irrigation pipes for efficient water flow',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search market products',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Chip(label: Text('All')),
                SizedBox(width: 8),
                Chip(label: Text('Seeds')),
                SizedBox(width: 8),
                Chip(label: Text('Tools')),
                SizedBox(width: 8),
                Chip(label: Text('Fertilizer')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: _marketItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final item = _marketItems[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            item['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['category'],
                                style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${item['price']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text('${item['stock']} left', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Buy now'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
