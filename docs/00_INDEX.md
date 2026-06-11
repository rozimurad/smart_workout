---
tags: [index, vault-root, smart_workout]
created: 2026-06-11
type: index
---

# Smart Workout — Vault Index

> **Akıllı Antrenman** Flutter uygulamasının tam dokümantasyon vault'u.  
> Bu dizin, tüm dosyalara giriş noktasıdır. Obsidian'da açıldığında `[[link]]` bağlantıları otomatik çözülür.

---

## Başlangıç Noktaları

| Dosya | Ne İçin |
|-------|---------|
| [[ÖZET]] | Projenin 5 dakikalık genel özeti |
| [[01_Mimari]] | Stack, klasör yapısı, bileşen haritası |
| [[09_Veri_Akışı]] | Veri nasıl akar — uçtan uca |

---

## Tüm Dosyalar

```
docs/
├── 00_INDEX.md          ← buradasın
├── ÖZET.md              ← üst düzey özet
├── 01_Mimari.md         ← mimari + klasör yapısı
├── 02_Modeller.md       ← UserProfile, WorkoutProgram, WorkoutExercise
├── 03_Servisler.md      ← LocalStorageService, WorkoutGeneratorService
├── 04_Ekranlar.md       ← tüm ekranlar
├── 05_Onboarding.md     ← 9 adımlı kayıt akışı
├── 06_API.md            ← tüm PHP endpoint'leri
├── 07_İş_Mantığı.md     ← BMI, program seçimi, goal achievement
├── 08_Tasarım_Sistemi.md← renkler, tipografi, animasyonlar
└── 09_Veri_Akışı.md     ← state + navigation akışı
```

---

## Hızlı Referans

- **App Adı:** Akıllı Antrenman (`akilli_antreman`)
- **Platform:** Flutter 3.x · Dart SDK ^3.11.3
- **Dil:** Türkçe (hardcoded, i18n yok)
- **Backend:** PHP API → `http://192.168.1.23/api/`
- **Local Storage:** SharedPreferences (SQLite/Hive yok)
- **State Management:** `setState` (Provider/BLoC yok)
- **Tema:** Material 3 Dark · Primary `#00FF87` Neon Yeşil

---

## Graf Bağlantıları

```
ÖZET
 ├── 01_Mimari
 │    ├── 02_Modeller
 │    ├── 03_Servisler
 │    └── 04_Ekranlar
 │         └── 05_Onboarding
 ├── 06_API
 ├── 07_İş_Mantığı
 │    ├── 02_Modeller
 │    └── 03_Servisler
 ├── 08_Tasarım_Sistemi
 └── 09_Veri_Akışı
      ├── 06_API
      └── 04_Ekranlar
```
