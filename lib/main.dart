import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'firebase_options.dart';

import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Tu peux appeler des fonctions comme celle-ci ailleurs dans l'appli,
  // mais PAS dans main() si elles retournent du texte
  // Sinon, déplace-les dans une méthode et appelle-les plus tard
  generateGeminiContent();

  runApp(const PlantApp());
}

// Fonction pour générer du contenu Gemini
Future<void> generateGeminiContent() async {
  final model =
      FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash');

  final prompt = [Content.text('Write a story about a magic backpack.')];

  final response = await model.generateContent(prompt);
  print(response.text);
}

class PlantApp extends StatelessWidget {
  const PlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPlant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const WelcomeScreen(),
    );
  }
}
