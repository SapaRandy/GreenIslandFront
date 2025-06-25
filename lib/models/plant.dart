// FICHIER : models/plant_model.dart
// FICHIER : models/plant_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String name;
  final String dist;
  final String humidity;
  final String temp;
  final String imageUrl;
  final String userId;
  final bool isOutdoor;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  Plant({
    required this.id,
    required this.name,
    required this.dist,
    required this.humidity,
    required this.temp,
    required this.imageUrl,
    required this.userId,
    required this.isOutdoor,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory Plant.fromMap(Map<String, dynamic> data, String documentId) {
    return Plant(
      id: documentId,
      name: data['name'] ?? '',
      dist: data['dist'] ?? '',
      humidity: data['humidity'] ?? '',
      temp: data['temp'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? '',
      isOutdoor: data['isOutdoor'] ?? false,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dist': dist,
      'humidity': humidity,
      'temp': temp,
      'imageUrl': imageUrl,
      'userId': userId,
      'isOutdoor': isOutdoor,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
    };
  }
}
