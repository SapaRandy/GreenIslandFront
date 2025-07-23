import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LastMeasureText extends StatelessWidget {
  final String plantId;

  const LastMeasureText({super.key, required this.plantId});

  Future<Map<String, dynamic>?> fetchLastMeasure() async {
    final url = Uri.parse(
        'https://greenislandback.onrender.com/plantid/mesures/$plantId/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print("Erreur backend: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erreur réseau: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchLastMeasure(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Chargement des mesures...");
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text("Aucune mesure disponible");
        }

        final data = snapshot.data!;
        final temp = (data['temperature'] is num)
            ? (data['temperature'] as num).toStringAsFixed(1)
            : 'N/A';
        final eau = (data['niveau_eau'] is num)
            ? (data['niveau_eau'] as num).toStringAsFixed(1)
            : 'N/A';
        final hum = (data['humidite'] is num)
            ? (data['humidite'] as num).toStringAsFixed(1)
            : 'N/A';

        return Text("💧 Eau : $eau cm • 🌡️ Temp : $temp °C • 💦 Hum : $hum%");
      },
    );
  }
}
