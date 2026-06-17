# Farm Management

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)

A cross-platform Flutter app for managing livestock on a farm. Register and track cattle records, keep everything stored locally on-device, and import or export your data whenever you need it — no internet connection required.

---

## Screenshots

> _Coming in v1.0.0 — Android, iOS, and Web builds._

---

## Features

- **Cattle registration** — add animals with name, breed, farm, and alive/deceased status
- **Local-first storage** — all records kept in an on-device SQLite database; works fully offline
- **Import & export** — move data in and out using the device file picker and file saver
- **Login screen** — simple auth entry point before accessing the management dashboard
- **Cross-platform** — single codebase runs on Android, iOS, and the web

---

## Tech Stack

| Area | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev/) / Dart |
| Local database | [`sqflite`](https://pub.dev/packages/sqflite) |
| File handling | `file_picker`, `file_saver`, `path`, `path_provider` |
| Device & permissions | `permission_handler`, `device_info_plus` |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and on your `PATH`
- One of: an Android/iOS device or emulator, or Chrome (for web)

Check your setup:

```bash
flutter doctor
```

### Run

```bash
flutter pub get
flutter run
```

### Build a Release

```bash
flutter build apk          # Android — output: build/app/outputs/flutter-apk/
flutter build web          # Web — output: build/web/
flutter build ios          # iOS — requires a macOS machine with Xcode
```

---

## Project Structure

```
lib/
├─ main.dart                  # App entry point — initialises the Cow Management System
├─ auth/
│  └─ LoginPage.dart          # Login screen shown before the dashboard
├─ api/
│  └─ Database_helper.dart    # SQLite data access layer (CRUD for cattle records)
└─ models/
   └─ cow_model.dart          # Cow data model — toMap() / fromMap() serialisation
```

---

## Roadmap

Planned releases and upcoming features.

| Version | Theme | Target |
|---|---|---|
| v1.0.0 | Security, Architecture, and Code Quality.| Jul 14, 2026 |
| v1.1.0 | Search, filter, UX polish | Sep 8, 2026 |
| v1.2.0 | Health log, weight tracking, vet records | Nov 3, 2026 |

---

## License

[Apache-2.0](LICENSE)
