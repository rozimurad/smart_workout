---
tags: [ekranlar, ui, flutter-screens]
created: 2026-06-11
type: screens
related: [01_Mimari, 05_Onboarding, 06_API, 09_Veri_Akışı]
---

# Ekranlar

> `lib/screens/` altındaki tüm ekranlar. Onboarding için bkz. [[05_Onboarding]].

---

## Ekran Haritası

```
main.dart (routing)
  ├── '/' → OnboardingScreen (→ [[05_Onboarding]])
  └── '/main' → MainScreen
                  ├── Tab 0: DashboardScreen
                  ├── Tab 1: ProfileScreen
                  └── Tab 2: HistoryScreen

DashboardScreen → WorkoutScheduleScreen
                    └── WorkoutSessionScreen

OnboardingScreen → AnalysisLoadingScreen → ProgramResultScreen → MainScreen
```

---

## main_screen.dart

**Rol:** Bottom navigation bar container  
**Yapı:** `IndexedStack` (3 tab — state korunur)

```
Tab 0: 🏠 Dashboard
Tab 1: 👤 Profil
Tab 2: 📋 Geçmiş
```

**Neden IndexedStack?** Tab değişince widget dispose edilmez, state korunur.

---

## dashboard_screen.dart

**API:** `GET /api/get_progress.php?user_id=<id>`

**İçerik:**
- Hoşgeldin mesajı (kullanıcı adıyla)
- **Aylık İlerleme Kartı**
  - Tamamlanma yüzdesi (progress bar)
  - Toplam süre (dakika), set sayısı, egzersiz sayısı
  - Tamamlanan antrenman / aylık hedef
- **BMI Analiz Kartı** — VKİ değeri + renk kodlu durum rozeti
- **Aktif Program Kartı** — program adı, açıklama, kategori
- "Antrenman Takvimini Aç" butonu → WorkoutScheduleScreen
- Logout butonu → `LocalStorageService.clearAll()` → OnboardingScreen

---

## profile_screen.dart

**API'ler:**
- `GET /api/get_profile.php?user_id=<id>`
- `POST /api/update_workout_days.php`
- `POST /api/update_weight.php`
- `POST /api/update_goal_and_weight.php` (hedef başarısı sonrası)

**İçerik:**
- Kullanıcı avatar'ı (baş harflerle)
- Program adı ve açıklaması
- 2×3 metrik grid: Boy, Kilo, Yaş, Hedef, Seviye, Ortam
- "Antrenman Günlerimi Değiştir" → bottom sheet (checkbox günler)
- "Güncel Kilo Gir" → bottom sheet (slider + kaydet)

**Hedef Başarısı Mantığı:**
```
Kilo Ver + yeni_kilo <= hedef_kilo → 🎉 modal
Kas Kazan + yeni_kilo >= hedef_kilo → 🎉 modal
  → Seçenek: Yeni hedef koy | Formda kal
```

**Lottie Animasyon:** Kutlama modal'ında oynatılır (network URL'den)

---

## history_screen.dart

**API:** `GET /api/get_history.php?user_id=<id>`

**İçerik:**
- Tamamlanan antrenmanlar listesi (en yeni önce)
- Her öğede:
  - Program adı
  - Tarih (DD/MM/YYYY formatı)
  - Süre (dakika)
  - Set ve egzersiz sayısı
  - Renk kodlu rozetler

---

## workout_schedule_screen.dart

**API:** `GET /api/get_workout.php?user_id=<id>`

**Response'daki `today_state` değerleri:**

| today_state | Gösterilen |
|-------------|-----------|
| `workout_time` | Normal takvim + "Antrenmanı Başlat" butonu |
| `already_done` | "Bugünlük Bu Kadar! 🎉" mesajı |
| `rest` | "Dinlenme Günü ☕" mesajı |

**İçerik:**
- Haftalık takvim (genişletilebilir gün kartları)
- Her günde egzersiz listesi: `isim × set × tekrar`
- Aktif güne ait "Antrenmanı Başlat" → WorkoutSessionScreen

---

## workout_session_screen.dart

**Rol:** Aktif antrenman yöneticisi  
**API (tamamlama):** `POST /api/complete_workout.php`

### Aşamalar

```
1. HAZIRLIK (10 saniye geri sayım)
   └── "Skip" butonu ile atlanabilir

2. AKTİF EGZERSİZ
   ├── Egzersiz adı + GIF (network'ten)
   ├── Timer (saniye sayacı)
   ├── Set sayacı (animasyonlu progress)
   └── Pause/Resume

3. DİNLENME (60 saniye, ayarlanabilir)
   ├── Geri sayım
   ├── "Skip" butonu
   └── Sonraki set/egzersiz'e geç

4. TAMAMLAMA
   ├── POST /complete_workout.php
   ├── Başarı modal'ı
   └── MainScreen'e dön
```

**State Yönetimi:** Timer'lar `Timer.periodic` ile, dispose'da iptal edilir.

---

## analysis_loading_screen.dart

**Rol:** Onboarding → ProgramResultScreen arası 4 saniyelik animasyon  
**Otomatik geçiş:** 4 saniye sonra ProgramResultScreen'e push

**Mesajlar (ilerlemeye göre):**
```
%0–35:   "Fiziksel verileriniz analiz ediliyor..."
%35–70:  "BMI ve metabolizma hızı hesaplanıyor..."
%70–100: "Hedefinize en uygun şablon oluşturuluyor..."
```

---

## program_result_screen.dart

**Rol:** Onboarding sonunda üretilen programı önizleme + onaylama

**İçerik:**
- BMI kartı (görsel ölçek, değer, kategori)
- Program adı, açıklama, istatistikler
- Haftalık takvim grid'i (seçilen günler renkli)
- "Programı Onayla ve Kaydet" → MainScreen

---

## Bağlantılar

- [[05_Onboarding]] — 9 adımlı kayıt ekranı
- [[06_API]] — her ekranın kullandığı endpoint'ler
- [[07_İş_Mantığı]] — hedef başarısı ve program kuralları
- [[08_Tasarım_Sistemi]] — renk ve UI kararları
- [[09_Veri_Akışı]] — ekranlar arası navigasyon akışı
