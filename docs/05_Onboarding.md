---
tags: [onboarding, kullanıcı-akışı, kayıt]
created: 2026-06-11
type: feature
related: [02_Modeller, 06_API, 09_Veri_Akışı]
---

# Onboarding Akışı

> Uygulamayı ilk açan kullanıcının geçtiği 9 adımlı kayıt ve profil oluşturma akışı.  
> Dosya: `lib/screens/onboarding/onboarding_screen.dart`

---

## Genel Yapı

- `PageView` + `PageController` ile 9 adım arasında gezinme
- Her adım `lib/screens/onboarding/widgets/` altında ayrı widget
- `UserProfile` nesnesi OnboardingScreen state'inde biriktirilir
- Son adımdan sonra API çağrısı → program üretimi → MainScreen

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
**UI:** Her cinsiyet için illüstrasyon + seçim animasyonu

### Adım 3 — PhysicalStep
**Dosya:** `physical_step.dart`  
**Input:** 3 ayrı slider/input  
**Veri:**
- `UserProfile.age` (varsayılan: 25)
- `UserProfile.height` (varsayılan: 175.0 cm)
- `UserProfile.weight` (varsayılan: 70.0 kg)

### Adım 4 — GoalStep
**Dosya:** `goal_step.dart`  
**Input:** Genişletilebilir liste (tek seçim)  
**Seçenekler:**
- `Kilo Ver`
- `Kas Kütlesi Kazan`
- `Formda Kal`

**Veri:** `UserProfile.goal`  
**Kritik:** Bu seçim program tipini belirler (bkz. [[07_İş_Mantığı]])

### Adım 5 — TargetWeightStep
**Dosya:** `target_weight_step.dart`  
**Input:** Slider (dinamik aralık)  
**Aralık:** Mevcut kiloya göre hesaplanır  
- Kilo Ver → hedef mevcut kilodan düşük
- Kas Kazan → hedef mevcut kilodan yüksek

**Veri:** `UserProfile.targetWeight`

### Adım 6 — TargetMusclesStep
**Dosya:** `target_muscles_step.dart`  
**Input:** Çoklu seçim (checkbox benzeri kartlar)  
**Seçenekler:** `Full Body` | `Göğüs` | `Sırt` | `Kollar` | `Bacak` | `Karın`  
**Veri:** `UserProfile.targetMuscles` (List<String>)

### Adım 7 — LevelStep
**Dosya:** `level_step.dart`  
**Input:** Radio button (tek seçim)  
**Seçenekler:**
- `Yeni Başlayan` → max 3 antrenman günü
- `Orta` → max 4 antrenman günü
- `İleri` → max 5 antrenman günü

**Veri:** `UserProfile.level`  
**Kritik:** Sonraki adımdaki seçilebilir gün sayısını sınırlar

### Adım 8 — WorkoutDaysStep
**Dosya:** `workout_days_step.dart`  
**Input:** Gün seçimi (Pazartesi–Pazar, checkbox)  
**Kısıt:** Level'e göre max seçilebilir gün sayısı  
**Veri:** Seçilen günler listesi (API'ye string olarak gönderilir)

### Adım 9 — EnvironmentStep
**Dosya:** `environment_step.dart`  
**Input:** İki büyük kart butonu  
**Seçenekler:** `Ev` | `Spor Salonu`  
**Veri:** `UserProfile.environment`

---

## Onboarding Tamamlama Akışı

```
Adım 9 tamamlandı
  │
  ├── 1. POST /api/save_profile.php
  │       { nickname, gender, age, height, weight, goal,
  │         target_weight, environment, level,
  │         workout_days, target_muscles }
  │       ← { status: 'success', user_id: <int> }
  │
  ├── 2. LocalStorageService.saveUserId(user_id)
  ├── 3. LocalStorageService.saveUserProfile(profile)
  │
  ├── 4. WorkoutGeneratorService.generateProgram(profile)
  │       ← WorkoutProgram
  │
  ├── 5. LocalStorageService.saveWorkoutProgram(program)
  │
  └── 6. Navigator → AnalysisLoadingScreen (4 sn)
              └── Navigator → ProgramResultScreen
                        └── [Onayla] → MainScreen
```

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
- [[06_API]] — save_profile.php detayı
- [[07_İş_Mantığı]] — program seçim kuralları
- [[04_Ekranlar]] — onboarding sonrası ekranlar
