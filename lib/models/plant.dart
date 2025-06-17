class Plant {
  final String name;
  final String imageUrl;
  final String description;

  Plant({
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  factory Plant.fromMap(Map<String, String> map) {
    return Plant(
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}
