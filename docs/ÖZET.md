---
tags: [özet, smart_workout, flutter, fitness]
created: 2026-06-11
updated: 2026-06-11
type: summary
related: [01_Mimari, 06_Veritabanı, 07_İş_Mantığı]
---

# Akıllı Antrenman — Proje Özeti

> Türkçe, kişiselleştirilmiş antrenman programı oluşturan Flutter mobil uygulaması.  
> **Tamamen yerel:** PHP/API yok, SharedPreferences yok — sadece Dart, Flutter, SQLite.

---

## Ne Yapıyor?

Kullanıcı **9 adımlı onboarding** tamamlar → fiziksel ölçüler + hedef + tercihler toplanır → **BMI hesaplanır + program adı üretilir** → SQLite'a kaydedilir → haftalık antrenman takvimi gösterilir → **yalnızca bugünün antrenmanı başlatılabilir** → tamamlanan antrenman SQLite'a yazılır → aylık ilerleme dashboard'da gösterilir.

---

## Kullanıcı Yolculuğu (Happy Path)

```
İlk Açılış
  └──► OnboardingScreen (9 adım)
         ├── Nickname → Cinsiyet → Boy/Kilo/Yaş
         ├── Hedef → Hedef Kilo → Hedef Kaslar
         ├── Seviye → Günler → Ortam
         └── DatabaseService.insertUser() → user_id SQLite'a yazılır
                └──► AnalysisLoadingScreen (4 sn animasyon)
                       └──► ProgramResultScreen (BMI + program önizleme)
                              └──► MainScreen (bottom nav)

MainScreen (kalıcı)
  ├── Dashboard: aylık istatistik + BMI + program özeti
  ├── Profile:  metrikleri güncelle (kilo / günler / hedef)
  └── History:  geçmiş antrenmanlar

WorkoutScheduleScreen
  ├── Tam haftalık takvim her zaman görünür
  ├── Bugünkü gün yeşil badge + "Başlat" butonu
  └── Diğer günler kilitli (🔒)
       └──► WorkoutSessionScreen (aktif antrenman)
              ├── 10 sn hazırlık → egzersiz timer → dinlenme timer
              └── DatabaseService.insertSession() → SQLite'a yaz
```

---

## Teknik Yığın

| Katman | Teknoloji | Notlar |
|--------|-----------|--------|
| UI Framework | Flutter (Material 3) | Dark tema, neon yeşil accent |
| Dil | Dart ^3.11.3 | |
| State | `setState` | Provider/BLoC kullanılmamış |
| Depolama | SQLite (sqflite ^2.4.2) | Tek DB, 2 tablo |
| Egzersiz Verisi | Dart sabit listesi | `lib/data/exercise_data.dart` |
| Animasyon | Lottie ^3.3.3 | Yerel asset (kutlama) |
| GIF'ler | Yerel asset | `assets/exercises/man/` |
| Backend | **Yok** | Tamamen offline |

---

## Klasör Haritası (Özet)

```
lib/
├── main.dart                    → giriş + routing
├── data/
│   └── exercise_data.dart       → 38 egzersiz kataloğu + buildFilteredSchedule()
├── models/                      → 3 model
├── services/
│   ├── database_service.dart    → SQLite CRUD + program üretme
│   └── workout_generator_service.dart → BMI + program adı
└── screens/
    ├── main_screen.dart
    ├── dashboard_screen.dart
    ├── profile_screen.dart
    ├── history_screen.dart
    ├── workout_schedule_screen.dart
    ├── workout_session_screen.dart
    ├── analysis_loading_screen.dart
    ├── program_result_screen.dart
    └── onboarding/
        ├── onboarding_screen.dart
        └── widgets/              → 9 adım widget'ı

assets/
├── animations/                  → Lottie JSON (celebration.json)
└── exercises/
    └── man/                     → 34+ GIF dosyası
```

---

## Kritik İş Kuralları

1. **Egzersiz filtreleme** → cinsiyet + ortam (ev/salon) + hedef kas + obezite kontrolü
2. **Obezite güvenliği** → BMI ≥ 30 ise Box Jump, Burpees, Jumping Jack gibi yüksek darbeli egzersizler kaldırılır
3. **Günlük kilit** → sadece bugünün antrenmanı başlatılabilir, diğer günler 🔒
4. **Egzersiz rastgeleliği** → her takvim yüklemesinde farklı egzersiz kombinasyonu
5. **Hedef başarısı** → kilo hedefine ulaşınca kutlama modal'ı
6. **Logout** → DatabaseService.clearAll() → SQLite tamamen temizlenir

---

## Güçlü Yönler

- Tamamen offline çalışır (internet bağlantısı gerektirmez)
- Temiz, tutarlı dark UI tasarımı
- Kapsamlı egzersiz filtreleme (cinsiyet, ortam, kas grubu, obezite)
- Aktif antrenman ekranı (timer, set sayacı, GIF) iyi düşünülmüş
- Tek veritabanı dosyası — kurulum gerektirmez

---

## Bağlantılar

- Mimari detay: [[01_Mimari]]
- Veri modelleri: [[02_Modeller]]
- Servisler: [[03_Servisler]]
- Ekranlar: [[04_Ekranlar]]
- Onboarding akışı: [[05_Onboarding]]
- SQLite şema: [[06_Veritabanı]]
- İş mantığı kuralları: [[07_İş_Mantığı]]
- Tasarım sistemi: [[08_Tasarım_Sistemi]]
- Veri akışı diyagramı: [[09_Veri_Akışı]]
