import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../data/exercise_data.dart';
import 'workout_generator_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _db;
  static int? _cachedUserId;

  // Senkron erişim — sadece init() sonrası çalışır
  static int? get savedUserId => _cachedUserId;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // main() içinde bir kez çağrılır
  static Future<void> init() async {
    final db = await DatabaseService.instance.database;
    await DatabaseService.instance._ensureTables(db);
    _cachedUserId = await DatabaseService.instance._getActiveUserId();
  }

  // ──────────────────────── DB INIT ────────────────────────

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'akilli_antreman.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _ensureTables(Database db) async {
    await _createTables(db);
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickname TEXT NOT NULL,
        gender TEXT,
        age INTEGER DEFAULT 25,
        height REAL DEFAULT 175.0,
        weight REAL DEFAULT 70.0,
        goal TEXT,
        level TEXT,
        environment TEXT,
        target_muscles TEXT,
        target_weight REAL,
        workout_days TEXT,
        program_type TEXT,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        program_name TEXT,
        completed_at TEXT DEFAULT (datetime('now')),
        total_time_seconds INTEGER DEFAULT 0,
        total_exercises INTEGER DEFAULT 0,
        total_sets INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  // ──────────────────────── USER ────────────────────────

  Future<int> insertUser(UserProfile profile, List<String> workoutDays) async {
    final db = await database;
    final programType = WorkoutGeneratorService.getProgramTypeKey(profile);
    final id = await db.insert('users', {
      'nickname': profile.nickname ?? '',
      'gender': profile.gender ?? '',
      'age': profile.age,
      'height': profile.height,
      'weight': profile.weight,
      'goal': profile.goal ?? '',
      'level': profile.level ?? '',
      'environment': profile.environment ?? '',
      'target_muscles': (profile.targetMuscles ?? []).join(','),
      'target_weight': profile.targetWeight ?? profile.weight,
      'workout_days': workoutDays.join(','),
      'program_type': programType,
    });
    _cachedUserId = id;
    return id;
  }

  Future<Map<String, dynamic>?> getUser(int userId) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<void> updateWorkoutDays(int userId, List<String> days) async {
    final db = await database;
    await db.update(
      'users',
      {'workout_days': days.join(',')},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateWeight(int userId, double weight) async {
    final db = await database;
    await db.update(
      'users',
      {'weight': weight},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateGoalAndWeight(int userId, String goal, double weight) async {
    final db = await database;
    final programType = _goalToProgram(goal, '');
    await db.update(
      'users',
      {'goal': goal, 'weight': weight, 'program_type': programType},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('workout_sessions');
    await db.delete('users');
    _cachedUserId = null;
  }

  // ──────────────────────── SESSIONS ────────────────────────

  Future<void> insertSession({
    required int userId,
    required String programName,
    required int totalTimeSeconds,
    required int totalExercises,
    required int totalSets,
  }) async {
    final db = await database;
    await db.insert('workout_sessions', {
      'user_id': userId,
      'program_name': programName,
      'total_time_seconds': totalTimeSeconds,
      'total_exercises': totalExercises,
      'total_sets': totalSets,
    });
  }

  // ──────────────────────── DASHBOARD ────────────────────────

  Future<Map<String, dynamic>> getDashboardData(int userId) async {
    final db = await database;
    final user = await getUser(userId);
    if (user == null) return {};

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String();

    final sessions = await db.query(
      'workout_sessions',
      where: "user_id = ? AND completed_at >= ?",
      whereArgs: [userId, monthStart],
    );

    final int completedWorkouts = sessions.length;
    final double bmi = WorkoutGeneratorService.calculateBMI(
      (user['height'] as num).toDouble(),
      (user['weight'] as num).toDouble(),
    );
    final bmiEval = WorkoutGeneratorService.evaluateBMI(bmi);

    int monthlyTime = 0;
    int monthlySets = 0;
    int monthlyExercises = 0;
    for (final s in sessions) {
      monthlyTime += (s['total_time_seconds'] as int? ?? 0) ~/ 60;
      monthlySets += s['total_sets'] as int? ?? 0;
      monthlyExercises += s['total_exercises'] as int? ?? 0;
    }

    final program = WorkoutGeneratorService.generateProgram(_rowToProfile(user));
    final monthlyTarget = program.haftalikGunSayisi * 4;
    final progressPct = monthlyTarget > 0
        ? (completedWorkouts / monthlyTarget).clamp(0.0, 1.0)
        : 0.0;

    return {
      'user_name': user['nickname'],
      'bmi_value': bmi.toStringAsFixed(1),
      'bmi_status': bmiEval.category,
      'progress_percentage': progressPct,
      'monthly_time_minutes': monthlyTime,
      'monthly_sets': monthlySets,
      'monthly_exercises': monthlyExercises,
      'completed_workouts': completedWorkouts,
      'monthly_target': monthlyTarget,
    };
  }

  // ──────────────────────── SCHEDULE ────────────────────────

  Future<Map<String, dynamic>> getScheduleData(int userId) async {
    final db = await database;
    final user = await getUser(userId);
    if (user == null) {
      return {'today_state': 'rest', 'message': 'Kullanıcı bulunamadı.'};
    }

    final workoutDaysStr = user['workout_days'] as String? ?? '';
    final programName = WorkoutGeneratorService.generateProgram(_rowToProfile(user)).programAdi;

    // Bugün antrenman günü mü?
    final todayName = _turkishDayName(DateTime.now().weekday);
    final userDays = workoutDaysStr.split(',').map((d) => d.trim()).where((d) => d.isNotEmpty).toList();
    final isWorkoutDay = userDays.contains(todayName);

    final schedule = _buildSchedule(userDays, user);

    if (!isWorkoutDay) {
      return {
        'today_state': 'rest',
        'message': 'Bugün dinlenme günün! Kaslarını toparla, zorlamanın alemi yok.',
        'schedule': schedule,
        'program_title': programName,
        'today_day_name': todayName,
      };
    }

    // Bugün zaten antrenman yapıldı mı?
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final todaySessions = await db.rawQuery(
      "SELECT id FROM workout_sessions WHERE user_id = ? AND date(completed_at) = ?",
      [userId, todayStr],
    );

    if (todaySessions.isNotEmpty) {
      return {
        'today_state': 'already_done',
        'message': 'Süpersin! Bugünkü antrenmanını tamamladın. Yarın görüşürüz.',
        'schedule': schedule,
        'program_title': programName,
        'today_day_name': todayName,
      };
    }

    return {
      'today_state': 'workout_time',
      'message': 'Bugün antrenman günün! Hadi başla.',
      'schedule': schedule,
      'program_title': programName,
      'today_day_name': todayName,
    };
  }

  // ──────────────────────── HISTORY ────────────────────────

  Future<List<Map<String, dynamic>>> getHistory(int userId) async {
    final db = await database;
    return db.query(
      'workout_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );
  }

  // ──────────────────────── YARDIMCILAR ────────────────────────

  Future<int?> _getActiveUserId() async {
    final db = await database;
    final rows = await db.query('users', orderBy: 'id DESC', limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  UserProfile _rowToProfile(Map<String, dynamic> row) {
    return UserProfile(
      nickname: row['nickname'] as String?,
      gender: row['gender'] as String?,
      age: row['age'] as int? ?? 25,
      height: (row['height'] as num?)?.toDouble() ?? 175.0,
      weight: (row['weight'] as num?)?.toDouble() ?? 70.0,
      goal: row['goal'] as String?,
      level: row['level'] as String?,
      environment: row['environment'] as String?,
      targetMuscles: (row['target_muscles'] as String?)?.split(',').where((s) => s.isNotEmpty).toList(),
      targetWeight: (row['target_weight'] as num?)?.toDouble(),
    );
  }

  Map<String, List<Map<String, dynamic>>> _buildSchedule(
    List<String> userDays,
    Map<String, dynamic> user,
  ) {
    final targetMusclesRaw = (user['target_muscles'] as String? ?? '').split(',').where((s) => s.isNotEmpty).toList();
    return buildFilteredSchedule(
      userDays: userDays,
      gender: user['gender'] as String? ?? '',
      environment: user['environment'] as String? ?? '',
      targetMuscles: targetMusclesRaw,
      goal: user['goal'] as String? ?? '',
      level: user['level'] as String? ?? '',
      weight: (user['weight'] as num?)?.toDouble() ?? 70.0,
      height: (user['height'] as num?)?.toDouble() ?? 170.0,
    );
  }

  String _turkishDayName(int weekday) {
    const names = {
      1: 'Pazartesi',
      2: 'Salı',
      3: 'Çarşamba',
      4: 'Perşembe',
      5: 'Cuma',
      6: 'Cumartesi',
      7: 'Pazar',
    };
    return names[weekday] ?? 'Pazartesi';
  }

  String _goalToProgram(String goal, String gender) {
    final g = goal.toLowerCase();
    if (g.contains('kilo_ver') || g.contains('kilo ver')) return 'hiit';
    if (g.contains('kas') || g.contains('hacim')) {
      return gender == 'Erkek' ? 'upper_body' : 'lower_body';
    }
    return 'full_body';
  }
}
