// FICHIER : models/plant_model.dart
// FICHIER : models/plant_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String name;
  final String dist;
  final bool auto; // Default value, can be changed later
  final String humidity;
  final String temp;
  final String imageUrl;
  final String? deviceId;
  final String userId;
  final bool isOutdoor;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  Plant({
    required this.id,
    required this.name,
    required this.dist,
    this.auto = true, // Default value, can be changed later
    required this.humidity,
    required this.temp,
    String? deviceId,
    required this.imageUrl,
    required this.userId,
    required this.isOutdoor,
    required this.createdAt,
    this.latitude,
    this.longitude,
  }) : deviceId = deviceId;

  factory Plant.fromMap(Map<String, dynamic> data, String documentId) {
    return Plant(
      id: documentId,
      name: data['name'] ?? '',
      dist: data['dist'] ?? '',
      auto: data['auto'] ?? true,
      humidity: data['humidity'] ?? '',
      temp: data['temp'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      deviceId: data['deviceId'] ?? '',
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
      'auto': auto,
      'humidity': humidity,
      'temp': temp,
      'deviceId': deviceId,
      'imageUrl': imageUrl,
      'userId': userId,
      'isOutdoor': isOutdoor,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
    };
  }
}
