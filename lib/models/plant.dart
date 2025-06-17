class Plant {
  final String name;
  final String humidity;
  final String temperature;

  Plant({
    required this.name,
    required this.humidity,
    required this.temperature,
  });

  factory Plant.fromMap(Map<String, String> map) {
    return Plant(
      name: map['name'] ?? '',
      humidity: map['humidity'] ?? '',
      temperature: map['temperature'] ?? '',
    );
  }
}
