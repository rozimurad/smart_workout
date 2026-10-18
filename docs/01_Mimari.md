---
tags: [mimari, flutter, klasör-yapısı]
created: 2026-06-11
updated: 2026-06-11
type: architecture
related: [ÖZET, 02_Modeller, 03_Servisler, 04_Ekranlar]
---

# Mimari

> Uygulamanın genel yapısı, bileşen ilişkileri ve teknoloji kararları.

---

## Katmanlı Yapı

```
┌─────────────────────────────────────────────┐
│                UI (Screens)                 │  ← lib/screens/
│  Onboarding │ Main │ Workout │ History      │
├─────────────────────────────────────────────┤
│              Services Katmanı               │  ← lib/services/
│  DatabaseService │ WorkoutGeneratorService  │
├─────────────────────────────────────────────┤
│               Data Katmanı                  │  ← lib/data/
│  exercise_data.dart (38 egzersiz kataloğu)  │
├─────────────────────────────────────────────┤
│              Models Katmanı                 │  ← lib/models/
│  UserProfile │ WorkoutProgram │ Exercise    │
├─────────────────────────────────────────────┤
│           Yerel Depolama                    │
│  SQLite — akilli_antreman.db (sqflite)      │
└─────────────────────────────────────────────┘
```

---

## Dosya Yapısı (Tam)

```
smart_workout/
├── lib/
│   ├── main.dart
│   ├── data/
│   │   └── exercise_data.dart         ← 38 egzersiz + buildFilteredSchedule()
│   ├── models/
│   │   ├── user_profile.dart
│   │   ├── workout_program.dart
│   │   └── workout_exercise.dart
│   ├── services/
│   │   ├── database_service.dart      ← SQLite CRUD (users + workout_sessions)
│   │   └── workout_generator_service.dart ← BMI + program adı üretme
│   └── screens/
│       ├── main_screen.dart
│       ├── dashboard_screen.dart
│       ├── profile_screen.dart
│       ├── history_screen.dart
│       ├── workout_schedule_screen.dart
│       ├── workout_session_screen.dart
│       ├── analysis_loading_screen.dart
│       ├── program_result_screen.dart
│       └── onboarding/
│           ├── onboarding_screen.dart
│           └── widgets/
│               ├── nickname_step.dart
│               ├── gender_step.dart
│               ├── physical_step.dart
│               ├── goal_step.dart
│               ├── target_weight_step.dart
│               ├── target_muscles_step.dart
│               ├── level_step.dart
│               ├── workout_days_step.dart
│               └── environment_step.dart
├── assets/
│   ├── animations/
│   │   └── celebration.json           ← Lottie kutlama animasyonu
│   └── exercises/
│       └── man/                       ← 34+ GIF dosyası (yerel)
├── pubspec.yaml
└── analysis_options.yaml
```

---

## State Management

**Yaklaşım:** `setState` — sade StatefulWidget

**Neden Provider/BLoC yok?**
- Uygulama nispeten küçük ve tek kullanıcılı
- Karmaşık cross-screen state paylaşımı yok
- `DatabaseService.savedUserId` static field ile sync erişim yeterli

**State Akışı:**
```
main() → DatabaseService.init()
  → savedUserId var mı?
      ├── Evet → MainScreen (mevcut kullanıcı)
      └── Hayır → OnboardingScreen (yeni kullanıcı)
```

---

## Navigation

**Yaklaşım:** Klasik `Navigator` + route dictionary (GoRouter yok)

```dart
routes: {
  '/': OnboardingScreen,
  '/main': MainScreen,
}
```

**Kullanılan Pattern'ler:**

| Pattern | Kullanım Yeri |
|---------|---------------|
| `push()` | Yeni ekran açmak |
| `pop()` | Geri gitmek |
| `pushAndRemoveUntil()` | Onboarding → MainScreen (stack temizle) |
| `pushReplacementNamed()` | Üst route'u değiştir |

---

## Bağımlılıklar (pubspec.yaml)

```yaml
dependencies:
  flutter: SDK
  cupertino_icons: ^1.0.8      # iOS ikonları
  sqflite: ^2.4.2              # SQLite veritabanı
  path: ^1.9.1                 # DB dosya yolu
  lottie: ^3.3.3               # Kutlama animasyonu (yerel asset)

dev_dependencies:
  flutter_test: SDK
  flutter_lints: ^6.0.0        # Kod kalitesi
```

**Kasıtlı olarak yok:**
- `http` / Firebase (backend yok, tamamen offline)
- `shared_preferences` (SQLite her şeyi karşılıyor)
- Provider / Riverpod / BLoC (setState yeterli)
- GoRouter (basit 2-route yapı)

---

## Platform Desteği

| Platform | Durum |
|----------|-------|
| Android | ✓ Birincil hedef |
| iOS | ✓ |
| Web | — sqflite web desteklemez |
| Windows / Linux / macOS | — sqflite masaüstü için ek setup gerektirir |

---

## Bağlantılar

- [[02_Modeller]] — veri sınıfları detayı
- [[03_Servisler]] — servis katmanı detayı
- [[04_Ekranlar]] — tüm ekranlar
- [[06_Veritabanı]] — SQLite şema
- [[09_Veri_Akışı]] — uçtan uca akış
