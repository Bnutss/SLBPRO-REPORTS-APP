import 'package:flutter/material.dart';
import 'menu_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Отчеты',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      home: const MenuPage(),
    );
  }
}
