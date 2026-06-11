---
tags: [api, php, backend, endpoints]
created: 2026-06-11
type: api-reference
related: [04_Ekranlar, 05_Onboarding, 09_Veri_Akışı]
---

# API Referansı

> Backend: PHP REST API  
> Base URL (geliştirme): `http://192.168.1.23/api/`  
> Protokol: HTTP (HTTPS yok — geliştirme ortamı)  
> Format: JSON (Content-Type: application/json; charset=UTF-8)  
> Timeout: 10 saniye

---

## Genel Notlar

- Auth yok — user_id ile kimlik belirlenir
- user_id URL param veya JSON body'de düz metin geçer
- Tüm istekler Flutter `http` paketi ile yapılır
- Hata durumunda SnackBar + retry seçeneği gösterilir

---

## Endpoint Listesi

### POST /save_profile.php

**Kullanım:** Onboarding tamamlandığında kullanıcı oluştur  
**Çağıran:** `OnboardingScreen`

**Request:**
```json
{
  "nickname": "Ali",
  "gender": "Erkek",
  "age": 25,
  "height": 175.0,
  "weight": 70.0,
  "goal": "Kilo Ver",
  "target_weight": 65.0,
  "environment": "Spor Salonu",
  "level": "Orta",
  "workout_days": "Pazartesi,Çarşamba,Cuma",
  "target_muscles": ["Göğüs", "Karın"]
}
```

**Response (success):**
```json
{
  "status": "success",
  "user_id": 42
}
```

---

### GET /get_progress.php

**Kullanım:** Dashboard için aylık istatistik  
**Çağıran:** `DashboardScreen`

**Query:** `?user_id=42`

**Response:**
```json
{
  "progress_percentage": 65,
  "monthly_time_minutes": 180,
  "monthly_sets": 84,
  "monthly_exercises": 42,
  "completed_workouts": 8,
  "monthly_target": 12,
  "user_name": "Ali",
  "bmi_value": 22.86,
  "bmi_status": "Normal"
}
```

---

### GET /get_profile.php

**Kullanım:** Profil ekranı için detaylı kullanıcı verisi  
**Çağıran:** `ProfileScreen`

**Query:** `?user_id=42`

**Response:**
```json
{
  "status": "success",
  "profile": {
    "nickname": "Ali",
    "gender": "Erkek",
    "age": 25,
    "height": 175.0,
    "weight": 70.0,
    "goal": "Kilo Ver",
    "level": "Orta",
    "environment": "Spor Salonu",
    "target_weight": 65.0,
    "target_muscles": ["Göğüs"]
  },
  "assigned_program": "HIIT Fat Burn"
}
```

---

### GET /get_history.php

**Kullanım:** Geçmiş antrenmanlar listesi  
**Çağıran:** `HistoryScreen`

**Query:** `?user_id=42`

**Response:**
```json
{
  "status": "success",
  "history": [
    {
      "program_name": "HIIT Fat Burn",
      "completed_at": "2026-06-10 09:30:00",
      "total_time_spent": 45,
      "total_sets": 18,
      "total_exercises": 6
    }
  ]
}
```

---

### GET /get_workout.php

**Kullanım:** Haftalık antrenman takvimi  
**Çağıran:** `WorkoutScheduleScreen`

**Query:** `?user_id=42`

**Response:**
```json
{
  "status": "success",
  "today_state": "workout_time",
  "message": "Bugün antrenman günün!",
  "program_id": 1,
  "program_title": "HIIT Fat Burn",
  "schedule": {
    "Gün 1": [
      {
        "name": "Burpee",
        "gifUrl": "http://...",
        "sets": 3,
        "reps": 15
      }
    ],
    "Gün 2": [...]
  }
}
```

**today_state değerleri:**
- `workout_time` → Bugün antrenman günü
- `already_done` → Bugün zaten tamamlandı
- `rest` → Bugün dinlenme günü

---

### POST /complete_workout.php

**Kullanım:** Antrenman tamamlandığında kayıt  
**Çağıran:** `WorkoutSessionScreen`

**Request:**
```json
{
  "user_id": 42,
  "program_id": 1,
  "total_time": 2700,
  "total_exercises": 6,
  "total_sets": 18
}
```

**Response:**
```json
{
  "status": "success"
}
```

---

### POST /update_workout_days.php

**Kullanım:** Profil ekranından antrenman günlerini değiştir  
**Çağıran:** `ProfileScreen`

**Request:**
```json
{
  "user_id": 42,
  "workout_days": "Salı,Perşembe,Cumartesi"
}
```

---

### POST /update_weight.php

**Kullanım:** Güncel kilo güncelleme  
**Çağıran:** `ProfileScreen`

**Request:**
```json
{
  "user_id": 42,
  "weight": "68.5"
}
```

---

### POST /update_goal_and_weight.php

**Kullanım:** Hedef başarısı sonrası yeni hedef veya formda kal  
**Çağıran:** `ProfileScreen`

**Request:**
```json
{
  "user_id": 42,
  "goal": "formda_kal",
  "weight": "65.0"
}
```

---

## HTTP Client Pattern (Flutter)

```dart
final uri = Uri.parse('$baseUrl/endpoint.php');
final response = await http.post(
  uri,
  headers: {'Content-Type': 'application/json; charset=UTF-8'},
  body: jsonEncode(data),
).timeout(Duration(seconds: 10));

if (response.statusCode == 200) {
  final json = jsonDecode(response.body);
  // işle
} else {
  // hata göster
}
```

---

## Geliştirme Notları

- Base URL `192.168.1.23` hardcoded → production için env variable veya config gerekir
- HTTPS eklenmeli
- user_id'ye ek olarak session token gerekebilir
- Endpoint'ler için OpenAPI spec yok

---

## Bağlantılar

- [[04_Ekranlar]] — hangi ekran hangi endpoint'i çağırır
- [[05_Onboarding]] — save_profile akışı
- [[09_Veri_Akışı]] — API çağrıları akış içinde nerede
