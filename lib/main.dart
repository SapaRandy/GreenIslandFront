import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // Nouvelle page d'accueil

void main() => runApp(const PlantApp());

class PlantApp extends StatelessWidget {
  const PlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPlant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const WelcomeScreen(), // Nouvelle entrée
    );
  }
}
