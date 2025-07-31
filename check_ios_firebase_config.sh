#!/bin/bash

echo "✅ Vérification de la configuration Firebase iOS pour Flutter..."

PLIST_FILE="ios/Runner/Info.plist"
APPDELEGATE_FILE="ios/Runner/AppDelegate.swift"
WORKSPACE_FILE="ios/Runner.xcworkspace"
GOOGLE_SERVICE="ios/Runner/GoogleService-Info.plist"

# Vérifie le fichier GoogleService-Info.plist
if [[ -f "$GOOGLE_SERVICE" ]]; then
  echo "✔️  GoogleService-Info.plist trouvé ✅"
else
  echo "❌ GoogleService-Info.plist manquant ❗"
fi

# Vérifie que FirebaseApp.configure() est présent
if grep -q "FirebaseApp.configure()" "$APPDELEGATE_FILE"; then
  echo "✔️  FirebaseApp.configure() détecté dans AppDelegate.swift ✅"
else
  echo "❌ FirebaseApp.configure() est manquant ❗"
fi

# Vérifie le delegate des notifications
if grep -q "UNUserNotificationCenter.current().delegate = self" "$APPDELEGATE_FILE"; then
  echo "✔️  UNUserNotificationCenter.delegate est bien configuré ✅"
else
  echo "❌ UNUserNotificationCenter.delegate non configuré ❗"
fi

# Vérifie apnsToken
if grep -q "Messaging.messaging().apnsToken" "$APPDELEGATE_FILE"; then
  echo "✔️  apnsToken configuré ✅"
else
  echo "❌ apnsToken non configuré dans AppDelegate ❗"
fi

# Vérifie les clés Info.plist
if grep -q "<key>FirebaseAppDelegateProxyEnabled</key>" "$PLIST_FILE"; then
  echo "✔️  Clé FirebaseAppDelegateProxyEnabled trouvée dans Info.plist ✅"
else
  echo "❌ Clé FirebaseAppDelegateProxyEnabled manquante ❗"
fi

if grep -q "<key>UIBackgroundModes</key>" "$PLIST_FILE"; then
  echo "✔️  UIBackgroundModes configuré ✅"
else
  echo "❌ UIBackgroundModes manquant ❗"
fi

# Vérifie que le workspace Xcode existe
if [[ -d "$WORKSPACE_FILE" ]]; then
  echo "✔️  Fichier Runner.xcworkspace détecté ✅"
else
  echo "❌ Fichier Runner.xcworkspace manquant ❗ (Ouvre ios/ dans Xcode au moins une fois)"
fi

echo "🔍 Vérification terminée."
