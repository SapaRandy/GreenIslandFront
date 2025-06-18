import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String? userId;
  final Timestamp? createdAt;
  final String name;
  final String humidity;
  final String temp;
  final String? room;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final List<Map<String, dynamic>>? careLogs;

  Plant({
    required this.id,
    required this.name,
    required this.humidity,
    required this.temp,
    this.userId,
    this.createdAt,
    this.room,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.careLogs,
  });

  factory Plant.fromMap(String docId, Map<String, dynamic> map) {
    return Plant(
      id: docId,
      userId: map['userId']?.toString(),
      createdAt: map['createdAt'] as Timestamp?,
      name: (map['name'] ?? '').toString().trim(),
      humidity: (map['humidity'] ?? '').toString().trim(),
      temp: (map['temp'] ?? '').toString().trim(),
      room: map['room']?.toString().trim(),
      imageUrl: map['imageUrl']?.toString().trim(),
      latitude: (map['latitude'] != null) ? (map['latitude'] as num).toDouble() : null,
      longitude: (map['longitude'] != null) ? (map['longitude'] as num).toDouble() : null,
      careLogs: map['careLogs'] != null
          ? List<Map<String, dynamic>>.from(map['careLogs'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'humidity': humidity,
      'temp': temp,
      'room': room,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': createdAt,
      'latitude': latitude,
      'longitude': longitude,
      'careLogs': careLogs,
    };
  }
}
