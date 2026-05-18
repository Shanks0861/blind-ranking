# Blind Ranking — Firebase Setup

## 1. Firebase Projekt erstellen
1. https://console.firebase.google.com → Neues Projekt → "blind-ranking"
2. Authentication aktivieren: Email/Passwort + Anonymous
3. Firestore Database erstellen (Production mode)

## 2. FlutterFire konfigurieren
```bash
npm install -g firebase-tools
firebase login

dart pub global activate flutterfire_cli
cd blind_ranking_firebase
flutter pub get
flutterfire configure
```
→ Das erstellt automatisch `lib/firebase_options.dart`

## 3. Firestore Rules deployen
```bash
firebase deploy --only firestore:rules
```

## 4. Daten einspielen (Seed)
```bash
# Im Firebase Console → Project Settings → Service Accounts
# → Generate new private key → als serviceAccountKey.json speichern
# → In den Projektordner legen (blind_ranking_firebase/)

npm install firebase-admin
node seed_firestore.js
```
→ Lädt alle Kategorien + Items (Anime, Fußball, Boxen, Essen, Orte, Sportarten) in Firestore

## 5. App starten
```bash
flutter run -d chrome
```

## 6. Build & Deploy zu Vercel
```bash
flutter build web --release
git add build/web
git commit -m "firebase migration"
git push
```

## Firestore Composite Indexes
Falls Fehler "requires an index" erscheinen:
- Firestore Console → Indexes → Composite Index hinzufügen
- Collection: `items`, Fields: `category_id ASC`, `sub_category_id ASC`, `name ASC`
- Collection: `items`, Fields: ` ASC`, `name ASC`
- Collection: `categories`, Fields: `parent_id ASC`, `name ASC`
- Collection: `game_sessions`, Fields: `lobby_id ASC`, `created_at DESC`
- Collection: `player_rankings`, Fields: `session_id ASC`
- Collection: `votes`, Fields: `session_id ASC`, `voter_id ASC`
- Collection: `lobby_players`, Fields: `lobby_id ASC`

## Dateistruktur
```
lib/
  main.dart                          ← Firebase init + Auth listener
  firebase_options.dart              ← Auto-generiert von flutterfire
  models/
    app_user.dart
    category.dart                    ← Category, SubCategory, GameItem
    lobby.dart                       ← Lobby, LobbyPlayer, GameSession, RankingEntry, PlayerRanking, Vote
  services/
    auth_service.dart                ← Email, Gast, Password Reset
    category_service.dart            ← Kategorien + Items laden
    lobby_service.dart               ← Lobby erstellen/joinen, Realtime
    game_service.dart                ← Session, Rankings, Votes
  screens/
    auth/auth_screen.dart
    lobby/home_screen.dart
    lobby/lobby_screen.dart
    game/game_screen.dart
    final/final_screen.dart
    custom_category/custom_category_screen.dart
  widgets/
    character_image.dart
    item_reveal_dialog.dart
  utils/
    app_theme.dart
seed_firestore.js                    ← Alle Kategorien + Items
firestore.rules                      ← Security Rules
```
