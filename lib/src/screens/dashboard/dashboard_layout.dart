import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_notifier.dart';

class DashboardLayout extends StatelessWidget {
  final Widget? child;
  const DashboardLayout({super.key, this.child});

  static final List<_NavItem> _navItems = [
    _NavItem(label: 'Home', path: '/dashboard/home', icon: Icons.home),
    _NavItem(label: 'Market', path: '/dashboard/selling', icon: Icons.storefront),
    _NavItem(label: 'Consultation', path: '/dashboard/consultation', icon: Icons.support_agent),
    _NavItem(label: 'Lessons', path: '/dashboard/lessons', icon: Icons.book),
    _NavItem(label: 'Cart Items', path: '/dashboard/cart', icon: Icons.shopping_cart),
    _NavItem(label: 'Orders', path: '/dashboard/orders', icon: Icons.receipt_long),
    _NavItem(label: 'My Products', path: '/dashboard/my-products', icon: Icons.inventory_2),
    _NavItem(label: 'Messages', path: '/dashboard/messages', icon: Icons.message),
    _NavItem(label: 'Reports', path: '/dashboard/reports', icon: Icons.show_chart),
    _NavItem(label: 'Settings', path: '/dashboard/settings', icon: Icons.settings),
  ];

  void _go(BuildContext context, String path) {
    try {
      final loc = (GoRouter.of(context) as dynamic).location as String?;
      if (loc != path) context.go(path);
    } catch (_) {
      context.go(path);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthNotifier>();
    await auth.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool showRail = width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wateja'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () => _go(context, '/dashboard/notifications'), icon: const Icon(Icons.notifications)),
          IconButton(onPressed: () => _logout(context), icon: const Icon(Icons.logout)),
        ],
      ),
      drawer: showRail ? null : Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: const [Text('Wateja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Mobile app')])),
          ..._navItems.map((n) => ListTile(leading: Icon(n.icon), title: Text(n.label), onTap: () { Navigator.pop(context); _go(context, n.path); })),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () async {
            Navigator.pop(context);
            await _logout(context);
          }),
        ]),
      ),
      body: Row(children: [
        if (showRail)
          NavigationRail(
            selectedIndex: _selectedIndex(context),
            onDestinationSelected: (idx) => _go(context, _navItems[idx].path),
            labelType: NavigationRailLabelType.all,
            destinations: _navItems.map((n) => NavigationRailDestination(icon: Icon(n.icon), label: Text(n.label))).toList(),
          ),
        Expanded(child: child ?? const Center(child: Text('Select a page from the menu'))),
      ]),
    );
  }

  int _selectedIndex(BuildContext context) {
    String loc = '/dashboard/home';
    try {
      loc = (GoRouter.of(context) as dynamic).location as String? ?? loc;
    } catch (_) {}
    final idx = _navItems.indexWhere((n) => loc.startsWith(n.path));
    return idx >= 0 ? idx : 0;
  }
}

class _NavItem {
  final String label;
  final String path;
  final IconData icon;
  const _NavItem({required this.label, required this.path, required this.icon});
}
