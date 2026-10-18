---
tags: [servisler, sqlite, sqflite, bmi, program-generation, exercise-filter]
created: 2026-06-11
updated: 2026-06-11
type: services
related: [01_Mimari, 02_Modeller, 06_Veritabanı, 07_İş_Mantığı]
---

# Servisler

> `lib/services/` ve `lib/data/` altındaki servis ve veri katmanı.  
> Tüm iş mantığı ve depolama buradadır — HTTP/API yoktur.

---

## DatabaseService

**Dosya:** `lib/services/database_service.dart`  
**Tip:** Singleton  
**Amaç:** SQLite üzerinden kullanıcı ve antrenman verisi CRUD işlemleri + haftalık program üretme

### Başlatma

```dart
// main.dart içinde:
await DatabaseService.init();
// DB dosyasını açar, tabloları oluşturur, son user_id'yi cache'ler
```

### Static Erişim

```dart
static int? get savedUserId
// Senkron erişim — await gerekmez
// null ise → kullanıcı onboarding yapmamış
```

### Kullanıcı Metodları

```dart
Future<int> insertUser(UserProfile profile, List<String> workoutDays)
// Onboarding tamamlanınca çağrılır → SQLite'a yazar, user_id döndürür

Future<Map<String, dynamic>?> getUser(int userId)
// users tablosundan tek satır çeker

Future<void> updateWorkoutDays(int userId, List<String> days)
// Profil ekranından antrenman günleri güncelleme

Future<void> updateWeight(int userId, double weight)
// Güncel kilo güncelleme

Future<void> updateGoalAndWeight(int userId, String goal, double weight)
// Hedef başarısı sonrası yeni hedef / formda kal

Future<void> clearAll()
// Tüm users + workout_sessions siler → Logout
```

### Antrenman Metodları

```dart
Future<void> insertSession({
  required int userId,
  required String programName,
  required int totalTimeSeconds,
  required int totalExercises,
  required int totalSets,
})
// Antrenman bitince kaydeder

Future<List<Map<String, dynamic>>> getHistory(int userId)
// Geçmiş antrenmanlar (DESC sırali)
```

### Dashboard ve Takvim

```dart
Future<Map<String, dynamic>> getDashboardData(int userId)
// Döndürür: user_name, bmi_value, bmi_status, progress_percentage,
//           monthly_time_minutes, monthly_sets, monthly_exercises,
//           completed_workouts, monthly_target

Future<Map<String, dynamic>> getScheduleData(int userId)
// Döndürür: today_state, message, schedule, program_title, today_day_name
// schedule = buildFilteredSchedule() çıktısı (her açılışta yeniden üretilir)
```

**`today_state` değerleri:**

| Değer | Anlam |
|-------|-------|
| `workout_time` | Bugün antrenman günü, henüz yapılmadı |
| `already_done` | Bugün zaten tamamlandı |
| `rest` | Bugün dinlenme günü |

---

## exercise_data.dart

**Dosya:** `lib/data/exercise_data.dart`  
**Tip:** Sabit liste + filtre fonksiyonları  
**Amaç:** 38 egzersizin kataloğu ve kullanıcı profiline göre filtrelenmiş program üretme

### Egzersiz Kataloğu

```dart
const List<Map<String, dynamic>> kAllExercises = [
  {
    'name': 'Push-up',
    'gif': 'pushup-man.gif',         // assets/exercises/man/ altında
    'muscle': 'gogus',               // gogus | sirt | kol | bacak | karin | full_body
    'env': 'ev',                     // ev | salon | hepsi
    'gender': 'hepsi',               // erkek | kadin | hepsi
    'high_impact': false,            // true → obezlerde gösterilmez
  },
  // ... 37 egzersiz daha
];
```

**`high_impact: true` olan egzersizler** (BMI ≥ 30 kullanıcılarda çıkarılır):
- Burpees, Jumping Jack, High Knees, Squat Jump, Mountain Climber, Box Jump

### Ana Fonksiyon

```dart
Map<String, List<Map<String, dynamic>>> buildFilteredSchedule({
  required List<String> userDays,      // ['Pazartesi', 'Çarşamba', 'Cuma']
  required String gender,              // 'Erkek' | 'Kadın'
  required String environment,         // 'Ev' | 'Spor Salonu'
  required List<String> targetMuscles, // ['Göğüs', 'Kollar']
  required String goal,                // 'Kilo Ver' | 'Kas Kütlesi Kazan' | ...
  required String level,               // 'Yeni Başlayan' | 'Orta' | 'İleri'
  double weight,                       // kg (obezite kontrolü için)
  double height,                       // cm (obezite kontrolü için)
})
```

**Filtre adımları:**
1. `env` → ev / salon / hepsi
2. `gender` → erkek / kadin / hepsi
3. `high_impact` → BMI ≥ 30 ise `true` olanlar çıkar
4. Kas rotasyonu: seçilen kaslar arasında döngü (Gün 1 = 1. kas, Gün 2 = 2. kas, ...)
5. Her gün `Random()` ile karıştırılmış listeden seçilir (her açılışta farklı)
6. Eksik slot: önce `full_body` egzersizler, sonra herhangi uygun egzersiz

**Gün başına egzersiz sayısı:**

| Seviye | Egzersiz/Gün |
|--------|-------------|
| Yeni Başlayan | 4 |
| Orta | 5 |
| İleri | 6 |

**Set/Tekrar/Dinlenme parametreleri:**

| Hedef | Set | Tekrar | Dinlenme |
|-------|-----|--------|---------|
| Kilo Ver (Başlangıç) | 3 | 15 | 30 sn |
| Kilo Ver (İleri) | 3 | 20 | 20 sn |
| Kas Kazan (Başlangıç) | 3 | 10 | 90 sn |
| Kas Kazan (Orta) | 4 | 10 | 90 sn |
| Kas Kazan (İleri) | 5 | 8 | 90 sn |
| Formda Kal | 3–4 | 12–15 | 45–60 sn |

---

## WorkoutGeneratorService

**Dosya:** `lib/services/workout_generator_service.dart`  
**Tip:** Static utility class  
**Amaç:** BMI hesaplamak ve program adı/meta üretmek

### BMI Hesaplama

```dart
static double calculateBMI(double heightCm, double weightKg)
// BMI = weight / (height_m)²
// Örn: 70 / (1.75)² = 22.86

static BMIEvaluation evaluateBMI(double bmi)
// Döndürür: { category, description, color }
```

| Aralık | Kategori | Renk |
|--------|----------|------|
| < 18.5 | Zayıf | Cyan `#00E5FF` |
| 18.5–24.9 | Normal | Neon Yeşil `#00FF87` |
| 25–29.9 | Fazla Kilolu | Gold `#FFD700` |
| ≥ 30 | Obez | Kırmızı `#FF3366` |

### Program Üretme

```dart
static WorkoutProgram generateProgram(UserProfile profile)
```

Karar ağacı:
```
goal içeriyor 'Kilo Ver' ?  → HIIT Fat Burn      (4 gün)
goal içeriyor 'Kas'?
  gender == 'Erkek'         → Üst Vücut Hipertrofi (5 gün)
  gender == 'Kadın'         → Alt Vücut Hipertrofi  (5 gün)
Diğer                       → Full Body Kondisyon   (3 gün)
```

---

## Servis Çağrı Haritası

```
main.dart
  └── DatabaseService.init()

OnboardingScreen
  ├── DatabaseService.insertUser(profile, days)
  └── WorkoutGeneratorService.generateProgram(profile)  [önizleme için]

DashboardScreen
  ├── DatabaseService.savedUserId            [sync]
  └── DatabaseService.getDashboardData(id)  [async]

WorkoutScheduleScreen
  └── DatabaseService.getScheduleData(id)
        └── buildFilteredSchedule()          [içeride çağrılır]

WorkoutSessionScreen
  └── DatabaseService.insertSession(...)    [tamamlanınca]

ProfileScreen
  ├── DatabaseService.getUser(id)
  ├── DatabaseService.updateWeight(id, w)
  ├── DatabaseService.updateWorkoutDays(id, days)
  └── DatabaseService.updateGoalAndWeight(id, goal, w)

HistoryScreen
  └── DatabaseService.getHistory(id)
```

---

## Bağlantılar

- [[02_Modeller]] — servislerle kullanılan modeller
- [[06_Veritabanı]] — SQLite tablo şeması
- [[07_İş_Mantığı]] — filtreleme ve program seçimi kuralları detayı
- [[09_Veri_Akışı]] — servisler akış içinde nerede
