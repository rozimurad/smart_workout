---
tags: [veri-akışı, state, navigation, uçtan-uca, sqlite]
created: 2026-06-11
updated: 2026-06-11
type: data-flow
related: [01_Mimari, 03_Servisler, 06_Veritabanı, 04_Ekranlar]
---

# Veri Akışı

> Verinin uygulamaya girdiği noktadan SQLite'a yazıldığı yere kadar tam yolculuğu.  
> HTTP/API çağrısı yoktur — her şey cihaz içinde gerçekleşir.

---

## 1. Uygulama Başlangıcı

```dart
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();   // DB aç, tabloları oluştur, user_id cache'le
  runApp(AkilliAntrenmanApp());
}

AkilliAntrenmanApp.build() {
  initialRoute = DatabaseService.savedUserId != null ? '/main' : '/'
}
```

**Karar noktası:** `savedUserId` var mı?
- Evet → `MainScreen` (mevcut kullanıcı)
- Hayır → `OnboardingScreen` (yeni kullanıcı)

---

## 2. Onboarding Veri Akışı

```
OnboardingScreen  (state: UserProfile profile = UserProfile())
  │
  ├── Adım 1: NicknameStep      → profile.nickname = 'Ali'
  ├── Adım 2: GenderStep        → profile.gender = 'Erkek'
  ├── Adım 3: PhysicalStep      → profile.age / height / weight
  ├── Adım 4: GoalStep          → profile.goal = 'Kas Kütlesi Kazan'
  ├── Adım 5: TargetWeightStep  → profile.targetWeight = 75.0
  ├── Adım 6: TargetMusclesStep → profile.targetMuscles = ['Göğüs', 'Kollar']
  ├── Adım 7: LevelStep         → profile.level = 'Orta'
  ├── Adım 8: WorkoutDaysStep   → selectedDays = ['Pazartesi', 'Çarşamba', 'Cuma']
  └── Adım 9: EnvironmentStep   → profile.environment = 'Spor Salonu'
         │
         └── [Son adım — "Devam" butonuna basıldı]
               ↓
         DatabaseService.insertUser(profile, selectedDays)
               ↓ user_id = 1  (SQLite AUTO_INCREMENT)
         DatabaseService.savedUserId = 1  (static cache)
               ↓
         WorkoutGeneratorService.generateProgram(profile)
               ↓ WorkoutProgram (sadece önizleme için, DB'ye yazılmaz)
               ↓
         Navigator → AnalysisLoadingScreen (4 sn animasyon)
               ↓
         Navigator → ProgramResultScreen (BMI + program adı)
               ↓ [Onayla]
         Navigator.pushAndRemoveUntil → MainScreen
```

---

## 3. MainScreen Veri Akışı

### DashboardScreen

```
initState() {
  userId = DatabaseService.savedUserId          // sync, await yok
  data = await DatabaseService.getDashboardData(userId)
    ├── getUser(userId)                          // users tablosu
    └── workout_sessions WHERE bu_ay            // aylık istatistik
}
  ↓ setState()
UI: ilerleme yüzdesi, BMI, aylık süre/set/egzersiz sayısı
```

### ProfileScreen

```
initState() {
  userId = DatabaseService.savedUserId
  userRow = await DatabaseService.getUser(userId)
  profile = _rowToProfile(userRow)
  program = WorkoutGeneratorService.generateProgram(profile)
}

updateWeight(yeniKilo) {
  await DatabaseService.updateWeight(userId, yeniKilo)
    ↓
  Hedef başarı kontrolü (bkz. [[07_İş_Mantığı]] §6)
    ├── Başarı → Kutlama Modal (Lottie asset)
    └── Devam  → setState() ile UI güncellenir
}

updateWorkoutDays(yeniGünler) {
  await DatabaseService.updateWorkoutDays(userId, yeniGünler)
  setState()
}
```

### HistoryScreen

```
initState() {
  userId = DatabaseService.savedUserId
  sessions = await DatabaseService.getHistory(userId)
    → SELECT * FROM workout_sessions WHERE user_id = ? ORDER BY completed_at DESC
}
  ↓ setState()
ListView güncellenir
```

---

## 4. Antrenman Oturumu Akışı

```
WorkoutScheduleScreen
  └── await DatabaseService.getScheduleData(userId)
        ├── getUser(userId)                       → users tablosu (profil)
        ├── workout_sessions bugün var mı?         → already_done kontrolü
        └── buildFilteredSchedule(                 → exercise_data.dart
              gender, env, targetMuscles,
              goal, level, weight, height
            )
              ↓ schedule (Map<String, List<exercises>>)

  ↓ Her günün tile'ı gösterilir
  ↓ Yalnızca bugünkü güne "Antrenmanı Başlat" butonu aktif
  ↓ [Bugünkü güne basıldı]

WorkoutSessionScreen(exercisesRaw: dagEgzersizler, programName: ...)
  ├── exercises = WorkoutExercise.fromMap(egzersizRaw)
  ├── [10sn hazırlık → egzersiz → dinlenme döngüsü]
  └── [Tüm egzersizler tamamlandı]
        await DatabaseService.insertSession(
          userId, programName,
          totalTimeSeconds, totalExercises, totalSets
        )
          ↓
        Modal → Navigator.pushAndRemoveUntil → MainScreen
```

---

## 5. Veri Depolama Haritası

```
Veri Tipi            | Nerede              | Nasıl güncellenir
─────────────────────────────────────────────────────────────────
nickname             | SQLite / users      | Onboarding
gender               | SQLite / users      | Onboarding
age / height         | SQLite / users      | Onboarding
weight               | SQLite / users      | ProfileScreen.updateWeight
goal                 | SQLite / users      | ProfileScreen.updateGoalAndWeight
level                | SQLite / users      | Onboarding
environment          | SQLite / users      | Onboarding
target_muscles       | SQLite / users      | Onboarding
target_weight        | SQLite / users      | Onboarding
workout_days         | SQLite / users      | ProfileScreen.updateWorkoutDays
program_type         | SQLite / users      | Onboarding / goal güncelleme
─────────────────────────────────────────────────────────────────
antrenman geçmişi    | SQLite / workout_sessions | WorkoutSessionScreen
─────────────────────────────────────────────────────────────────
egzersiz kataloğu    | Dart sabit liste    | Değişmez (compile-time)
GIF dosyaları        | assets/exercises/man/ | Değişmez (bundle)
program adı/meta     | Bellek (runtime)    | Her açılışta üretilir
```

---

## 6. Logout Akışı

```
DashboardScreen → Çıkış Yap
  ↓
DatabaseService.clearAll()
  DELETE FROM workout_sessions;
  DELETE FROM users;
  savedUserId = null;
  ↓
Navigator.pushAndRemoveUntil → OnboardingScreen
  (stack tamamen temizlenir)
```

---

## 7. Hata Durumları

```
SQLite işlemi başarısız:
  → sqflite exception yakalanır
  → Ekranda hata mesajı gösterilir (setState)
  → "Yeniden Dene" butonu

DatabaseService.savedUserId == null ama MainScreen açık:
  → Her ekran bu kontrolü initState'de yapar
  → null ise → "Kullanıcı bulunamadı" mesajı

GIF dosyası bulunamadı (assets/exercises/man/):
  → Image.asset errorBuilder → placeholder widget gösterilir
  → Egzersiz bilgileri (ad, set, tekrar) yine de görünür

Egzersiz sayısı yetersiz (nadir):
  → buildFilteredSchedule() full_body egzersizlerle doldurur
  → Slot tamamen boş kalmaz
```

---

## Bağlantılar

- [[01_Mimari]] — genel yapı
- [[03_Servisler]] — DatabaseService ve exercise_data detayları
- [[06_Veritabanı]] — SQLite tablo şeması
- [[04_Ekranlar]] — ekranların initState davranışları
- [[07_İş_Mantığı]] — iş kuralları kararları
