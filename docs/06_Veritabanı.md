---
tags: [veritabani, sqlite, sqflite, şema]
created: 2026-06-11
updated: 2026-06-11
type: database
related: [03_Servisler, 09_Veri_Akışı]
---

# SQLite Veritabanı

> Uygulama backend veya API kullanmaz.  
> Tüm veri cihazda `akilli_antreman.db` SQLite dosyasında saklanır.  
> Erişim: `sqflite ^2.4.2` + `path ^1.9.1`

---

## Genel Bilgi

| Özellik | Değer |
|---------|-------|
| Dosya adı | `akilli_antreman.db` |
| Konum | `getDatabasesPath()` (platforma göre) |
| Tablo sayısı | 2 |
| Oluşturma | İlk açılışta otomatik (`onCreate`) |
| Versiyon | 1 |

---

## Tablo: `users`

Onboarding verisi ve kullanıcı profili.

```sql
CREATE TABLE IF NOT EXISTS users (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  nickname        TEXT NOT NULL,
  gender          TEXT,           -- 'Erkek' | 'Kadın'
  age             INTEGER DEFAULT 25,
  height          REAL DEFAULT 175.0,   -- cm
  weight          REAL DEFAULT 70.0,    -- kg
  goal            TEXT,           -- 'Kilo Ver' | 'Kas Kütlesi Kazan' | 'Formda Kal'
  level           TEXT,           -- 'Yeni Başlayan' | 'Orta' | 'İleri'
  environment     TEXT,           -- 'Ev' | 'Spor Salonu'
  target_muscles  TEXT,           -- virgülle ayrılmış: 'Göğüs,Kollar'
  target_weight   REAL,           -- hedef kilo
  workout_days    TEXT,           -- virgülle ayrılmış: 'Pazartesi,Çarşamba,Cuma'
  program_type    TEXT,           -- 'hiit' | 'upper_body' | 'lower_body' | 'full_body'
  created_at      TEXT DEFAULT (datetime('now'))
);
```

**Örnek satır:**
```
id=1, nickname='Ali', gender='Erkek', age=25, height=175.0, weight=70.0,
goal='Kas Kütlesi Kazan', level='Orta', environment='Spor Salonu',
target_muscles='Göğüs,Kollar', target_weight=75.0,
workout_days='Pazartesi,Çarşamba,Cuma', program_type='upper_body'
```

---

## Tablo: `workout_sessions`

Tamamlanan antrenman kayıtları.

```sql
CREATE TABLE IF NOT EXISTS workout_sessions (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id             INTEGER NOT NULL,
  program_name        TEXT,           -- ekranda gösterilen program adı
  completed_at        TEXT DEFAULT (datetime('now')),
  total_time_seconds  INTEGER DEFAULT 0,
  total_exercises     INTEGER DEFAULT 0,
  total_sets          INTEGER DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

**Örnek satır:**
```
id=1, user_id=1, program_name='Üst Vücut Odaklı Hipertrofi',
completed_at='2026-06-11 14:30:00',
total_time_seconds=2700, total_exercises=5, total_sets=20
```

---

## DatabaseService Metodları ve SQL Karşılıkları

| Metod | İşlem |
|-------|-------|
| `insertUser()` | `INSERT INTO users ...` |
| `getUser(id)` | `SELECT * FROM users WHERE id = ?` |
| `updateWorkoutDays()` | `UPDATE users SET workout_days = ?` |
| `updateWeight()` | `UPDATE users SET weight = ?` |
| `updateGoalAndWeight()` | `UPDATE users SET goal = ?, weight = ?, program_type = ?` |
| `insertSession()` | `INSERT INTO workout_sessions ...` |
| `getHistory()` | `SELECT * FROM workout_sessions WHERE user_id = ? ORDER BY completed_at DESC` |
| `getDashboardData()` | `SELECT * FROM workout_sessions WHERE user_id = ? AND completed_at >= ?` (aylık) |
| `clearAll()` | `DELETE FROM workout_sessions; DELETE FROM users` |

---

## Veri Akışı

```
Onboarding tamamlandı
  → insertUser(profile, days)     → users tablosu
  → savedUserId = dönen id

Antrenman tamamlandı
  → insertSession(userId, ...)    → workout_sessions tablosu

Dashboard açıldı
  → getDashboardData(userId)
       └── users JOIN workout_sessions (bu ay)

Takvim açıldı
  → getScheduleData(userId)
       ├── users tablosundan profil okunur
       ├── workout_sessions bugün var mı? → already_done?
       └── buildFilteredSchedule() çağrılır → egzersiz listesi üretilir

Logout
  → clearAll()                    → iki tablo da temizlenir
  → savedUserId = null
```

---

## Egzersiz Verisi (SQLite Dışı)

Egzersizler **SQLite'ta değil**, Dart sabit listesinde (`kAllExercises`) tutulur.  
Sebep: Egzersiz kataloğu değişmez veriler — DB'ye gerek yok.

Her antrenman başladığında `buildFilteredSchedule()` bu listeden dinamik program üretir.  
GIF dosyaları: `assets/exercises/man/<isim>-man.gif` (yerel bundle)

---

## Bağlantılar

- [[03_Servisler]] — DatabaseService implementasyonu
- [[09_Veri_Akışı]] — DB işlemlerinin akış içindeki yeri
