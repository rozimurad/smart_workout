---
tags: [modeller, dart, data-classes]
created: 2026-06-11
updated: 2026-06-11
type: models
related: [01_Mimari, 03_Servisler, 07_İş_Mantığı]
---

# Veri Modelleri

> `lib/models/` altındaki 3 Dart data sınıfı.

---

## UserProfile

**Dosya:** `lib/models/user_profile.dart`  
**Kullanım:** Onboarding boyunca biriktirilir, tamamlanınca `DatabaseService.insertUser()` ile SQLite'a yazılır.

```dart
class UserProfile {
  String? nickname;              // Kullanıcı adı
  String? gender;                // 'Erkek' | 'Kadın'
  int age;                       // Yaş (default: 25)
  double height;                 // Boy cm (default: 175.0)
  double weight;                 // Kilo kg (default: 70.0)
  String? goal;                  // 'Kilo Ver' | 'Kas Kütlesi Kazan' | 'Formda Kal'
  String? level;                 // 'Yeni Başlayan' | 'Orta' | 'İleri'
  String? environment;           // 'Ev' | 'Spor Salonu'
  List<String>? targetMuscles;   // ['Göğüs', 'Sırt', 'Kollar', 'Bacak', 'Karın', 'Full Body']
  double? targetWeight;          // Hedef kilo
}
```

**Notlar:**
- SQLite'a yazılırken `target_muscles` virgülle birleştirilir: `'Göğüs,Kollar'`
- `goal` değeri program tipini belirler (bkz. [[07_İş_Mantığı]])
- `weight` ve `height` değerleri BMI hesaplamada kullanılır
- Obezite kontrolü: `weight / (height/100)²` ≥ 30 ise yüksek darbeli egzersizler çıkarılır

---

## WorkoutProgram

**Dosya:** `lib/models/workout_program.dart`  
**Kullanım:** `WorkoutGeneratorService.generateProgram()` tarafından lokal olarak üretilir. Dashboard ve Profile ekranında gösterilir.

```dart
class WorkoutProgram {
  String programAdi;           // Örn: "Yüksek Yoğunluklu Yağ Yakımı (HIIT)"
  String aciklama;             // Program açıklaması
  int haftalikGunSayisi;       // Haftada kaç gün (3 | 4 | 5)
  String hedefKategori;        // 'Yağ Yakımı' | 'Kas Kütlesi' | 'Kondisyon'
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
**Kullanım:** `buildFilteredSchedule()` çıktısından oluşturulur. `WorkoutSessionScreen`'de GIF + bilgi olarak gösterilir.

```dart
class WorkoutExercise {
  final String name;        // Egzersiz adı (İngilizce)
  final String imagePath;   // Yerel asset yolu: 'assets/exercises/man/pushup-man.gif'
  final int setCount;       // Set sayısı
  final int repCount;       // Tekrar sayısı
  final int restDuration;   // Dinlenme süresi (saniye)
}
```

**Veri Kaynağı:** `lib/data/exercise_data.dart` → `buildFilteredSchedule()` → `WorkoutSessionScreen`'e parametre olarak geçilir.

**Not:** Eski mimaride `gifUrl` (network URL) vardı. Yeni mimaride `imagePath` (yerel asset) kullanılıyor. GIF'ler `assets/exercises/man/` klasöründe bulunur.

---

## Model İlişkileri

```
UserProfile
  │
  ├── [onboarding'de adım adım doldurulur]
  └── DatabaseService.insertUser(profile, days)
         └── SQLite users tablosuna yazılır
               ↓
         DatabaseService.savedUserId (static, sync erişim)

WorkoutProgram
  └── WorkoutGeneratorService.generateProgram(profile)
         └── Lokal olarak üretilir (DB'ye yazılmaz)

WorkoutExercise
  └── buildFilteredSchedule(gender, env, muscles, goal, level, weight, height)
         └── kAllExercises listesinden filtrelenerek üretilir
               └── WorkoutSessionScreen'de kullanılır
```

---

## Bağlantılar

- [[03_Servisler]] — modelleri kullanan servisler
- [[05_Onboarding]] — UserProfile'ın nasıl doldurulduğu
- [[06_Veritabanı]] — SQLite tablo şeması
- [[07_İş_Mantığı]] — program seçim ve egzersiz filtreleme kuralları
