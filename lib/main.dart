import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/services.dart';
import 'screens/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(TruthLens(store: LocalStore(prefs)));
}

class TruthLens extends StatelessWidget {
  final LocalStore store;
  const TruthLens({super.key, required this.store});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TruthLens',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFEEF4F8),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0B2545),
        primary: const Color(0xFF0B2545),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 17, height: 1.5),
        bodyLarge: TextStyle(fontSize: 18, height: 1.5),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFEEF4F8),
        foregroundColor: Color(0xFF0B2545),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 58),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 56),
          textStyle: const TextStyle(fontSize: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 17),
          minimumSize: const Size(48, 48),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    ),
    home: App(store: store),
  );
}
