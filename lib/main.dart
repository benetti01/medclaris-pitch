import 'package:flutter/material.dart';
import 'telas/home.dart';

void main() {
  runApp(const MedClaris());
}

class MedClaris extends StatelessWidget {
  const MedClaris({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'MedClaris',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F7BC4),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F7BC4),
          foregroundColor: Colors.white,
        ),
      ),

      home: const Home(),
    );
  }
}