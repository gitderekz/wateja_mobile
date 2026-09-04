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
  List<Map<String, String>> recentActivities = [];

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
    await _loadRecentActivities();
    setState(() => loading = false);
  }

  Future<void> _loadRecentActivities() async {
    recentActivities = [];
    try {
      final client = ApiClient();
      // Use role-aware endpoints
      final auth = Provider.of<AuthNotifier>(context, listen: false);
      final role = auth.user?['role'] as String? ?? 'client';

      if (role == 'admin') {
        // admin: fetch system logs
        final resp = await client.get('/logs');
        if (resp.statusCode == 200 && resp.body.isNotEmpty) {
          final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
          final logs = (parsed['logs'] as List?) ?? [];
          for (final l in logs.take(6)) {
            final user = l['user'] != null ? (l['user']['name'] ?? 'Unknown') : (l['userName'] ?? 'Unknown');
            final createdAt = l['createdAt'] ?? l['created_at'] ?? '';
            recentActivities.add({'action': l['action'] ?? 'Activity', 'detail': user.toString(), 'time': _relativeTime(createdAt)});
          }
        }
      } else {
        // client/other: fetch recent orders (most useful activity)
        final resp = await client.get('/orders', queryParams: {'limit': '6'});
        if (resp.statusCode == 200 && resp.body.isNotEmpty) {
          final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
          final orders = (parsed['orders'] as List?) ?? [];
          for (final o in orders) {
            final id = o['id']?.toString() ?? o['orderNumber']?.toString() ?? 'Order';
            final total = o['totalAmount'] ?? o['total'] ?? '';
            final time = o['createdAt'] ?? o['created_at'] ?? '';
            recentActivities.add({'action': 'Order #$id', 'detail': 'TZS ${total.toString()}', 'time': _relativeTime(time)});
            if (recentActivities.length >= 6) break;
          }

          // also try to fetch recently unlocked lessons for the user
          final lessonsResp = await client.get('/lesson-access/my-lessons');
          if (lessonsResp.statusCode == 200 && lessonsResp.body.isNotEmpty) {
            final lp = jsonDecode(lessonsResp.body) as Map<String, dynamic>;
            final userLessons = (lp['lessons'] as List?) ?? (lp['data'] as Map<String, dynamic>?)?['lessons'] as List? ?? [];
            for (final ls in userLessons.take(3)) {
              final title = ls['title'] ?? ls['name'] ?? 'Lesson';
              recentActivities.insert(0, {'action': 'Lesson Unlocked', 'detail': title.toString(), 'time': _relativeTime(ls['createdAt'] ?? ls['created_at'] ?? '')});
            }
            if (recentActivities.length > 6) recentActivities = recentActivities.sublist(0, 6);
          }
        }
      }
    } catch (e) {
      // ignore network errors for now
    }
    setState(() {});
  }

  String _relativeTime(dynamic value) {
    try {
      if (value == null || value.toString().isEmpty) return '';
      final dt = DateTime.parse(value.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (e) {
      return '';
    }
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
    // Build a BarChart using fl_chart from `summary.revenueByDay` or synthesize
    final List<double> values = [];
    if (summary.containsKey('revenueByDay') && summary['revenueByDay'] is List) {
      for (final v in summary['revenueByDay']) {
        try {
          values.add((v as num).toDouble());
        } catch (_) {
          continue;
        }
      }
    }
    if (values.isEmpty) {
      final total = (summary['totalRevenue'] ?? 0) as num;
      if (total > 0) {
        for (var i = 0; i < 7; i++) {
          values.add(((total / 7) * (0.5 + (i / 14))).toDouble());
        }
      } else {
        for (var i = 0; i < 7; i++) {
          values.add(0.0);
        }
      }
    }

    // Lightweight fallback chart (simple bars) to avoid package compatibility issues.
    final maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1.0;
    return SizedBox(
      height: 120,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(values.length, (i) {
              final v = values[i];
              final height = maxY == 0 ? 0.0 : (v / maxY) * 80;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(height: height, decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 6),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {

    // recentActivities is populated from backend in _loadRecentActivities

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: recentActivities.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text('No recent activity', style: TextStyle(color: Colors.grey[600]))),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentActivities.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final a = recentActivities[i];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(backgroundColor: Colors.grey[100], child: Icon(Icons.history, color: Colors.deepPurple)),
                      title: Text(a['action'] ?? ''),
                      subtitle: Text(a['detail'] ?? ''),
                      trailing: Text(a['time'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

