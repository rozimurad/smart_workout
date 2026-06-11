---
tags: [iş-mantığı, bmi, program-seçimi, egzersiz-filtreleme, kurallar]
created: 2026-06-11
updated: 2026-06-11
type: business-logic
related: [02_Modeller, 03_Servisler, 05_Onboarding]
---

# İş Mantığı

> Uygulamanın temel kuralları ve hesaplama mantığı.  
> Bu sayfa "neden böyle çalışıyor?" sorusunun cevabıdır.

---

## 1. Program Seçim Kuralları

**Sorumlu:** `WorkoutGeneratorService.generateProgram()`  
**Giriş:** `UserProfile.goal` + `UserProfile.gender`

```
goal içeriyor "Kilo Ver" ?
  → HIIT Fat Burn
     programAdi: "Yüksek Yoğunluklu Yağ Yakımı (HIIT)"
     haftalikGunSayisi: 4

goal içeriyor "Kas" VEYA "Hacim" ?
  gender == "Erkek"  → Üst Vücut Odaklı Hipertrofi   (5 gün)
  gender == "Kadın"  → Alt Vücut Odaklı Hipertrofi    (5 gün)

Diğer (Formda Kal):
  → Tüm Vücut (Full Body) Kondisyon                   (3 gün)
```

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

| Aralık | Kategori | Renk | Hex |
|--------|---------|------|-----|
| < 18.5 | Zayıf | Cyan | #00E5FF |
| 18.5 – 24.9 | Normal | Neon Yeşil | #00FF87 |
| 25.0 – 29.9 | Fazla Kilolu | Gold | #FFD700 |
| ≥ 30 | Obez | Coral Kırmızı | #FF3366 |

**Nerede kullanılır:**
- `ProgramResultScreen` — onboarding sonrası önizleme
- `DashboardScreen` — BMI kartı
- `ProfileScreen` — lokal hesaplama
- `buildFilteredSchedule()` — obezite kontrolü (§3)

---

## 3. Egzersiz Filtreleme Kuralları

**Sorumlu:** `buildFilteredSchedule()` — `lib/data/exercise_data.dart`

### 3.1 Ortam Filtresi

```
environment == 'Ev'         → env: 'ev' veya 'hepsi' olan egzersizler
environment == 'Spor Salonu'→ env: 'salon' veya 'hepsi' olan egzersizler
```

### 3.2 Cinsiyet Filtresi

```
gender == 'Erkek' → gender: 'erkek' veya 'hepsi'
gender == 'Kadın' → gender: 'kadin' veya 'hepsi'
```

**Not:** `gender: 'kadin'` olan egzersizler (Reverse Lunge, Glute Bridge, Side Step) erkeklere gösterilmez. `gender: 'erkek'` olan (Barbell Squat) kadınlara gösterilmez.

### 3.3 Obezite Güvenlik Filtresi

```
BMI ≥ 30 ise → high_impact: true olan egzersizler çıkarılır
```

**Yüksek darbeli (çıkarılan) egzersizler:**
| Egzersiz | Neden |
|----------|-------|
| Box Jump | Diz eklemine aşırı yük |
| Squat Jump | Diz + kalça zorlaması |
| Burpees | Tüm vücut yüksek darbe |
| Jumping Jack | Eklem sağlığı riski |
| High Knees | Yüksek hız + darbe |
| Mountain Climber | Yüksek yoğunluk |

### 3.4 Kas Grubu Rotasyonu

```
goal == 'kilo_ver':
  → Kardio rotasyonu (full_body ↔ bacak ↔ karin)
  → Kullanıcının hedef kas seçimi kardiyoda önemsizdir

Diğer (kas_kazan, formda_kal):
  → Sadece seçilen kaslar arasında döner
  → targetMuscles = ['Göğüs', 'Kollar']:
       Gün 1 = Göğüs egzersizleri
       Gün 2 = Kollar egzersizleri
       Gün 3 = Göğüs (döngü devam eder)
```

### 3.5 Randomizasyon

Her takvim yüklemesinde `Random()` (seed'siz) ile egzersiz listesi karıştırılır.  
→ Aynı kullanıcı için her gün farklı egzersiz kombinasyonu çıkar.

---

## 4. Antrenman Günü Limitleri

**Seviyeye göre gün başına egzersiz sayısı:**

| Seviye | Egzersiz/Gün |
|--------|-------------|
| Yeni Başlayan | 4 |
| Orta | 5 |
| İleri | 6 |

**`WorkoutDaysStep`'te max seçilebilir gün:** Kullanıcı onboarding'de istediği kadar gün seçebilir. Kısıtlama egzersiz sayısındadır, gün sayısında değil.

---

## 5. Bugünün Günü Kilidi

**Mantık:** Takvim her zaman tam haftalık gösterilir.  
Yalnızca bugün olan güne "Antrenmanı Başlat" butonu çıkar.

```
schedule → her gün tile'ı gösterilir

tile.dayName == todayDayName ?
  ├── today_state == 'workout_time' → "Antrenmanı Başlat" butonu (yeşil)
  ├── today_state == 'already_done' → "Bugünkü Antrenman Tamamlandı" badge
  └── (rest günü da olabilir — tile görünür ama kilitli)
Diğer günler → 🔒 "Sadece bu gün açılabilir"
```

---

## 6. Hedef Başarısı (Goal Achievement)

**Kontrol yeri:** `ProfileScreen` kilo güncelleme sonrası

```
goal == 'kilo_ver'  AND yeniKilo <= hedefKilo  → 🎉 Kutlama Modal
goal == 'kas_kazan' AND yeniKilo >= hedefKilo  → 🎉 Kutlama Modal

Kutlama Modal:
  Seçenek A: "Yeni Hedef Koy"
    → OnboardingScreen (stack temizlenir, yeni profil)
  Seçenek B: "Formda Kal"
    → DatabaseService.updateGoalAndWeight(id, 'Formda Kal', yeniKilo)
```

**Animasyon:** Lottie (yerel asset: `assets/animations/celebration.json`)

---

## 7. Kimlik Doğrulama Mantığı

```
main.dart başlangıcı:
  DatabaseService.init()
    └── savedUserId = son users tablosundaki id (veya null)

savedUserId != null → MainScreen
savedUserId == null → OnboardingScreen

Logout:
  DatabaseService.clearAll()
    → users + workout_sessions silinir
    → savedUserId = null
    → OnboardingScreen
```

---

## 8. Antrenman Oturumu Mantığı

**WorkoutSessionScreen sırası:**

```
[1] PREP PHASE (10 sn)
    countdown → "Skip" ile atlanabilir

[2] EXERCISE PHASE
    Timer.periodic(1s) → süre sayacı
    "Seti Tamamla" → REST PHASE

[3] REST PHASE (goal + level'e göre 20–90 sn)
    countdown → "Skip" ile atlanabilir
    Son set → sonraki egzersize geç

[4] Tüm egzersizler bitti → COMPLETE
    DatabaseService.insertSession(userId, programName, time, exercises, sets)
    Modal → "Tebrikler!" → MainScreen
```

**Dispose:** `dispose()` tüm Timer'ları iptal eder, memory leak önlenir.

---

## Bağlantılar

- [[02_Modeller]] — kullanılan model alanları
- [[03_Servisler]] — servis implementasyonları
- [[06_Veritabanı]] — SQLite tablo ve sorgu detayları
- [[04_Ekranlar]] — kuralların uygulandığı ekranlar
