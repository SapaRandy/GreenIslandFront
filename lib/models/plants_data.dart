class PlantData {
  final String name;
  final Map<String, String> details;

  PlantData({required this.name, required this.details});

  // Permet de créer un PlantData depuis un Map (utile si on récupère des données JSON/Firestore)
  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      name: json['name'] ?? '',
      details: Map<String, String>.from(json['details'] ?? {}),
    );
  }

  // Permet de transformer un PlantData en Map (utile si on veut l’envoyer dans Firestore)
  Map<String, dynamic> toJson() {
    return {'name': name, 'details': details};
  }
}
