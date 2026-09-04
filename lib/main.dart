import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:go_router/go_router.dart';
import 'src/router.dart';
import 'src/theme/app_theme.dart';
import 'src/providers/auth_notifier.dart';
import 'src/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final authNotifier = AuthNotifier();
  await authNotifier.initialize();

  final settings = SettingsProvider();

  final GoRouter router = createRouter(authNotifier);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: authNotifier),
      ChangeNotifierProvider.value(value: settings),
    ],
    child: MyApp(router: router),
  ));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wateja Mobile',
        theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
