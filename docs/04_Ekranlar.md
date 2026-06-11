---
tags: [ekranlar, ui, flutter-screens]
created: 2026-06-11
updated: 2026-06-11
type: screens
related: [01_Mimari, 05_Onboarding, 06_Veritabanı, 09_Veri_Akışı]
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

**Veri:** `DatabaseService.getDashboardData(userId)` — SQLite (users + workout_sessions)

**İçerik:**
- Hoşgeldin mesajı (kullanıcı adıyla)
- **Aylık İlerleme Kartı**
  - Tamamlanma yüzdesi (progress bar)
  - Toplam süre (dakika), set sayısı, egzersiz sayısı
  - Tamamlanan antrenman / aylık hedef
- **BMI Analiz Kartı** — VKİ değeri + renk kodlu durum rozeti
- **Aktif Program Kartı** — program adı, açıklama, kategori
- "Antrenman Takvimini Aç" butonu → WorkoutScheduleScreen
- Logout butonu → `DatabaseService.clearAll()` → OnboardingScreen

---

## profile_screen.dart

**Veri:** `DatabaseService.getUser(userId)` — SQLite users tablosu

**İçerik:**
- Kullanıcı avatar'ı (baş harflerle)
- Program adı ve açıklaması
- 2×3 metrik grid: Boy, Kilo, Yaş, Hedef, Seviye, Ortam
- "Antrenman Günlerimi Değiştir" → bottom sheet → `updateWorkoutDays()`
- "Güncel Kilo Gir" → bottom sheet → `updateWeight()`

**Hedef Başarısı Mantığı:**
```
Kilo Ver + yeni_kilo <= hedef_kilo  → 🎉 Kutlama Modal
Kas Kazan + yeni_kilo >= hedef_kilo → 🎉 Kutlama Modal
  Seçenek A: Yeni hedef koy → OnboardingScreen
  Seçenek B: Formda kal     → DatabaseService.updateGoalAndWeight()
```

**Lottie Animasyon:** `assets/animations/celebration.json` (yerel asset)

---

## history_screen.dart

**Veri:** `DatabaseService.getHistory(userId)` — SQLite workout_sessions tablosu

**İçerik:**
- Tamamlanan antrenmanlar listesi (en yeni önce)
- Her öğede: program adı, tarih, süre (dakika), set ve egzersiz sayısı, renk kodlu rozetler

---

## workout_schedule_screen.dart

**Veri:** `DatabaseService.getScheduleData(userId)`  
→ İçeride `buildFilteredSchedule()` çağrılır — egzersiz kataloğundan dinamik üretim

**`today_state` davranışları:**

| today_state | Gösterilen |
|-------------|-----------|
| `workout_time` | Bugüne "Antrenmanı Başlat" butonu aktif |
| `already_done` | Bugüne "Tamamlandı" badge'i |
| `rest` | Status banner: "Dinlenme Günü ☕" |

**İçerik (tüm durumlarda tam takvim gösterilir):**
- Haftalık program (genişletilebilir gün kartları) — **her zaman görünür**
- Bugünkü gün: yeşil badge + "Bugün" etiketi
- Diğer günler: 🔒 simgesi + "Sadece bu gün açılabilir"
- Her günde egzersiz listesi: isim × set × tekrar
- Bugünkü güne "Antrenmanı Başlat" → WorkoutSessionScreen

---

## workout_session_screen.dart

**Rol:** Aktif antrenman yöneticisi  
**Tamamlama:** `DatabaseService.insertSession(...)` — SQLite workout_sessions tablosu

**Parametre:** `exercisesRaw` (List\<dynamic\>) + `programName` (String)

### Aşamalar

```
1. HAZIRLIK (10 saniye geri sayım)
   └── "Skip" butonu ile atlanabilir

2. AKTİF EGZERSİZ
   ├── Egzersiz adı + GIF (yerel asset: assets/exercises/man/)
   ├── Timer (saniye sayacı)
   ├── Set sayacı (animasyonlu progress)
   └── Pause/Resume

3. DİNLENME (20–90 saniye — goal+level'e göre)
   ├── Geri sayım
   ├── "Skip" butonu
   └── Sonraki set/egzersiz'e geç

4. TAMAMLAMA
   ├── DatabaseService.insertSession(userId, ...)
   ├── Başarı modal'ı
   └── MainScreen'e dön
```

**GIF gösterimi:** `Image.asset(imagePath, fit: BoxFit.contain)` — hata durumunda placeholder.

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
**Not:** Veriler zaten SQLite'a yazılmıştır (insertUser çağrıldı). Bu ekran sadece gösterim yapar.

**İçerik:**
- BMI kartı (görsel ölçek, değer, kategori)
- Program adı, açıklama, istatistikler
- Haftalık takvim grid'i (seçilen günler renkli)
- "Programı Onayla ve Başla" → MainScreen

---

## Bağlantılar

- [[05_Onboarding]] — 9 adımlı kayıt ekranı
- [[06_Veritabanı]] — her ekranın kullandığı tablo/metod
- [[07_İş_Mantığı]] — hedef başarısı ve program kuralları
- [[08_Tasarım_Sistemi]] — renk ve UI kararları
- [[09_Veri_Akışı]] — ekranlar arası navigasyon akışı
