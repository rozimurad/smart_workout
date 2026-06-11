---
tags: [veri-akışı, state, navigation, uçtan-uca]
created: 2026-06-11
type: data-flow
related: [01_Mimari, 03_Servisler, 06_API, 04_Ekranlar]
---

# Veri Akışı

> Verinin uygulamaya girdiği noktadan depolandığı yere kadar tam yolculuğu.  
> Bu sayfa "bir şeyi değiştirirsem ne etkilenir?" sorusunu cevaplamak için.

---

## 1. Uygulama Başlangıcı

```
main() {
  await LocalStorageService.init()    // SP'yi belleğe yükle
  runApp(AkilliAntrenmanApp)
}

AkilliAntrenmanApp.build() {
  user_id = LocalStorageService.getSavedUserId()
  user_id != null ? route '/main' : route '/'
}
```

**Karar noktası:** user_id var mı?  
→ Evet: MainScreen (kalıcı kullanıcı)  
→ Hayır: OnboardingScreen (yeni kullanıcı)

---

## 2. Onboarding Veri Akışı

```
OnboardingScreen (state: UserProfile profile = UserProfile())
  │
  ├── Adım 1: NicknameStep.onChanged → profile.nickname = 'Ali'
  ├── Adım 2: GenderStep.onChanged → profile.gender = 'Erkek'
  ├── Adım 3: PhysicalStep.onChanged → profile.age/height/weight
  ├── Adım 4: GoalStep.onChanged → profile.goal = 'Kilo Ver'
  ├── Adım 5: TargetWeightStep.onChanged → profile.targetWeight
  ├── Adım 6: TargetMusclesStep.onChanged → profile.targetMuscles
  ├── Adım 7: LevelStep.onChanged → profile.level = 'Orta'
  ├── Adım 8: WorkoutDaysStep.onChanged → selectedDays = [...]
  └── Adım 9: EnvironmentStep.onChanged → profile.environment
         │
         └── [Son adım tamamlandı]
               ↓
         POST /save_profile.php
               ↓ user_id = 42
         LocalStorageService.saveUserId(42)
         LocalStorageService.saveUserProfile(profile)
               ↓
         WorkoutGeneratorService.generateProgram(profile)
               ↓ WorkoutProgram
         LocalStorageService.saveWorkoutProgram(program)
               ↓
         Navigator → AnalysisLoadingScreen (4sn)
               ↓
         Navigator → ProgramResultScreen
               ↓ [Onayla]
         Navigator.pushAndRemoveUntil → MainScreen
```

---

## 3. MainScreen Veri Akışı

### DashboardScreen
```
initState() {
  user_id = LocalStorageService.getSavedUserId()   // sync
  profile = LocalStorageService.getSavedProfile()  // sync (cache)
  program = LocalStorageService.getSavedProgram()  // sync (cache)
  GET /get_progress.php?user_id=42                 // async API
}
  ↓ setState()
UI güncellenir: ilerleme, BMI, program kartları
```

### ProfileScreen
```
initState() {
  profile = LocalStorageService.getSavedProfile()  // hızlı göster
  GET /get_profile.php?user_id=42                  // detay güncelle
}

updateWeight(yeniKilo) {
  POST /update_weight.php { user_id, weight }
    ↓
  Hedef başarı kontrolü (bkz. [[07_İş_Mantığı]])
    ├── Başarı → Modal → Yeni hedef / Formda kal
    └── Devam → UI güncelle
}
```

### HistoryScreen
```
initState() {
  GET /get_history.php?user_id=42
}
  ↓ setState()
ListView güncellenir
```

---

## 4. Antrenman Oturumu Akışı

```
WorkoutScheduleScreen
  └── GET /get_workout.php?user_id=42
        ↓ schedule, today_state, program_id
  ↓ "Antrenmanı Başlat" [today_state == 'workout_time']
WorkoutSessionScreen(schedule, program_id)
  ├── exercises = schedule["Gün X"]  (parametre olarak gelir)
  ├── [Timer mantığı — bkz. [[07_İş_Mantığı]] §6]
  └── [Tamamlandı]
        POST /complete_workout.php {
          user_id, program_id,
          total_time, total_exercises, total_sets
        }
          ↓ success
        Navigator.pushAndRemoveUntil → MainScreen
```

---

## 5. Veri Depolama Haritası

```
Veri Tipi          | Nerede Depolanır      | Kimle Senkronize
─────────────────────────────────────────────────────────────
user_id            | SharedPreferences     | POST /save_profile
nickname           | SharedPreferences     | POST /save_profile
gender             | SharedPreferences     | POST /save_profile
age                | SharedPreferences     | POST /save_profile
height             | SharedPreferences     | POST /save_profile
weight             | SharedPreferences     | POST /update_weight
goal               | SharedPreferences     | POST /update_goal_and_weight
level              | SharedPreferences     | POST /save_profile
environment        | SharedPreferences     | POST /save_profile
target_muscles     | SharedPreferences     | POST /save_profile
target_weight      | SharedPreferences     | POST /save_profile
program_adi        | SharedPreferences     | lokal üretim
program_aciklama   | SharedPreferences     | lokal üretim
program_gun_sayisi | SharedPreferences     | lokal üretim
program_kategori   | SharedPreferences     | lokal üretim
antrenman geçmişi  | Sadece API DB         | GET /get_history
aylık ilerleme     | Sadece API DB         | GET /get_progress
haftalık takvim    | Sadece API DB         | GET /get_workout
```

---

## 6. Logout Akışı

```
DashboardScreen → Logout butonu
  ↓
LocalStorageService.clearAll()
  (tüm SharedPreferences verileri silinir)
  ↓
Navigator.pushAndRemoveUntil → OnboardingScreen
  (stack tamamen temizlenir)
```

**Sunucuda hiçbir şey olmaz** — session yönetimi yok.

---

## 7. Hata Durumları

```
API isteği başarısız:
  ├── Timeout (>10sn) → SnackBar: "Bağlantı hatası"
  ├── status != 200  → Hata state + retry butonu
  └── JSON parse err → Hata state

SharedPreferences null:
  → UI default değer gösterir (nullsafe kullanım)
```

---

## Bağlantılar

- [[01_Mimari]] — genel yapı
- [[03_Servisler]] — LocalStorageService ve WorkoutGeneratorService
- [[06_API]] — tüm endpoint detayları
- [[04_Ekranlar]] — ekranların initState davranışları
- [[07_İş_Mantığı]] — iş kuralları kararları
