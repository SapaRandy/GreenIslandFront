import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  final String apiKey = '02c1ab64a9881461632e258fc96c6691';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = position.latitude;
      final lon = position.longitude;

      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&lang=fr&appid=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Erreur météo : ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Erreur localisation ou API : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Colors.green, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : weatherData == null
                  ? const Text("Impossible de récupérer la météo.")
                  : _buildWeatherCard(),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    final main = weatherData!['main'];
    final weather = weatherData!['weather'][0];
    final wind = weatherData!['wind'];
    final city = weatherData!['name'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 3,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            city,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            weather['description'].toString().toUpperCase(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoBox("🌡️ Temp", "${main['temp']}°C"),
              _infoBox("💧 Humidité", "${main['humidity']}%"),
              _infoBox("🌬️ Vent", "${wind['speed']} m/s"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            )),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
