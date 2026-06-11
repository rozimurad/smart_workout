---
tags: [tasarım, ui, renkler, tipografi, animasyon]
created: 2026-06-11
type: design-system
related: [04_Ekranlar, 01_Mimari]
---

# Tasarım Sistemi

> Uygulamanın görsel dili: renkler, tipografi, spacing, animasyonlar.  
> Tüm değerler `main.dart` içindeki `ThemeData` ve screen dosyalarından çıkarılmıştır.

---

## Renk Paleti

### Ana Renkler

| Rol | Renk | Hex | Kullanım |
|-----|------|-----|---------|
| Primary | Neon Yeşil | `#00FF87` | Butonlar, aktif state, vurgu |
| Secondary | İndigo | `#6366F1` | İkincil aksanlar |
| Background | Obsidian | `#0B0F19` | Ekran arka planı |
| Surface | Koyu Obsidian | `#161F30` | Kart arka planları |

### Aksanlar

| Rol | Renk | Hex | Kullanım |
|-----|------|-----|---------|
| Tertiary 1 | Elektrik Cyan | `#00E5FF` | BMI "Zayıf", bilgi rozetleri |
| Tertiary 2 | Gold | `#FFD700` | BMI "Fazla Kilolu", uyarı |
| Tertiary 3 | Coral Kırmızı | `#FF3366` | BMI "Obez", hata, kritik |

### BMI Renk Haritası

```
Zayıf       → #00E5FF  (Cyan)
Normal      → #00FF87  (Neon Yeşil)
Fazla Kilolu→ #FFD700  (Gold)
Obez        → #FF3366  (Coral Kırmızı)
```

---

## Material 3 Tema

```dart
ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF00FF87),      // Neon Yeşil
    secondary: Color(0xFF6366F1),    // İndigo
    surface: Color(0xFF161F30),      // Koyu Obsidian
    background: Color(0xFF0B0F19),   // Obsidian
  )
)
```

---

## Tipografi

| Kullanım | fontSize | fontWeight | Renk |
|---------|----------|------------|------|
| Büyük başlık | 28–32 | bold / w700 | white |
| Orta başlık | 20–24 | bold / w700 | white |
| Küçük başlık | 16–18 | w600 | white |
| Body metni | 13–16 | normal | white70 |
| Etiket/rozet | 11–14 | w600 | primary veya white |

---

## Spacing Sistemi (8px Grid)

| Token | Değer |
|-------|-------|
| xs | 4px |
| sm | 8px |
| md | 12–16px |
| lg | 20–24px |
| xl | 32px |
| xxl | 48px |

---

## Border Radius

| Kullanım | Değer |
|---------|-------|
| Küçük kart/chip | 12px |
| Orta kart | 16–20px |
| Büyük kart | 24–28px |
| Tam yuvarlak | 100px (CircleAvatar) |

---

## Gölge & Glow

```dart
// Kart gölgesi
BoxShadow(
  color: primary.withOpacity(0.15),
  blurRadius: 10–20,
  spreadRadius: 1–2,
)

// Seçili öğe glow efekti
BoxShadow(
  color: primary.withOpacity(0.3),
  blurRadius: 12,
  spreadRadius: 2,
)
```

---

## Animasyonlar

### AnimatedContainer
**Kullanım:** Seçim state değişimleri (onboarding kartları, tab highlight)  
**Duration:** 200–300ms  
**Curve:** Curves.easeInOut

### FadeTransition
**Kullanım:** Sayfa geçişleri  

### ScaleTransition
**Kullanım:** Modal ve dialog pop-in animasyonları  

### CircularProgressIndicator
**Kullanım:** API yükleme durumları  
**Renk:** Primary (Neon Yeşil)

### Lottie
**Kullanım:** Hedef başarısı kutlama animasyonu  
**Kaynak:** Network URL (Lottie JSON)  
**Paket:** `lottie: ^3.3.3`

### Custom Timer Animation
**WorkoutSessionScreen'de:**
- Hazırlık countdown → büyük sayı + pulse efekti
- Set progress → animasyonlu progress indicator

---

## İkon Seti

**Kaynak:** Material Icons Rounded

```dart
Icons.home_rounded       // Dashboard tab
Icons.person_rounded     // Profil tab
Icons.history_rounded    // Geçmiş tab
Icons.fitness_center     // Antrenman
Icons.timer              // Süre
Icons.local_fire_department  // HIIT/Yoğun
Icons.arrow_forward_ios  // Navigasyon
Icons.check_circle       // Tamamlandı
```

---

## Gradient Kullanımı

```dart
// Karanlık overlay gradient (image kartlarında)
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
)

// Progress bar gradient
LinearGradient(
  colors: [Color(0xFF00FF87), Color(0xFF6366F1)],
)
```

---

## Tasarım Kararlarının Gerekçesi

| Karar | Gerekçe |
|-------|---------|
| Neon Yeşil primary | Enerji, fitness, canlılık hissi |
| Tam dark tema | Gym ortamında göz yormaz, premium görünüm |
| Material 3 | Modern Flutter best practice |
| Büyük dokunma alanları | Antrenman sırasında ter elleri düşünülerek |
| Minimal text | GIF + görsel ağırlıklı egzersiz gösterimi |

---

## Bağlantılar

- [[04_Ekranlar]] — tasarımın uygulandığı ekranlar
- [[01_Mimari]] — tema tanımının yapıldığı main.dart
