---
tags: [iş-mantığı, bmi, program-seçimi, kurallar]
created: 2026-06-11
type: business-logic
related: [02_Modeller, 03_Servisler, 05_Onboarding]
---

# İş Mantığı

> Uygulamanın temel kuralları ve hesaplama mantığı.  
> Bu sayfa gelecekteki bir LLM için referans — "neden böyle çalışıyor" sorusunun cevabı burada.

---

## 1. Program Seçim Kuralları

**Sorumlu:** `WorkoutGeneratorService.generateProgram()`  
**Giriş:** `UserProfile.goal` + `UserProfile.gender`

```
goal içeriyor "Kilo Ver"?
  → HIIT Fat Burn
     programAdi: "Yüksek Yoğunluklu Yağ Yakımı (HIIT)"
     haftalikGunSayisi: 4
     hedefKategori: "Yağ Yakımı"

goal içeriyor "Kas" VEYA "Hacim"?
  gender == "Erkek"?
    → Üst Vücut
       programAdi: "Üst Vücut Odaklı Hipertrofi"
       haftalikGunSayisi: 5
       hedefKategori: "Kas Kütlesi"
  gender == "Kadın"?
    → Alt Vücut
       programAdi: "Alt Vücut Odaklı Hipertrofi"
       haftalikGunSayisi: 5
       hedefKategori: "Kas Kütlesi"

Diğer (Formda Kal):
  → Full Body
     programAdi: "Tüm Vücut (Full Body) Kondisyon"
     haftalikGunSayisi: 3
     hedefKategori: "Kondisyon"
```

**Tablo:**

| Hedef | Cinsiyet | Program | Gün/Hafta |
|-------|---------|---------|-----------|
| Kilo Ver | — | HIIT Fat Burn | 4 |
| Kas Kazan | Erkek | Üst Vücut Hipertrofi | 5 |
| Kas Kazan | Kadın | Alt Vücut Hipertrofi | 5 |
| Formda Kal | — | Full Body Kondisyon | 3 |

---

## 2. BMI Hesaplama

**Formül:**
```
BMI = weight_kg / (height_m)²
Örn: 70 / (1.75)² = 22.86
```

**Sınıflandırma:**

| Aralık | Kategori (TR) | Renk | Hex |
|--------|--------------|------|-----|
| < 18.5 | Zayıf | Cyan | #00E5FF |
| 18.5 – 24.9 | Normal | Neon Yeşil | #00FF87 |
| 25.0 – 29.9 | Fazla Kilolu | Gold | #FFD700 |
| ≥ 30 | Obez | Coral Kırmızı | #FF3366 |

**Nerede kullanılır:**
- `ProgramResultScreen` — onboarding sonrası önizleme
- `DashboardScreen` — BMI kartı (API'den gelir)
- `ProfileScreen` — lokal hesaplama

---

## 3. Antrenman Günü Limitleri

**Seviyeye göre maksimum antrenman günü:**

| Seviye | Max Gün |
|--------|---------|
| Yeni Başlayan | 3 |
| Orta | 4 |
| İleri | 5 |

**Uygulama:** `WorkoutDaysStep` widget'ında checkbox disable edilir.  
**Neden:** Aşırı antrenman (overtraining) önlemek için.

---

## 4. Hedef Başarısı (Goal Achievement)

**Kontrol yeri:** `ProfileScreen.update_weight()` sonrası  
**Mantık:**

```
Kullanıcı kilo güncelledi
  │
  ├── goal == 'kilo_ver' AND yeni_kilo <= hedef_kilo
  │     → 🎉 Kutlama Modal'ı göster
  │
  └── goal == 'kas_kazan' AND yeni_kilo >= hedef_kilo
        → 🎉 Kutlama Modal'ı göster

Kutlama Modal'ı:
  ├── Seçenek A: "Yeni Hedef Koy"
  │     → OnboardingScreen'e geri dön (stack temizlenir)
  │
  └── Seçenek B: "Formda Kal"
        → POST /update_goal_and_weight.php
              body: { goal: "formda_kal", weight: ... }
```

**Animasyon:** Lottie (network URL'den) — konfeti/kutlama efekti

---

## 5. Kimlik Doğrulama Mantığı

```
main.dart başlangıcı:
  LocalStorageService.getSavedUserId()
    ├── null → OnboardingScreen (yeni kullanıcı)
    └── !null → MainScreen (kayıtlı kullanıcı)

Logout:
  LocalStorageService.clearAll() → OnboardingScreen

Kayıt:
  POST /save_profile.php → user_id → SP'ye kaydet
```

**Önemli:** Server-side session yok. user_id kaybedilirse (uygulama silme) kullanıcı yeniden kayıt yapmalı.

---

## 6. Antrenman Oturumu Mantığı

**WorkoutSessionScreen sırası:**

```
[1] PREP PHASE (10 sn)
    Timer.periodic(1s) → countdown
    "Skip" → anında egzersize geç

[2] EXERCISE PHASE
    Timer.periodic(1s) → süre sayacı
    Set bitince → REST PHASE

[3] REST PHASE (60 sn, ayarlanabilir)
    Timer.periodic(1s) → countdown
    "Skip" → anında sonraki set/egzersiz

[4] Tüm setler/egzersizler bitti → COMPLETE
    POST /complete_workout.php
    Modal → "Tebrikler!" → MainScreen
```

**Dispose:** `WorkoutSessionScreen.dispose()` tüm Timer'ları iptal eder.

---

## 7. Takvim Günü Durumları

**`get_workout.php` `today_state` alanı:**

| Değer | Anlam | Kullanıcıya gösterilen |
|-------|-------|----------------------|
| `workout_time` | Bugün antrenman günü | Takvim + "Başlat" butonu |
| `already_done` | Bugün zaten yapıldı | "Bugünlük Bu Kadar! 🎉" |
| `rest` | Dinlenme günü | "Dinlenme Günü ☕" |

---

## Bağlantılar

- [[02_Modeller]] — kullanılan model alanları
- [[03_Servisler]] — WorkoutGeneratorService implementasyonu
- [[06_API]] — API endpoint request/response formatları
- [[04_Ekranlar]] — kuralların uygulandığı ekranlar
