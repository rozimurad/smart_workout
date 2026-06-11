import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/workout_program.dart';

class LocalStorageService {
  static UserProfile? _savedProfile;
  static WorkoutProgram? _savedProgram;
  static bool _hasSavedData = false;
  static dynamic _savedUserId;

  // Cihazdaki SharedPreferences kayıtlarını belleğe yükler (senkron okuma için)
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedUserId = prefs.getInt('user_id');
      _hasSavedData = _savedUserId != null;
      
      final nickname = prefs.getString('nickname');
      if (nickname != null) {
        _savedProfile = UserProfile(
          nickname: nickname,
          gender: prefs.getString('gender'),
          age: prefs.getInt('age') ?? 25,
          height: prefs.getDouble('height') ?? 175.0,
          weight: prefs.getDouble('weight') ?? 70.0,
          goal: prefs.getString('goal'),
          level: prefs.getString('level'),
          environment: prefs.getString('environment'),
          targetMuscles: prefs.getStringList('target_muscles'),
        );
      }
      print('📦 [LocalStorage] SharedPreferences başarıyla yüklendi. user_id: $_savedUserId, nickname: $nickname');
    } catch (e) {
      print('❌ [LocalStorage] Yükleme hatası: $e');
    }
  }

  // user_id kalıcı olarak kaydeder
  static Future<bool> saveUserId(dynamic userId) async {
    _savedUserId = userId;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (userId != null) {
        final intId = int.tryParse(userId.toString()) ?? 1;
        await prefs.setInt('user_id', intId);
        _hasSavedData = true;
      } else {
        await prefs.remove('user_id');
        _hasSavedData = false;
      }
      print('💾 [LocalStorage] user_id SharedPreferences\'a kalıcı olarak kaydedildi: $_savedUserId');
      return true;
    } catch (e) {
      print('❌ [LocalStorage] user_id kaydetme hatası: $e');
      return false;
    }
  }

  // user_id değerini senkron olarak döner
  static dynamic getSavedUserId() {
    return _savedUserId;
  }

  // Profil verisini kalıcı olarak kaydeder
  static Future<bool> saveUserProfile(UserProfile profile) async {
    _savedProfile = profile;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', profile.nickname ?? '');
      await prefs.setString('gender', profile.gender ?? '');
      await prefs.setInt('age', profile.age);
      await prefs.setDouble('height', profile.height);
      await prefs.setDouble('weight', profile.weight);
      await prefs.setString('goal', profile.goal ?? '');
      await prefs.setString('level', profile.level ?? '');
      await prefs.setString('environment', profile.environment ?? '');
      if (profile.targetMuscles != null) {
        await prefs.setStringList('target_muscles', profile.targetMuscles!);
      } else {
        await prefs.remove('target_muscles');
      }
      print('💾 [LocalStorage] UserProfile SharedPreferences\'a kalıcı olarak kaydedildi.');
      return true;
    } catch (e) {
      print('❌ [LocalStorage] Profil kaydetme hatası: $e');
      return false;
    }
  }

  // Antrenman programını kaydeder (şimdilik bellek odaklı)
  static Future<bool> saveWorkoutProgram(WorkoutProgram program) async {
    _savedProgram = program;
    print('💾 [LocalStorage] WorkoutProgram belleğe kaydedildi: ${program.programAdi}');
    return true;
  }

  // Kayıtlı profil verisini döner
  static UserProfile? getSavedProfile() {
    return _savedProfile;
  }

  // Kayıtlı programı döner
  static WorkoutProgram? getSavedProgram() {
    return _savedProgram;
  }

  // Kayıtlı veri var mı kontrol eder
  static bool isProfileSaved() {
    return _hasSavedData;
  }

  // Tüm kayıtları temizler
  static Future<void> clearAll() async {
    _savedProfile = null;
    _savedProgram = null;
    _savedUserId = null;
    _hasSavedData = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('🗑️ [LocalStorage] Tüm yerel veriler SharedPreferences\'tan temizlendi.');
    } catch (e) {
      print('❌ [LocalStorage] Temizleme hatası: $e');
    }
  }
}
