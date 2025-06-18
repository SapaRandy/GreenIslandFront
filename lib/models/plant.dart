class Plant {
  final String id;
  final String name;
  final String humidity;
  final String temp;
  final String? room;
  final String? imageUrl;

  Plant({
    required this.id,
    required this.name,
    required this.humidity,
    required this.temp,
    this.room,
    this.imageUrl,
  });

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      humidity: map['humidity'] ?? '',
      temp: map['temp'] ?? '',
      room: map['room'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'humidity': humidity,
      'temp': temp,
      'room': room,
      'imageUrl': imageUrl,
    };
  }
}
// This class represents a plant with its properties and methods to convert to/from a map.
