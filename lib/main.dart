import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  // Make sure Flutter's bindings are ready before we do async work
  // (loading the .env file) prior to runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Load API configuration (base URL, API key) from the local .env
  // file before the app starts, so ApiService can use it right away.
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GirlStadium',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}