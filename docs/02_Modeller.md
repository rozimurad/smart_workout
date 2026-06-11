---
tags: [modeller, dart, data-classes]
created: 2026-06-11
type: models
related: [01_Mimari, 03_Servisler, 07_İş_Mantığı]
---

# Veri Modelleri

> `lib/models/` altındaki 3 Dart data sınıfı.

---

## UserProfile

**Dosya:** `lib/models/user_profile.dart`  
**Kullanım:** Onboarding boyunca biriktirilir, API'ye gönderilir, SharedPreferences'a cache'lenir.

```dart
class UserProfile {
  String? nickname;          // Kullanıcı adı
  String? gender;            // 'Erkek' | 'Kadın'
  int age;                   // Yaş (default: 25)
  double height;             // Boy cm (default: 175.0)
  double weight;             // Kilo kg (default: 70.0)
  String? goal;              // 'Kilo Ver' | 'Kas Kütlesi Kazan' | 'Formda Kal'
  String? level;             // 'Yeni Başlayan' | 'Orta' | 'İleri'
  String? environment;       // 'Ev' | 'Spor Salonu'
  List<String>? targetMuscles; // ['Göğüs', 'Sırt', 'Kollar', 'Bacak', 'Karın']
  double? targetWeight;      // Hedef kilo
}
```

**Notlar:**
- `toJson()` ile API'ye gönderilir
- `fromJson()` ile SharedPreferences'tan geri yüklenir
- `goal` değeri program tipini belirler (bkz. [[07_İş_Mantığı]])
- `level` değeri max antrenman gün sayısını belirler

---

## WorkoutProgram

**Dosya:** `lib/models/workout_program.dart`  
**Kullanım:** `WorkoutGeneratorService` tarafından üretilir, dashboard ve profile ekranında gösterilir.

```dart
class WorkoutProgram {
  String programAdi;           // Örn: "HIIT Fat Burn"
  String aciklama;             // Program açıklaması
  int haftalikGunSayisi;       // Haftada kaç gün (3 | 4 | 5)
  String hedefKategori;        // 'Yağ Yakımı' | 'Kas' | 'Kondisyon'
}
```

**Program Tipleri** (bkz. [[07_İş_Mantığı]]):

| programAdi | goal | gender | haftalikGunSayisi |
|-----------|------|--------|-------------------|
| Yüksek Yoğunluklu Yağ Yakımı (HIIT) | Kilo Ver | — | 4 |
| Üst Vücut Odaklı Hipertrofi | Kas Kazan | Erkek | 5 |
| Alt Vücut Odaklı Hipertrofi | Kas Kazan | Kadın | 5 |
| Tüm Vücut (Full Body) Kondisyon | Formda Kal | — | 3 |

---

## WorkoutExercise

**Dosya:** `lib/models/workout_exercise.dart`  
**Kullanım:** API'den gelen egzersiz listesi. WorkoutSessionScreen'de GIF + bilgi olarak gösterilir.

```dart
class WorkoutExercise {
  String name;     // Egzersiz adı (Türkçe)
  String gifUrl;   // Egzersiz animasyon URL'si

  factory WorkoutExercise.fromJson(Map<String, dynamic> json)
}
```

**Veri Kaynağı:** `GET /api/get_workout.php` → schedule içindeki egzersiz listesi

---

## Model İlişkileri

```
UserProfile
  │
  ├── [onboarding'de doldurulur]
  ├── [POST /save_profile.php'ye gönderilir]
  ├── [SharedPreferences'a cache'lenir]
  │
  └──► WorkoutGeneratorService.generateProgram(profile)
         └──► WorkoutProgram (lokal üretilir)

WorkoutExercise
  └── [GET /api/get_workout.php'den gelir]
       └──► WorkoutSessionScreen'de kullanılır
```

---

## Bağlantılar

- [[03_Servisler]] — modelleri kullanan servisler
- [[05_Onboarding]] — UserProfile'ın nasıl doldurulduğu
- [[06_API]] — API JSON formatları
- [[07_İş_Mantığı]] — program seçim kuralları
