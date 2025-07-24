import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  final String apiKey = '02c1ab64a9881461632e258fc96c6691';

  final TextEditingController _botController = TextEditingController();
  String botResponse = "";

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final lat = position.latitude;
      final lon = position.longitude;

      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&lang=fr&appid=$apiKey');

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
      print("Erreur : $e");
    }
  }

  void _handleBotQuery(String query) {
    if (weatherData == null) return;

    final lower = query.toLowerCase();
    final main = weatherData!['main'];
    final sys = weatherData!['sys'];
    final weather = weatherData!['weather'][0];

    String formatTime(int timestamp) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return DateFormat.Hm().format(date);
    }

    String answer = "Je n’ai pas compris la question 🤔";

    if (lower.contains("temp") || lower.contains("degr")) {
      answer = "Il fait actuellement ${main['temp']}°C.";
    } else if (lower.contains("pluie")) {
      answer = weather['description'].toString().contains("pluie")
          ? "Oui, il y a de la pluie prévue."
          : "Non, pas de pluie prévue pour l’instant.";
    } else if (lower.contains("soleil") && lower.contains("lever")) {
      answer = "Le soleil se lève à ${formatTime(sys['sunrise'])}.";
    } else if (lower.contains("soleil") && lower.contains("coucher")) {
      answer = "Le soleil se couche à ${formatTime(sys['sunset'])}.";
    } else if (lower.contains("humidité")) {
      answer = "L’humidité actuelle est de ${main['humidity']}%.";
    }

    setState(() {
      botResponse = answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Colors.green, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Météo locale"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : weatherData == null
                ? const Center(child: Text("Données météo non disponibles."))
                : _buildDashboard(),
      ),
    );
  }

  Widget _buildDashboard() {
    final main = weatherData!['main'];
    final wind = weatherData!['wind'];
    final weather = weatherData!['weather'][0];
    final clouds = weatherData!['clouds'];
    final sys = weatherData!['sys'];
    final visibility = weatherData!['visibility'];
    final city = weatherData!['name'];

    final iconUrl =
        "https://openweathermap.org/img/wn/${weather['icon']}@2x.png";

    String formatTime(int timestamp) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return DateFormat.Hm().format(date);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(city,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(height: 10),
                  Image.network(iconUrl, width: 80),
                  Text(
                    weather['description'].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    "🌡️ ${main['temp']} °C (ressenti : ${main['feels_like']} °C)",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _infoCard("📉 Min", "${main['temp_min']}°C"),
              _infoCard("📈 Max", "${main['temp_max']}°C"),
              _infoCard("💧 Humidité", "${main['humidity']}%"),
              _infoCard("🧭 Pression", "${main['pressure']} hPa"),
              _infoCard("🌬️ Vent", "${wind['speed']} m/s"),
              _infoCard("🎯 Direction", "${wind['deg']}°"),
              _infoCard("☁️ Nuages", "${clouds['all']}%"),
              _infoCard("👁️ Visibilité", "${visibility / 1000} km"),
              _infoCard("🌅 Lever", formatTime(sys['sunrise'])),
              _infoCard("🌇 Coucher", formatTime(sys['sunset'])),
            ],
          ),
          const SizedBox(height: 30),

          const Text("💬 Pose une question météo :",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _botController,
            onSubmitted: (value) {
              _handleBotQuery(value);
              _botController.clear();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Ex : Est-ce qu’il va pleuvoir ?",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _handleBotQuery(_botController.text);
                  _botController.clear();
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (botResponse.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text("🤖 $botResponse"),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
