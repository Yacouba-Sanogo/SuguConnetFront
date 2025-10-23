# SuguConnect Mobile

Application mobile Flutter pour la plateforme SuguConnect - Marché local connecté entre producteurs et consommateurs.

## 🚀 Fonctionnalités

### Authentification
- ✅ Connexion/Inscription pour tous les types d'utilisateurs
- ✅ Gestion des rôles (Consommateur, Producteur, Admin)
- ✅ Authentification JWT sécurisée

### Interface Utilisateur
- ✅ Écrans d'authentification (Login/Register)
- ✅ Interface consommateur avec navigation
- ✅ Interface producteur avec dashboard
- ✅ Interface administrateur
- ✅ Écran de profil utilisateur

### Architecture
- ✅ Modèles de données complets
- ✅ Services API pour communication avec le backend
- ✅ Gestion d'état avec Provider
- ✅ Navigation et routage

## 📱 Types d'utilisateurs

### Consommateur
- Parcourir le catalogue de produits
- Ajouter des produits au panier
- Passer des commandes
- Gérer les favoris
- Consulter l'historique des commandes

### Producteur
- Gérer son catalogue de produits
- Suivre les commandes
- Gérer les livraisons
- Consulter les évaluations

### Administrateur
- Gérer tous les utilisateurs
- Superviser les commandes
- Gérer les catégories
- Tableau de bord complet

## 🛠️ Installation et Configuration

### Prérequis
- Flutter SDK (version 3.2.0 ou supérieure)
- Dart SDK
- Android Studio / VS Code
- Backend SuguConnect en cours d'exécution

### Installation
```bash
# Cloner le projet
git clone <repository-url>
cd suguconnect_mobile

# Installer les dépendances
flutter pub get

# Générer les fichiers de sérialisation JSON
flutter packages pub run build_runner build

# Lancer l'application
flutter run
```

### Configuration
1. Assurez-vous que le backend Spring Boot est en cours d'exécution sur `http://localhost:8080`
2. Configurez l'URL de base dans `lib/services/api_service.dart` si nécessaire
3. Lancez l'application sur un émulateur ou un appareil physique

## 📁 Structure du projet

```
lib/
├── models/           # Modèles de données
│   ├── user.dart
│   ├── auth.dart
│   ├── product.dart
│   ├── order.dart
│   ├── notification.dart
│   └── api_response.dart
├── services/         # Services API
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── order_service.dart
│   ├── notification_service.dart
│   └── user_service.dart
├── providers/        # Gestion d'état
│   └── auth_provider.dart
├── screens/          # Écrans de l'application
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── consumer/
│   │   └── consumer_home_screen.dart
│   ├── producer/
│   │   └── producer_dashboard_screen.dart
│   ├── admin/
│   │   └── admin_dashboard_screen.dart
│   ├── home_screen.dart
│   └── profile_screen.dart
├── widgets/          # Widgets réutilisables
├── theme/           # Thème de l'application
└── main.dart        # Point d'entrée
```

## 🔧 Développement

### Ajout de nouvelles fonctionnalités
1. Créez les modèles de données dans `lib/models/`
2. Implémentez les services API dans `lib/services/`
3. Créez les écrans dans `lib/screens/`
4. Ajoutez la navigation dans `main.dart`

### Gestion d'état
Le projet utilise Provider pour la gestion d'état :
- `AuthProvider` : Gestion de l'authentification
- Ajoutez d'autres providers selon les besoins

### Services API
Tous les services API sont centralisés dans `lib/services/` :
- `ApiService` : Service de base pour les requêtes HTTP
- Services spécialisés pour chaque entité

## 🧪 Tests

```bash
# Lancer les tests
flutter test

# Lancer les tests d'intégration
flutter drive --target=test_driver/app.dart
```

## 📦 Build et Déploiement

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

## 🔗 Intégration Backend

L'application communique avec le backend Spring Boot via des API REST :

### Endpoints principaux
- `POST /api/auth/login` - Connexion
- `POST /api/auth/register/*` - Inscription
- `GET /api/produits` - Liste des produits
- `GET /api/commandes` - Commandes
- `GET /api/notifications` - Notifications

### Configuration
Modifiez l'URL de base dans `lib/services/api_service.dart` :
```dart
static const String baseUrl = 'http://localhost:8080/api';
```

## 🚧 Fonctionnalités à venir

- [ ] Catalogue de produits interactif
- [ ] Panier et commandes
- [ ] Système de notifications push
- [ ] Géolocalisation
- [ ] Paiements intégrés
- [ ] Chat en temps réel
- [ ] Évaluations et avis

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## 🤝 Contribution

1. Fork le projet
2. Créez une branche pour votre fonctionnalité
3. Committez vos changements
4. Poussez vers la branche
5. Ouvrez une Pull Request

## 📞 Support

Pour toute question ou problème, contactez l'équipe de développement.