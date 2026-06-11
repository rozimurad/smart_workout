---
tags: [servisler, shared-preferences, bmi, program-generation]
created: 2026-06-11
type: services
related: [01_Mimari, 02_Modeller, 06_API, 07_İş_Mantığı]
---

# Servisler

> `lib/services/` altındaki 2 servis sınıfı. Tüm business logic ve storage burada.

---

## LocalStorageService

**Dosya:** `lib/services/local_storage_service.dart`  
**Tip:** Static class, SharedPreferences wrapper  
**Amaç:** Kullanıcı verisini cihazda cache'lemek, API çağrısı olmadan hızlı erişim

### Başlatma

```dart
// main.dart içinde:
await LocalStorageService.init();
// SharedPreferences instance'ı yükler, sync erişim için hazır hale getirir
```

### Metodlar

```dart
static Future<void> init()
// Uygulama başlangıcında çağrılır. SP instance'ını hazırlar.

static Future<bool> saveUserId(dynamic userId)
// Onboarding sonrası API'den gelen user_id'yi kaydeder

static dynamic getSavedUserId()
// user_id'yi senkron okur (await gerekmez)
// null ise → kullanıcı onboarding yapmamış

static Future<bool> saveUserProfile(UserProfile profile)
// Tüm UserProfile alanlarını SP'ye yazar (JSON değil, field field)

static UserProfile? getSavedProfile()
// SP'den UserProfile reconstruct eder

static Future<bool> saveWorkoutProgram(WorkoutProgram program)
// WorkoutProgram'ı cache'ler

static WorkoutProgram? getSavedProgram()
// Cache'teki programı okur

static bool isProfileSaved()
// Hızlı kontrol: profil kaydedilmiş mi?

static Future<void> clearAll()
// Tüm SP verisini siler → Logout işlevi
```

### Cache'lenen Anahtarlar

```
user_id, nickname, gender, age, height, weight,
goal, level, environment, target_muscles (JSON string),
target_weight, program_adi, program_aciklama,
program_gun_sayisi, program_kategori
```

---

## WorkoutGeneratorService

**Dosya:** `lib/services/workout_generator_service.dart`  
**Tip:** Static utility class  
**Amaç:** BMI hesaplamak ve kullanıcı profiline göre lokal program üretmek

> **Not:** API'den program gelmez, program lokal olarak bu servis üretir. API ise egzersizleri ve takvimi verir.

### BMI Hesaplama

```dart
static double calculateBMI(double heightCm, double weightKg)
// BMI = weight / (height_m)²
// Örn: 70kg / (1.75m)² = 22.86
```

### BMI Değerlendirme

```dart
static BMIEvaluation evaluateBMI(double bmi)
// Döndürür: { category, description, color }
```

| Aralık | Kategori | Renk |
|--------|----------|------|
| < 18.5 | Zayıf | Cyan `#00E5FF` |
| 18.5–25 | Normal | Neon Yeşil `#00FF87` |
| 25–30 | Fazla Kilolu | Gold `#FFD700` |
| > 30 | Obez | Kırmızı `#FF3366` |

### Program Üretme

```dart
static WorkoutProgram generateProgram(UserProfile profile)
```

**Karar Ağacı:**
```
goal içeriyor 'Kilo Ver'?
  └── EVET → HIIT Fat Burn (4 gün/hafta)

goal içeriyor 'Kas' veya 'Hacim'?
  ├── gender == 'Erkek' → Üst Vücut Hipertrofi (5 gün)
  └── gender == 'Kadın' → Alt Vücut Hipertrofi (5 gün)

Diğer (Formda Kal):
  └── Full Body Kondisyon (3 gün/hafta)
```

---

## Servis Çağrı Haritası

```
main.dart
  └── LocalStorageService.init()

OnboardingScreen
  ├── [POST API] save_profile.php
  ├── LocalStorageService.saveUserId()
  ├── LocalStorageService.saveUserProfile()
  ├── WorkoutGeneratorService.generateProgram()
  └── LocalStorageService.saveWorkoutProgram()

DashboardScreen
  ├── LocalStorageService.getSavedUserId()
  └── [GET API] get_progress.php

ProfileScreen
  ├── LocalStorageService.getSavedProfile()
  ├── WorkoutGeneratorService.calculateBMI()
  └── [GET API] get_profile.php

ProgramResultScreen
  └── WorkoutGeneratorService.evaluateBMI()
```

---

## Bağlantılar

- [[02_Modeller]] — servislerle kullanılan modeller
- [[06_API]] — HTTP isteklerinin gönderildiği yer
- [[07_İş_Mantığı]] — program üretme kuralları detayı
- [[09_Veri_Akışı]] — servisler akış içinde nerede
