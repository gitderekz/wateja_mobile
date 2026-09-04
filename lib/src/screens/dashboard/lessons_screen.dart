import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/settings_provider.dart';
// auth_notifier not required here
import '../../services/api_client.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  List<Map<String, dynamic>> lessons = [];
  bool loading = true;
  String? error;
  List<String> topics = [];
  String? selectedTopic;
  String search = '';

  @override
  void initState() {
    super.initState();
    fetchLessons();
  }

  Future<void> fetchLessons() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final client = ApiClient();
      final resp = await client.get('/lessons');
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final parsed = jsonDecode(resp.body);
        List<dynamic> data = [];
        if (parsed is Map && parsed.containsKey('lessons')) {
          data = parsed['lessons'];
        } else if (parsed is Map && parsed.containsKey('data')) {
          final d = parsed['data'];
          if (d is Map && d.containsKey('lessons')) {
            data = d['lessons'];
          } else if (d is List) {
            data = d;
          }
        } else if (parsed is List) {
          data = parsed;
        }

        lessons = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        topics = lessons.map((l) => (l['topic'] ?? '').toString()).where((t) => t.isNotEmpty).toSet().toList();
      } else {
        error = 'Failed to load lessons';
      }
    } catch (e) {
      error = 'Error: $e';
    }
    setState(() => loading = false);
  }

  List<Map<String, dynamic>> get filteredLessons {
    var list = lessons;
    if (selectedTopic != null && selectedTopic!.isNotEmpty) {
      list = list.where((l) => (l['topic'] ?? '') == selectedTopic).toList();
    }
    if (search.isNotEmpty) {
      list = list.where((l) => (l['title'] ?? '').toString().toLowerCase().contains(search.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Lessons')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search lessons'),
                onChanged: (v) => setState(() => search = v),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: selectedTopic,
              hint: const Text('Topic'),
              items: [const DropdownMenuItem(value: '', child: Text('All'))] +
                  topics.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => selectedTopic = (v == '') ? null : v),
            ),
          ]),
          const SizedBox(height: 12),
          if (loading) const Expanded(child: Center(child: CircularProgressIndicator())) else if (error != null) Expanded(child: Center(child: Text(error!))) else Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.78, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: filteredLessons.length,
              itemBuilder: (context, i) {
                final lesson = filteredLessons[i];
                final id = lesson['id']?.toString() ?? lesson['_id']?.toString() ?? i.toString();
                final title = lesson['title'] ?? 'Lesson';
                final price = lesson['price'] ?? 0;
                final img = lesson['image'] ?? (lesson['images'] is List && (lesson['images'] as List).isNotEmpty ? lesson['images'][0] : null);
                return GestureDetector(
                  onTap: () => GoRouter.of(context).go('/dashboard/lessons/$id'),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: img != null && img.toString().isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: img.toString().startsWith('http') ? img.toString() : '${ApiClient().baseUrl.replaceAll('/api','')}$img',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.book, size: 40, color: Colors.grey))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(title.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(settings.formatCurrency(price is num ? price : num.tryParse(price.toString()) ?? 0), style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(onPressed: () => GoRouter.of(context).go('/dashboard/lessons/$id'), icon: const Icon(Icons.chevron_right))
                          ])
                        ]),
                      )
                    ]),
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}
