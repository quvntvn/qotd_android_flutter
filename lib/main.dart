import 'package:flutter/material.dart';
import 'notification_helper.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotifHelper.init(); // init plugin + channel
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext ctx) => MaterialApp(
        title: 'Citation du jour',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        routes: {
          '/': (_) => const HomeScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      );
}
