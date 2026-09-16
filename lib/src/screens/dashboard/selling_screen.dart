import 'package:flutter/material.dart';

class SellingScreen extends StatefulWidget {
  const SellingScreen({super.key});

  @override
  State<SellingScreen> createState() => _SellingScreenState();
}

class _SellingScreenState extends State<SellingScreen> {
  final List<Map<String, dynamic>> _allItems = const [
    {'name': 'Organic Seeds - Tomato', 'category': 'Seeds', 'price': 12.99, 'stock': 1250, 'image': 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=900', 'description': 'High-quality organic tomato seeds for optimal yield', 'rating': 4.8, 'tag': 'Organic'},
    {'name': 'Fertilizer NPK 20-20-20', 'category': 'Fertilizer', 'price': 45.50, 'stock': 85, 'image': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900', 'description': 'Balanced NPK fertilizer for all crops', 'rating': 4.6, 'tag': 'Best seller'},
    {'name': 'Garden Hoe', 'category': 'Tools', 'price': 28.00, 'stock': 45, 'image': 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=900', 'description': 'Durable steel garden hoe', 'rating': 4.4, 'tag': 'New'},
    {'name': 'Irrigation Pipes - 50m', 'category': 'Equipment', 'price': 125.00, 'stock': 5, 'image': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?w=900', 'description': 'Heavy-duty irrigation pipes for efficient water flow', 'rating': 4.9, 'tag': 'Hot'},
    {'name': 'Organic Seeds - Corn', 'category': 'Seeds', 'price': 18.99, 'stock': 890, 'image': 'https://images.unsplash.com/photo-1551375685-8c0ba6da0e2b?w=900', 'description': 'Premium corn seeds with excellent germination rate', 'rating': 4.7, 'tag': 'Organic'},
    {'name': 'Pesticide - Organic', 'category': 'Pesticide', 'price': 35.00, 'stock': 150, 'image': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=900', 'description': 'Eco-friendly organic pesticide for crop protection', 'rating': 4.5, 'tag': 'Certified'},
    {'name': 'Drip Irrigation Kit', 'category': 'Equipment', 'price': 210.00, 'stock': 18, 'image': 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?w=900', 'description': 'Complete kit for drip water efficiency and savings', 'rating': 4.9, 'tag': 'Popular'},
    {'name': 'Premium Compost', 'category': 'Fertilizer', 'price': 52.00, 'stock': 67, 'image': 'https://images.unsplash.com/photo-1471193945509-9ad0617afabf?w=900', 'description': 'Nutrient-rich compost for healthy soil and yields', 'rating': 4.6, 'tag': 'Eco'},
  ];

  final List<String> _categories = const ['All', 'Seeds', 'Fertilizer', 'Tools', 'Equipment', 'Pesticide'];
  final List<String> _sortOptions = const ['Newest', 'Lowest Price', 'Highest Price', 'Best Rated'];

  String _search = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Newest';
  bool _gridView = true;
  int _page = 1;
  final int _itemsPerPage = 4;

  List<Map<String, dynamic>> get _filteredItems {
    var items = [..._allItems];

    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      items = items.where((item) {
        final name = (item['name'] as String).toLowerCase();
        final category = (item['category'] as String).toLowerCase();
        final desc = (item['description'] as String).toLowerCase();
        return name.contains(q) || category.contains(q) || desc.contains(q);
      }).toList();
    }

    if (_selectedCategory != 'All') {
      items = items.where((item) => item['category'] == _selectedCategory).toList();
    }

    switch (_selectedSort) {
      case 'Lowest Price':
        items.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
        break;
      case 'Highest Price':
        items.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
        break;
      case 'Best Rated':
        items.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
        break;
      case 'Newest':
      default:
        break;
    }

    return items;
  }

  int get _totalPages => ((_filteredItems.length / _itemsPerPage).ceil() < 1) ? 1 : (_filteredItems.length / _itemsPerPage).ceil();

  List<Map<String, dynamic>> get _pagedItems {
    final start = (_page - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    return _filteredItems.sublist(start, end > _filteredItems.length ? _filteredItems.length : end);
  }

  void _onAddToCart(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} added to cart')),
    );
  }

  void _onViewDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(item['image'], width: double.infinity, height: 180, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              Text(item['description']),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text('${item['rating']}'),
                  const Spacer(),
                  Text('Stock: ${item['stock']}'),
                ],
              ),
              const SizedBox(height: 12),
              Text('Price: TZS ${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () {
            Navigator.pop(context);
            _onAddToCart(item);
          }, child: const Text('Add to cart')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _filteredItems.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_alt_outlined)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(
              hintText: 'Search products, categories, location',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: const WidgetStatePropertyAll(Color(0xFFF4F5F7)),
              onChanged: (value) {
                setState(() {
                  _search = value;
                  _page = 1;
                });
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _categories[index];
                  final active = item == _selectedCategory;
                  return ChoiceChip(
                    label: Text(item),
                    selected: active,
                    selectedColor: Colors.green.shade700,
                    labelStyle: TextStyle(color: active ? Colors.white : Colors.black87),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = item;
                        _page = 1;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        isExpanded: true,
                        items: _sortOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSort = value;
                              _page = 1;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _gridView = true),
                        icon: Icon(Icons.grid_view, color: _gridView ? Colors.green.shade700 : Colors.black54),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _gridView = false),
                        icon: Icon(Icons.view_list, color: !_gridView ? Colors.green.shade700 : Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(child: Text('No products found'))
                  : (_gridView
                      ? GridView.builder(
                          itemCount: _pagedItems.length,
                          padding: const EdgeInsets.only(bottom: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (_, index) {
                            final item = _pagedItems[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Image.network(item['image'], width: double.infinity, height: 150, fit: BoxFit.cover),
                                      Positioned(
                                        left: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade700,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(item['tag'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['category'], style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 6),
                                          Text(item['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 14, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text('${item['rating']}'),
                                              const Spacer(),
                                              Text('Stock ${item['stock']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('TZS ${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              IconButton(
                                                onPressed: () => _onAddToCart(item),
                                                icon: const Icon(Icons.add_shopping_cart),
                                                tooltip: 'Add to cart',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () => _onViewDetails(item),
                                              child: const Text('View'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: _pagedItems.length,
                          padding: const EdgeInsets.only(bottom: 8),
                          itemBuilder: (_, index) {
                            final item = _pagedItems[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 110,
                                    height: 128,
                                    child: Image.network(item['image'], fit: BoxFit.cover),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['category'], style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 6),
                                          Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                          const SizedBox(height: 6),
                                          Text(item['description'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 14, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text('${item['rating']}'),
                                              const Spacer(),
                                              Text('Stock ${item['stock']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('TZS ${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                              Row(
                                                children: [
                                                  TextButton(onPressed: () => _onViewDetails(item), child: const Text('View')),
                                                  ElevatedButton(onPressed: () => _onAddToCart(item), child: const Text('Buy')),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        )),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing ${_pagedItems.length} of $totalCount products'),
                Row(
                  children: [
                    IconButton(
                      onPressed: _page > 1 ? () => setState(() => _page--) : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('Page $_page / $_totalPages'),
                    IconButton(
                      onPressed: _page < _totalPages ? () => setState(() => _page++) : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
