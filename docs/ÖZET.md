---
tags: [özet, smart_workout, flutter, fitness]
created: 2026-06-11
type: summary
related: [01_Mimari, 06_API, 07_İş_Mantığı]
---

# Akıllı Antrenman — Proje Özeti

> Türkçe, AI destekli, kişiselleştirilmiş antrenman programı oluşturan Flutter mobil uygulaması.  
> Backend: PHP REST API · Frontend: Flutter/Dart · Depolama: SharedPreferences + API DB

---

## Ne Yapıyor?

Kullanıcı **9 adımlı onboarding** tamamlar → fiziksel ölçüler + hedef toplanır → **BMI hesaplanır + program üretilir** → haftalık antrenman takvimi sunulur → kullanıcı her gün antrenmana başlar, timer/set takibi yapılır → tamamlanan antrenman API'ye kaydedilir → aylık ilerleme dashboard'da gösterilir.

---

## Kullanıcı Yolculuğu (Happy Path)

```
İlk Açılış
  └──► OnboardingScreen (9 adım)
         ├── Nickname → Cinsiyet → Boy/Kilo/Yaş
         ├── Hedef (Kilo Ver / Kas Kazan / Formda Kal)
         ├── Hedef Kilo → Hedef Kaslar → Seviye → Günler → Ortam
         └── POST /save_profile.php → user_id alınır
                └──► AnalysisLoadingScreen (4 sn animasyon)
                       └──► ProgramResultScreen (BMI + program önizleme)
                              └──► MainScreen (bottom nav)

MainScreen (kalıcı)
  ├── Dashboard: aylık istatistik + BMI + program özeti
  ├── Profile: metrikleri güncelle (kilo/günler)
  └── History: geçmiş antrenmanlar

WorkoutScheduleScreen (takvim)
  └──► WorkoutSessionScreen (aktif antrenman)
         ├── 10sn hazırlık → egzersiz timer → dinlenme timer
         └── POST /complete_workout.php → kayıt
```

---

## Teknik Yığın

| Katman | Teknoloji | Notlar |
|--------|-----------|--------|
| UI Framework | Flutter (Material 3) | Dark tema, neon yeşil accent |
| Dil | Dart ^3.11.3 | |
| State | `setState` | Provider/BLoC kullanılmamış |
| Local Storage | SharedPreferences | user_id + profil cache |
| HTTP | `http` paketi | JSON REST API |
| Animasyon | Lottie + AnimatedContainer | Kutlama + geçişler |
| Backend | PHP (192.168.1.23) | Geliştirme ortamı, HTTP |
| Auth | user_id (no JWT/token) | Basit, geliştirme fazı |

---

## Klasör Haritası (Özet)

```
lib/
├── main.dart              → giriş + routing
├── models/                → 3 model (UserProfile, WorkoutProgram, WorkoutExercise)
├── services/              → 2 servis (LocalStorage, WorkoutGenerator)
└── screens/
    ├── main_screen.dart   → bottom nav container
    ├── dashboard_screen.dart
    ├── profile_screen.dart
    ├── history_screen.dart
    ├── workout_schedule_screen.dart
    ├── workout_session_screen.dart
    ├── analysis_loading_screen.dart
    ├── program_result_screen.dart
    └── onboarding/
        ├── onboarding_screen.dart
        └── widgets/       → 9 adım widget'ı
```

---

## Kritik İş Kuralları

1. **Program seçimi** → `goal + gender` kombinasyonuna göre 3 seçenek (bkz. [[07_İş_Mantığı]])
2. **Günlük limit** → Seviyeye göre: Başlangıç 3 gün, Orta 4, İleri 5
3. **Hedef başarısı** → Kilo hedefine ulaşınca kutlama modal'ı + yeni hedef seçimi
4. **BMI sınıflandırması** → 4 kategori, renk kodlu (bkz. [[07_İş_Mantığı]])
5. **Logout** → Sadece local veri silinir, API'de session yok

---

## Güçlü Yönler

- Temiz, tutarlı dark UI tasarımı
- İyi organize edilmiş dosya yapısı
- Kapsamlı onboarding (9 adım, kişiselleştirme derinliği)
- Aktif antrenman ekranı (timer, set sayacı, GIF) iyi düşünülmüş

## Dikkat Edilmesi Gerekenler

- Backend IP hardcoded (`192.168.1.23`) — prod için değişmeli
- HTTP kullanıyor, HTTPS yok
- user_id URL'de düz metin — güvenlik riski
- SharedPreferences encrypt edilmemiş
- State management büyüdükçe yönetilemez hale gelebilir
- Network istekleri cache'lenmiyor (her ekran açılışında fetch)

---

## Bağlantılar

- Mimari detay: [[01_Mimari]]
- Veri modelleri: [[02_Modeller]]
- Servisler: [[03_Servisler]]
- Ekranlar: [[04_Ekranlar]]
- Onboarding akışı: [[05_Onboarding]]
- API endpoint listesi: [[06_API]]
- İş mantığı kuralları: [[07_İş_Mantığı]]
- Tasarım sistemi: [[08_Tasarım_Sistemi]]
- Veri akışı diyagramı: [[09_Veri_Akışı]]
