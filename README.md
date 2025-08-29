# 📱 app_news

Une application Flutter qui affiche des actualités en temps réel, gère les notifications push, les favoris et permet la lecture complète via une webview.

---

## 🚀 Fonctionnalités

- 📰 Affichage des dernières actualités
- 🔔 Notifications push avec Firebase Cloud Messaging
- 🧠 Sauvegarde locale des notifications avec Hive
- 📍 Affichage des notifications locales avec Flutter Local Notifications
- ⭐ Système de favoris (ajout/suppression)
- 🌐 Lecture d’articles avec WebView intégrée
- 📶 Fonctionnalité hors-ligne partielle grâce à Hive



## 📸 Captures d'écran

| Accueil | Notifications | Favoris |
|--------|----------------|---------|
| ![Accueil](screenshots/home.png) | ![Notifications](screenshots/notifications.png) | ![Favoris](screenshots/favorites.png) |

> Place tes images dans un dossier `screenshots/` à la racine du projet.

---

## 🧑‍💻 Installation

```bash
git clone https://github.com/allatchimi/app_news.git
cd app_news
flutter pub get
flutter run
```



## 🔧 Configuration
Avant de lancer l’application, assure-toi de :

✅ Configuration Firebase
Android : ajoute google-services.json dans android/app/

iOS : ajoute GoogleService-Info.plist dans ios/Runner/

Configure les notifications dans Firebase Cloud Messaging

✅ Configuration Hive
Initialise Hive dans main.dart

Crée les adapters pour tes modèles :

````
flutter packages pub run build_runner build

````
## 🗂️ Structure du projet

```
lib/
├── main.dart
├── models/
│   └── notification_item.dart
├── services/
│   ├── notification_service.dart
│   └── favorite_service.dart
├── pages/
│   ├── home_screen.dart
│   └── notifications_page.dart
├── widgets/
│   ├── news_widget.dart
│   └── app_text.dart
├── utils/
│   ├── app_colors.dart
│   └── helper/
│       ├── date_functions.dart
│       ├── notifier.dart
│       └── author_function.dart

```

## 📦  Dépendances principales

```
dependencies:
  flutter:
  hive:
  hive_flutter:
  firebase_core:
  firebase_messaging:
  flutter_local_notifications:
  path_provider:
  webview_flutter:
  provider:
  webfeed_plus:
  youtube_player_flutter

````

##  🛠️ Fonctionnalité à venir

* 🔍 Recherche d'articles

* 🗂️ Catégorisation des actualités par thème

* 👤 Authentification utilisateur

* 📥 Téléchargement d'articles hors ligne

## ✍️ Auteur

Amine Mahamat Allatchi

📧 Email : [kellanamine@gmail.com]

🌐 GitHub : https://github.com/allatchimi

## 📄 Licence

Ce projet est sous licence MIT.
Vous êtes libre de l'utiliser, le modifier ou le redistribuer avec attribution.

---

