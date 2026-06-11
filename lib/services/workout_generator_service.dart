import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/workout_program.dart';

class WorkoutGeneratorService {
  // BMI hesaplar
  static double calculateBMI(double heightCm, double weightKg) {
    if (heightCm <= 0) return 0;
    final double heightMeters = heightCm / 100.0;
    return weightKg / (heightMeters * heightMeters);
  }

  // BMI durumunu ve rengini döner
  static BMIEvaluation evaluateBMI(double bmi) {
    if (bmi < 18.5) {
      return BMIEvaluation(
        category: 'Zayıf',
        description: 'Vücut kitle indeksiniz normalin altında. Sağlıklı kilo alımı hedeflenebilir.',
        color: const Color(0xFF00E5FF), // Electric Cyan
      );
    } else if (bmi >= 18.5 && bmi < 25.0) {
      return BMIEvaluation(
        category: 'Normal',
        description: 'Tebrikler! Vücut kitle indeksiniz ideal aralıkta. Formunuzu korumaya devam edin.',
        color: const Color(0xFF00FF87), // Neon Green
      );
    } else if (bmi >= 25.0 && bmi < 30.0) {
      return BMIEvaluation(
        category: 'Fazla Kilolu',
        description: 'Vücut ağırlığınız boyunuza göre biraz fazla. Aktif kalmaya ve beslenmeye dikkat edin.',
        color: const Color(0xFFFFD700), // Energetic Gold/Yellow
      );
    } else {
      return BMIEvaluation(
        category: 'Obez',
        description: 'Vücut kitle indeksiniz yüksek seviyede. Düzenli egzersiz ve uzman eşliğinde aktivite önerilir.',
        color: const Color(0xFFFF3366), // Vibrant Coral Red
      );
    }
  }

  // Profil verilerine göre en uygun antrenman şablonunu oluşturur
  static WorkoutProgram generateProgram(UserProfile profile) {
    final String goal = profile.goal ?? '';
    final String gender = profile.gender ?? '';

    // Eşleştirmelerde "contains" kullanarak daha esnek ve dayanıklı eşleştirme yapıyoruz.
    if (goal.contains('Kilo Ver')) {
      return WorkoutProgram(
        programAdi: 'Yüksek Yoğunluklu Yağ Yakımı (HIIT)',
        aciklama: 'Kardiyovasküler kapasiteni zirveye çıkarırken yağ yakımını maksimize etmeye odaklanan, dinamik ve yüksek tempolu interval antrenman programı.',
        haftalikGunSayisi: 4,
        hedefKategori: 'Yağ Yakımı & Kondisyon',
      );
    } else if (goal.contains('Kas') || goal.contains('Hacim')) {
      if (gender == 'Erkek') {
        return WorkoutProgram(
          programAdi: 'Üst Vücut Odaklı Hipertrofi',
          aciklama: 'Göğüs, sırt, omuz ve kol kaslarını hedefleyen, hacim ve güç kazanımına odaklı progresif yükleme (progressive overload) içeren hipertrofi programı.',
          haftalikGunSayisi: 5,
          hedefKategori: 'Kas Hacmi & Güç',
        );
      } else {
        return WorkoutProgram(
          programAdi: 'Alt Vücut Odaklı Hipertrofi',
          aciklama: 'Bacak, kalça ve merkez bölgesi kas gruplarını şekillendirmeyi ve güçlendirmeyi hedefleyen, yüksek yoğunluklu direnç egzersizleri içeren hipertrofi programı.',
          haftalikGunSayisi: 5,
          hedefKategori: 'Sıkılaşma & Şekillendirme',
        );
      }
    } else {
      // Varsayılan veya Formda Kal hedefi
      return WorkoutProgram(
        programAdi: 'Tüm Vücut (Full Body) Kondisyon',
        aciklama: 'Tüm ana kas gruplarını dengeli bir şekilde çalıştırarak metabolik hızı artıran, genel sağlık, esneklik ve mobilite odaklı fonksiyonel kondisyon programı.',
        haftalikGunSayisi: 3,
        hedefKategori: 'Genel Zindelik & Sağlık',
      );
    }
  }
}

class BMIEvaluation {
  final String category;
  final String description;
  final Color color;

  BMIEvaluation({
    required this.category,
    required this.description,
    required this.color,
  });
}
