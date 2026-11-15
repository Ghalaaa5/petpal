# PetPal – Pet Sitter Matching App

CS 388T project (Scrum, Sprint 1 + Sprint 2). Built with Flutter.

## Features
**Sprint 1:** account registration/login, add/edit/delete pets, search for sitters, filters (pet type, price, rating, location).

**Sprint 2:** sitter profile management (PBI 4), view sitter profile (PBI 6), sitter availability dates (PBI 7), view available dates (PBI 8), booking requests (PBI 13), accept/decline requests (PBI 10), location-radius filter (PBI 17).

## Known limitations (prototype)
- Data and demo accounts are stored **in memory only** (PBI 18 – persistent database – is not implemented yet).
- Radius filtering uses sample distances, not live coordinates.
- Availability is date-based (no time slots).

## Run it
**Option A – DartPad:** open https://dartpad.dev, choose Flutter, paste `lib/main.dart`, press Run.

**Option B – Flutter SDK:**
```bash
flutter create .      # generates android/ios/web folders (keeps lib/main.dart)
flutter pub get
flutter run -d chrome
```
If `flutter create .` adds `test/widget_test.dart`, delete that file.

## Team
Tareem Alosaimi, Ghala Aldawood, Kayan Alshathri, Ghaida Alzahrani (Scrum roles per the Sprint Planning Report).
