---
tags: [mimari, flutter, klasör-yapısı]
created: 2026-06-11
type: architecture
related: [ÖZET, 02_Modeller, 03_Servisler, 04_Ekranlar]
---

# Mimari

> Uygulamanın genel yapısı, bileşen ilişkileri ve teknoloji kararları.

---

## Katmanlı Yapı

```
┌─────────────────────────────────────────┐
│              UI (Screens)               │  ← lib/screens/
│  Onboarding │ Main │ Workout │ History  │
├─────────────────────────────────────────┤
│             Services Katmanı            │  ← lib/services/
│  LocalStorageService │ WorkoutGenerator │
├─────────────────────────────────────────┤
│              Models Katmanı             │  ← lib/models/
│  UserProfile │ WorkoutProgram │ Exercise │
├─────────────────────────────────────────┤
│         Dış Bağımlılıklar               │
│  SharedPreferences │ PHP REST API       │
└─────────────────────────────────────────┘
```

---

## Dosya Yapısı (Tam)

```
smart_workout/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── user_profile.dart
│   │   ├── workout_program.dart
│   │   └── workout_exercise.dart
│   ├── services/
│   │   ├── local_storage_service.dart
│   │   └── workout_generator_service.dart
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
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
├── pubspec.yaml
├── pubspec.lock
└── analysis_options.yaml
```

---

## State Management

**Yaklaşım:** `setState` — sade StatefulWidget

**Neden Provider/BLoC yok?**
- Uygulama nispeten küçük
- Karmaşık cross-screen state paylaşımı yok
- Kullanıcı profili uygulama başlangıcında bir kez yükleniyor
- API verisi her ekranda kendi initState'inde çekiliyor

**State Akışı:**
```
main() → LocalStorageService.init()
  → user_id var mı?
      ├── Evet → MainScreen (bottom nav)
      └── Hayır → OnboardingScreen
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
  http: ^1.2.1                  # REST API istekleri
  shared_preferences: ^2.5.5   # Local kalıcı depolama
  lottie: ^3.3.3               # Kutlama animasyonları

dev_dependencies:
  flutter_test: SDK
  flutter_lints: ^6.0.0        # Kod kalitesi
```

**Kasıtlı olarak yok:**
- Firebase (custom PHP backend var)
- SQLite / Hive (SharedPreferences yeterli)
- Provider / Riverpod / BLoC (setState yeterli)
- GoRouter (basit routing)

---

## Platform Desteği

Proje tüm Flutter platformlarını destekliyor:
- Android ✓
- iOS ✓
- Web ✓
- Windows ✓
- Linux ✓
- macOS ✓

---

## Bağlantılar

- [[02_Modeller]] — veri sınıfları detayı
- [[03_Servisler]] — servis katmanı detayı
- [[04_Ekranlar]] — tüm ekranlar
- [[06_API]] — backend iletişimi
- [[09_Veri_Akışı]] — uçtan uca akış
