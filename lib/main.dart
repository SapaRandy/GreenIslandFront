import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartplant_app/screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'package:smartplant_app/screens/reset_password_screen.dart';
// Make sure the class name in the import matches the actual class name in the file.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SmartPlantApp());
}

class SmartPlantApp extends StatelessWidget {
  const SmartPlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Plant',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        // If the class is named differently (e.g., ResetPassword), update it accordingly:
        // '/reset-password': (context) => const ResetPassword(),
        // Make sure to use the correct class name as defined in reset_password_screen.dart
        '/reset-password': (context) => const ResetPasswordScreen(),

      },
    );
  }
} 
