class PlantData {
  final String name;
  final Map<String, String> details;

  const PlantData({
    required this.name,
    required this.details,
  });
}

final List<PlantData> plantsData = [
  PlantData(
    name: 'hibiscus',
    details: {
      'Cycle': 'Plante vivace',
      'Enracinement': 'Système racinaire',
      'Exposition': 'Soleil (mi-ombre dans le sud)',
      'Famille': 'Malvacées – Malvaceae',
      'Feuillage': 'Persistant',
      'Floraison': 'Juin à septembre',
      'Origine': 'Asie tropicale / Chine',
      'Plantation': 'Printemps',
      'Port': 'Arbuste très florifère (de 1 à 3 mètres)',
      'Rusticité': 'Plante non-rustique / faible résistance au froid (-3/-5°C)',
      'Zone de Culture': '9b à 12 (voir carte de rusticité en France 9b à 10)',
    },
  ),
  // 🔁 Tu pourras ajouter ici d’autres entrées similaires si besoin
];