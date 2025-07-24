**README.md complet et professionnel** pour la partie Front du projet **GreenIsland** :

# 🌱 GreenIsland – Frontend Flutter App

GreenIsland est une application mobile multiplateforme développée avec **Flutter**, dédiée à l'entretien intelligent des plantes grâce à un système d’arrosage connecté, des capteurs IoT, une IA de reconnaissance des plantes, et des services météo personnalisés.

## 📱 Objectif de l’application

Permettre à tout utilisateur d’arroser ses plantes à distance, suivre leur état en temps réel (humidité, température, niveau d’eau, etc.), et recevoir des conseils personnalisés grâce à la reconnaissance automatique des espèces végétales. Un bot IA, d'assistance météo également y est intégré.

## 🚀 Fonctionnalités principales

| Fonctionnalité | Description |
|----------------|-------------|
| 🔐 Authentification | Connexion, inscription, récupération de mot de passe via Firebase Auth |
| 🌿 Gestion des plantes | Ajout manuel ou par reconnaissance d’image (IA), affichage des infos de chaque plante |
| 💧 Arrosage connecté | Activation automatique ou manuelle de l’arrosage via un device connecté |
| 🌡 Suivi des capteurs | Visualisation en temps réel de l’humidité, de la température et du niveau d’eau |
| 📍 Localisation & météo | Intégration météo basée sur la localisation de l’appareil |
| 📊 Fonction de recherche de plantes |
| ⚙️ Profil utilisateur | Modification des infos personnelles, appairage/dissociation d’un device |

## 🧱 Architecture du code (résumé)

lib/
├── models/           # Modèles de données (Plant, User, Device, etc.)
├── screens/          # Écrans principaux (Home, Login, Register, PlantDetails...)
├── widgets/          # Composants réutilisables (PlantCard, SensorChart...)
├── services/         # Firebase, Auth, API Calls
├── utils/            # Constantes, Helpers, Thèmes
main.dart             # Point d'entrée de l'app

## ⚙️ Technologies utilisées

- **Flutter 3.19+** (Dart)
- **Firebase Authentication** (gestion des utilisateurs)
- **Cloud Firestore** (stockage des données plantes, capteurs, users, devices)
- **Firebase Storage** (upload des images)
- **API externe** :
  - Reconnaissance d’image (IA)
  - Météo
  - Scraping infos botaniques

## 🛠 Installation & Lancement local

# Clonez le repo
git clone https://github.com/SapaRandy/GreenIslandFront.git
cd GreenIslandFront

# Installez les dépendances
flutter pub get

# Lancez l'application
flutter run
````

### ✅ Pré-requis

* Flutter SDK installé
* Un émulateur ou un device Android/iOS connecté
* Avoir configuré vos variables Firebase (`google-services.json` / `GoogleService-Info.plist`)

## 🔐 Variables d’environnement requises

Certaines parties de l'app nécessitent la configuration de Firebase et des APIs personnalisées (PlantID, météo).
Pour cela, créer un fichier `.env` ou utiliser Firebase CLI selon les règles du projet.
À inclure :

* Clés API pour IA et météo
* URL backend (ex. : `https://greenislandback.onrender.com/...`)

## 🔄 Communication avec le backend

Les appels réseau incluent :

* `POST /plantid/identify`: Reconnaissance de plante via image
* `GET /plantid/infos`: Récupération des infos botaniques
* `GET /weather`: Récupération des données météo
* `POST /plantid/connect`: Appairage d’un device à une plante

## 📅 Historique des sprints / stories livrées

| Sprint   | Fonctionnalité livrée                           |
| -------- | ----------------------------------------------- |
| Sprint 1 | Authentification Firebase, base UI              |
| Sprint 2 | Ajout / gestion des plantes, affichage capteurs |
| Sprint 3 | Appairage devices, historique d’arrosage        |
| Sprint 4 | Intégration API IA + météo, finalisation UI/UX  |

## 🧪 Tests

Les tests ont été réalisés de façon manuelle (UI), avec validation par critères d’acceptation.
Des tests unitaires peuvent être ajoutés sur les services et widgets critiques à l’aide de `flutter_test`.

## 📈 Perspectives d’évolution

* Ajout de notifications push (arrosage requis, météo extrême)
* Intégration de plus de capteurs (lumière, pH)
* Suivi de croissance de la plante avec photos
* Tableau de bord web complémentaire

## 🤝 Auteurs & Crédits

Projet réalisé dans le cadre du cursus MASTER 1 IOT – H3 HITEMA (2024/2025)

* [Randy SAPA](https://github.com/SapaRandy/GreenIslandBack.git) – Backend & API
* [Fred Lucien Ablefonlin](https://github.com/) – Frontend Flutter
* [Anthony Selin](https://github.com/SapaRandy/GreenIslandArduino.git) – Arduino & Intégration

## 📄 Licence

Ce projet est réalisé à des fins académiques. Tous droits réservés.
Licence à définir selon le besoin (MIT, GPL, etc.).