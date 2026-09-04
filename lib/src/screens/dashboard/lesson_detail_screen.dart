import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/api_client.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class LessonDetailScreen extends StatefulWidget {
  final String? id;
  const LessonDetailScreen({super.key, this.id});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  Map<String, dynamic>? lesson;
  bool loading = true;
  String? error;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadLesson() async {
    setState(() => loading = true);
    try {
      final client = ApiClient();
      final resp = await client.get('/lessons/${widget.id}');
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final parsed = jsonDecode(resp.body);
        Map<String, dynamic> data = {};
        if (parsed is Map && parsed.containsKey('lesson')) {
          data = Map<String, dynamic>.from(parsed['lesson']);
        } else if (parsed is Map && parsed.containsKey('data')) {
          data = Map<String, dynamic>.from(parsed['data']);
        } else if (parsed is Map) {
          data = Map<String, dynamic>.from(parsed);
        }
        lesson = data;

        final videoUrl = (lesson?['videoUrl'] ?? lesson?['video'] ?? '').toString();
        if (videoUrl.isNotEmpty) {
          final fullUrl = videoUrl.startsWith('http') ? videoUrl : '${ApiClient().baseUrl.replaceAll('/api','')}$videoUrl';
          _videoController = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
          await _videoController?.initialize();
          if (!mounted) return;
          setState(() {});
        }
      } else {
        error = 'Failed to load lesson';
      }
    } catch (e) {
      error = 'Error: $e';
    }
    setState(() => loading = false);
  }

  Future<void> _addToCart() async {
    try {
      final client = ApiClient();
      final price = _numFrom(lesson?['price']) ?? 0;
      final body = {
        'itemId': lesson?['id'] ?? lesson?['_id'],
        'itemType': 'lesson',
        'name': lesson?['title'] ?? 'Lesson',
        'description': lesson?['content'] ?? '',
        'price': price,
        'quantity': 1,
      };
      final resp = await client.post('/cart', body: body);
      if (!mounted) return;
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add to cart')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _buyNow() async {
    try {
      final client = ApiClient();
      final itemId = lesson?['id'] ?? lesson?['_id'];
      final price = _numFrom(lesson?['price']) ?? 0;
      final body = {
        'items': [
          {
            'itemId': itemId,
            'itemType': 'lesson',
            'name': lesson?['title'] ?? 'Lesson',
            'price': price,
            'quantity': 1,
          }
        ],
        'totalAmount': price,
        'currency': 'USD'
      };

      final resp = await client.post('/orders', body: body);
      if (!mounted) return;
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order created successfully')));
        // Navigate to orders/receipts page if exists
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
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
      appBar: AppBar(title: Text(lesson?['title'] ?? 'Lesson')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (lesson?['image'] != null && lesson!['image'].toString().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(imageUrl: lesson!['image'].toString().startsWith('http') ? lesson!['image'] : '${ApiClient().baseUrl.replaceAll('/api','')}${lesson!['image']}', height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 12),
                    Text(lesson?['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(settings.formatCurrency(_numFrom(lesson?['price']) ?? 0), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green)),
                    const SizedBox(height: 12),
                    if (_videoController != null && _videoController!.value.isInitialized)
                      AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: Stack(children: [VideoPlayer(_videoController!), Positioned.fill(child: GestureDetector(onTap: () { setState(() { _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play(); }); },),),])),
                    const SizedBox(height: 12),
                    // Render content from the backend (HTML tags stripped for mobile display)
                    if ((lesson?['content'] ?? '').toString().isNotEmpty)
                      Text(_stripHtml(lesson?['content'] ?? ''), style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(child: ElevatedButton.icon(onPressed: _addToCart, icon: const Icon(Icons.shopping_cart), label: const Text('Add to cart'))),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(onPressed: _buyNow, icon: const Icon(Icons.payment), label: const Text('Buy now'))
                    ])
                  ]),
                ),
    );
  }

  String _stripHtml(String html) {
    try {
      return html.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (e) {
      return html;
    }
  }

  num? _numFrom(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) return num.tryParse(v.replaceAll(',', ''));
    return null;
  }
}
