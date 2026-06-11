---
tags: [onboarding, kullanıcı-akışı, kayıt]
created: 2026-06-11
updated: 2026-06-11
type: feature
related: [02_Modeller, 06_Veritabanı, 09_Veri_Akışı]
---

# Onboarding Akışı

> Uygulamayı ilk açan kullanıcının geçtiği 9 adımlı kayıt ve profil oluşturma akışı.  
> Dosya: `lib/screens/onboarding/onboarding_screen.dart`

---

## Genel Yapı

- `PageView` + `PageController` ile 9 adım arasında gezinme
- Her adım `lib/screens/onboarding/widgets/` altında ayrı widget
- `UserProfile` nesnesi OnboardingScreen state'inde biriktirilir
- Son adımdan sonra **SQLite'a kayıt** → program üretimi → MainScreen

---

## 9 Adım

### Adım 1 — NicknameStep
**Dosya:** `nickname_step.dart`  
**Input:** TextFormField  
**Veri:** `UserProfile.nickname`  
**Validasyon:** Boş bırakılamaz

### Adım 2 — GenderStep
**Dosya:** `gender_step.dart`  
**Input:** Görsel kart seçimi (iki kart)  
**Seçenekler:** `Erkek` | `Kadın`  
**Veri:** `UserProfile.gender`  
**Önemi:** Egzersiz filtrelemede kullanılır (bkz. [[07_İş_Mantığı]] §3.2)

### Adım 3 — PhysicalStep
**Dosya:** `physical_step.dart`  
**Input:** 3 ayrı slider/input  
**Veri:**
- `UserProfile.age` (varsayılan: 25)
- `UserProfile.height` (varsayılan: 175.0 cm)
- `UserProfile.weight` (varsayılan: 70.0 kg)

**Not:** Weight + Height → BMI hesabı → Obezite kontrolü

### Adım 4 — GoalStep
**Dosya:** `goal_step.dart`  
**Seçenekler:** `Kilo Ver` | `Kas Kütlesi Kazan` | `Formda Kal`  
**Veri:** `UserProfile.goal`  
**Kritik:** Program tipini belirler (bkz. [[07_İş_Mantığı]] §1)

### Adım 5 — TargetWeightStep
**Dosya:** `target_weight_step.dart`  
**Input:** Slider (dinamik aralık)  
**Veri:** `UserProfile.targetWeight`

### Adım 6 — TargetMusclesStep
**Dosya:** `target_muscles_step.dart`  
**Input:** Çoklu seçim kartlar  
**Seçenekler:** `Full Body` | `Göğüs` | `Sırt` | `Kollar` | `Bacak` | `Karın`  
**Veri:** `UserProfile.targetMuscles` (List\<String\>)  
**Önemi:** Egzersiz kas grubu rotasyonunu belirler (bkz. [[07_İş_Mantığı]] §3.4)

### Adım 7 — LevelStep
**Dosya:** `level_step.dart`  
**Seçenekler:** `Yeni Başlayan` (4 egzersiz/gün) | `Orta` (5) | `İleri` (6)  
**Veri:** `UserProfile.level`

### Adım 8 — WorkoutDaysStep
**Dosya:** `workout_days_step.dart`  
**Input:** Gün seçimi (Pazartesi–Pazar, checkbox)  
**Veri:** Seçilen günler listesi (SQLite'a `'Pazartesi,Çarşamba,Cuma'` olarak yazılır)

### Adım 9 — EnvironmentStep
**Dosya:** `environment_step.dart`  
**Seçenekler:** `Ev` | `Spor Salonu`  
**Veri:** `UserProfile.environment`  
**Önemi:** Egzersiz ortam filtresini belirler (bkz. [[07_İş_Mantığı]] §3.1)

---

## Onboarding Tamamlama Akışı

```
Adım 9 tamamlandı
  │
  ├── 1. DatabaseService.insertUser(profile, selectedDays)
  │       → users tablosuna yazılır
  │       → user_id döner (AUTO_INCREMENT)
  │       → DatabaseService.savedUserId = user_id
  │
  ├── 2. WorkoutGeneratorService.generateProgram(profile)
  │       → WorkoutProgram (sadece önizleme, DB'ye yazılmaz)
  │
  └── 3. Navigator → AnalysisLoadingScreen (4 sn)
              └── Navigator → ProgramResultScreen
                        └── [Onayla] → MainScreen
```

**Eski mimariden fark:** API çağrısı yoktur. `POST /save_profile.php` yerine doğrudan SQLite yazması.

---

## Widget Pattern

Tüm step widget'ları ortak kalıbı paylaşır:

```dart
class XxxStep extends StatefulWidget {
  final SomeType? initialValue;
  final ValueChanged<SomeType> onChanged;  // Parent'a bildir

  @override
  Widget build(BuildContext context) {
    // Seçim animasyonu: AnimatedContainer
    // Callback: widget.onChanged(yeniDeger)
  }
}
```

---

## Bağlantılar

- [[02_Modeller]] — UserProfile modeli
- [[06_Veritabanı]] — SQLite users tablosu
- [[07_İş_Mantığı]] — program seçim ve filtreleme kuralları
- [[04_Ekranlar]] — onboarding sonrası ekranlar
