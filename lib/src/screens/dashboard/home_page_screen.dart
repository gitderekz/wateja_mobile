import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_notifier.dart';
import '../../providers/settings_provider.dart';
import '../../services/api_client.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  Map<String, dynamic> summary = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => loading = true);
    try {
      final client = ApiClient();
      final resp = await client.get('/reports');
      if (resp.statusCode == 200) {
        final body = resp.body;
        if (body.isNotEmpty) {
          final Map<String, dynamic> parsed = jsonDecode(body) as Map<String, dynamic>;
          // Web returns response.data.summary; backend may return { data: { summary: {...} } }
          if (parsed.containsKey('data') && parsed['data'] is Map && (parsed['data'] as Map).containsKey('summary')) {
            summary = Map<String, dynamic>.from((parsed['data'] as Map)['summary'] as Map<String, dynamic>);
          } else if (parsed.containsKey('summary') && parsed['summary'] is Map) {
            summary = Map<String, dynamic>.from(parsed['summary'] as Map<String, dynamic>);
          } else if (parsed.containsKey('data') && parsed['data'] is Map) {
            summary = Map<String, dynamic>.from(parsed['data'] as Map<String, dynamic>);
          } else {
            // fallback: if API returns flat object
            summary = Map<String, dynamic>.from(parsed);
          }
        }
      }
    } catch (e) {
      // ignore
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthNotifier>(context);
    final name = auth.user?['name'] ?? 'User';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 12),
            Text('Welcome back, $name!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Here's what's happening with your farming platform today.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            if (loading) const Center(child: CircularProgressIndicator()) else Column(children: [
              _buildStats(),
              const SizedBox(height: 12),
              _buildChart(),
              _buildRecentActivities(),
            ])
          ]),
        ),
      ),
    );
  }

  Widget _buildStats() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    final role = auth.user?['role'] as String? ?? 'admin';

    List<Map<String, dynamic>> stats;
    if (role == 'client') {
      stats = [
        {'title': 'My Orders', 'value': (summary['totalOrders'] ?? 0).toString(), 'color': Colors.green, 'icon': Icons.shopping_cart},
        {'title': 'Total Spent', 'value': settings.formatCurrency(summary['totalRevenue'] ?? 0), 'color': Colors.blue, 'icon': Icons.attach_money},
        {'title': 'Active Lessons', 'value': (summary['totalLessons'] ?? 0).toString(), 'color': Colors.purple, 'icon': Icons.book},
        {'title': 'Consultations', 'value': (summary['totalConsultations'] ?? 0).toString(), 'color': Colors.orange, 'icon': Icons.message},
      ];
    } else if (role == 'stock') {
      stats = [
        {'title': 'Total Stock Items', 'value': (summary['totalStockItems'] ?? 0).toString(), 'color': Colors.green, 'icon': Icons.inventory},
        {'title': 'Low Stock Items', 'value': (summary['lowStockItems'] ?? '—').toString(), 'color': Colors.red, 'icon': Icons.trending_up},
        {'title': 'New Products', 'value': (summary['totalOrders'] ?? 0).toString(), 'color': Colors.blue, 'icon': Icons.new_releases},
        {'title': 'Stock Value', 'value': settings.formatCurrency(summary['totalRevenue'] ?? 0), 'color': Colors.purple, 'icon': Icons.paid},
      ];
    } else if (role == 'accountant') {
      stats = [
        {'title': 'Total Revenue', 'value': settings.formatCurrency(summary['totalRevenue'] ?? 0), 'color': Colors.green, 'icon': Icons.attach_money},
        {'title': 'Pending Payments', 'value': (summary['pendingPayments'] ?? 0).toString(), 'color': Colors.orange, 'icon': Icons.receipt},
        {'title': 'Monthly Sales', 'value': settings.formatCurrency(summary['monthlySales'] ?? summary['totalRevenue'] ?? 0), 'color': Colors.blue, 'icon': Icons.show_chart},
        {'title': 'Active Orders', 'value': (summary['totalOrders'] ?? 0).toString(), 'color': Colors.purple, 'icon': Icons.shopping_cart},
      ];
    } else {
      stats = [
        {'title': 'Total Sales', 'value': settings.formatCurrency(summary['totalRevenue'] ?? 0), 'color': Colors.green, 'icon': Icons.attach_money},
        {'title': 'Active Users', 'value': (summary['totalUsers'] ?? 0).toString(), 'color': Colors.blue, 'icon': Icons.people},
        {'title': 'Products', 'value': (summary['totalStockItems'] ?? 0).toString(), 'color': Colors.purple, 'icon': Icons.inventory},
        {'title': 'Orders', 'value': (summary['totalOrders'] ?? 0).toString(), 'color': Colors.orange, 'icon': Icons.shopping_cart},
      ];
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: stats.map((s) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            CircleAvatar(
              backgroundColor: (s['color'] as Color).withAlpha((0.12 * 255).round()),
              child: Icon(s['icon'] as IconData, color: s['color'] as Color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(s['title'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(s['value'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
            )
          ]),
        ),
      )).toList(),
    );
  }

  Widget _buildChart() {
    // Try to read a simple revenue series from summary, else synthesize
    final List<num> series = [];
    if (summary.containsKey('revenueByDay') && summary['revenueByDay'] is List) {
      for (final v in summary['revenueByDay']) {
        if (v is num) {
          series.add(v);
        }
      }
    }
    if (series.isEmpty) {
      final total = (summary['totalRevenue'] ?? 0) as num;
      if (total > 0) {
        // simple synthetic last-7-days split
        for (var i = 0; i < 7; i++) {
          series.add((total / 7) * (0.5 + (i / 14)));
        }
      } else {
        for (var i = 0; i < 7; i++) {
          series.add(0);
        }
      }
    }

    final maxVal = series.fold<num>(0, (p, e) => e > p ? e : p);

    return SizedBox(
      height: 90,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
            children: series.map((v) {
              final double height = maxVal > 0 ? (v / maxVal * 70).toDouble() : 4.0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                      Container(
                        height: height,
                        decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(4)),
                      ),
                    const SizedBox(height: 6),
                    Text('', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {

    final activities = <Map<String, String>>[
      {'action': 'Order completed', 'detail': 'Tomato Seeds', 'time': '2 days ago'},
      {'action': 'Lesson unlocked', 'detail': 'Modern Farming Basics', 'time': '1 week ago'},
      {'action': 'Consultation booked', 'detail': 'Soil Testing', 'time': '2 weeks ago'},
      {'action': 'Payment processed', 'detail': 'Fertilizer Purchase', 'time': '3 weeks ago'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final a = activities[i];
              return ListTile(
                dense: true,
                leading: CircleAvatar(child: Text(a['action']![0])),
                title: Text(a['action']!),
                subtitle: Text(a['detail']!),
                trailing: Text(a['time']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              );
            },
          ),
        ),
      ],
    );
  }
}

