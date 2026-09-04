import 'package:flutter/material.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  final List<Map<String, dynamic>> _consultations = const [
    {
      'title': 'Soil Testing & Analysis',
      'expert': 'Dr. John Smith',
      'price': 150000,
      'topic': 'Soil Health',
      'image': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900',
      'description': 'Get professional soil testing and personalized recommendations.',
    },
    {
      'title': 'Crop Disease Diagnosis',
      'expert': 'Dr. Sarah Johnson',
      'price': 120000,
      'topic': 'Plant Health',
      'image': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=900',
      'description': 'Expert diagnosis and treatment for crop diseases.',
    },
    {
      'title': 'Farm Business Planning',
      'expert': 'Prof. Michael Brown',
      'price': 200000,
      'topic': 'Business',
      'image': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?w=900',
      'description': 'Strategic business planning for your farming operations.',
    },
    {
      'title': 'Irrigation System Design',
      'expert': 'Eng. David Wilson',
      'price': 180000,
      'topic': 'Irrigation',
      'image': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900',
      'description': 'Custom irrigation system design for your farm.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultation')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search experts or topics',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Chip(label: Text('All')),
                SizedBox(width: 8),
                Chip(label: Text('Soil Health')),
                SizedBox(width: 8),
                Chip(label: Text('Irrigation')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _consultations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _consultations[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 140,
                          child: Image.network(item['image'], fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['topic'], style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(item['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('Expert: ${item['expert']}', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text(item['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('TZS ${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text('Book'),
                                    ),
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
          ],
        ),
      ),
    );
  }
}
