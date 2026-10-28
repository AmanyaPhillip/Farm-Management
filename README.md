# FarMan
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-Apache--2.0-blue)
 
A cross-platform Flutter app for managing livestock on a farm. Register and track
cattle records — including vaccination, tick-dipping, milk-yield, and lineage
history — with everything stored locally on-device. Import or export your data as
JSON whenever you need it. No internet connection required.
 
---
 
## Screenshots
 

 
---
 
## Features
 
- **Cattle registration** — add animals with an auto-generated ID (`CW####`), name,
  breed, farm, and alive/deceased status.
- **Per-cow health & production records** — each cow tracks vaccination history,
  tick-dipping history, milk-yield entries, and a family-tree/lineage record
  (parents and offspring).
- **Search & filter** — find cattle on the home screen by name, ID, breed, or farm.
- **Role-based access** — two seeded roles: an **admin** (role 1) who can add cattle
  and a **regular user** (role 2) with read access. Login gates entry to the dashboard.
- **Import & export** — export all inventory to a timestamped JSON file in a
  `Farm_export/` folder; import from any JSON file (this **replaces** existing data).
- **Local-first storage** — all records kept in on-device SQLite databases; works
  fully offline.
- **Cross-platform** — single codebase targets Android, iOS, Windows and the web With Installable releases(except iOS).
 
---
 
## Tech Stack
 
| Area | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev/) / Dart |
| Local database | [`sqflite`](https://pub.dev/packages/sqflite) |
| File handling | `file_picker`, `path`, `path_provider`, `dart:io` |
| Device & permissions | `permission_handler`, `device_info_plus` |
 
---
 
## Getting Started
### Installation:
Get the Latest release for your device: [Download](https://github.com/Mahir29Flame/FarMan/releases/tag/v1.1.0)

### Build a Release
 
```bash
flutter build apk          # Android — output: build/app/outputs/flutter-apk/
flutter build web          # Web — output: build/web/
flutter build ios          # iOS — requires a macOS machine with Xcode
```
 
---
 
## Data Model
 
The app uses on-device SQLite databases.
 
**`inventory_database.db`** (schema version 7)
 
| Table | Purpose |
|---|---|
| `inventory` | Core cattle records: `cow_id`, `alive`, `cow_name`, `farm`, `breed`. |
| `vacTable` | Vaccination records per cow (date, status). |
| `dipTable` | Tick-dipping records per cow (date, status). |
| `milkTable` | Milk-yield records per cow (date, liters). |
| `FamilyTreeTable` | Lineage: parents and offspring (kids stored as JSON). |
 
---
 
## Project Structure [NOT Up-to-date]
 
```
lib/
├─ main.dart                          # App entry point — launches LoginPage
├─ auth/
│  └─ LoginPage.dart                  # Login screen; verifies credentials, passes role
├─ api/
│  └─ Database_helper.dart            # SQLite layer: DatabaseHelper (users)
│                                     #   + InventoryDatabaseHelper (cattle, vac, dip, milk, family tree)
├─ models/
│  └─ cow_model.dart                  # Cow model — toMap()/fromMap()/copyWith()/equality
└─ pages/
   ├─ home/
   │  └─ Homescreen.dart              # Dashboard: searchable cattle list, bottom nav
   ├─ add_cow/
   │  └─ AddCowPage.dart              # Add-cow form (admin only); auto-generates CW#### ID
   ├─ cow_details/
   │  └─ CowDetailsPage.dart          # Per-cow detail view (health/milk/lineage)
   └─ import_export/
      └─ ImportExportPage.dart        # JSON import/export with storage permissions
```
 
---
 
## Known Limitations (pre-1.0)
 
- No Auth.
- The "Money" tab on the home screen is a placeholder ("coming soon").
- Import **overwrites** all existing inventory without a confirmation/merge step.
- Family-Tree connection does not work
---
