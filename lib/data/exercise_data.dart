import 'dart:math';

// high_impact: true olan egzersizler obezlerde (BMI >= 30) hariç tutulur
const List<Map<String, dynamic>> kAllExercises = [
  {'name': 'Wall Push-up',           'gif': 'pushups_on_the_wall-man.gif',     'muscle': 'gogus',     'env': 'hepsi', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Marching in Place',      'gif': 'marching_in_place-man.gif',       'muscle': 'full_body', 'env': 'hepsi', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Burpees',                'gif': 'burpees-man.gif',                 'muscle': 'full_body', 'env': 'hepsi', 'gender': 'hepsi', 'high_impact': true},
  {'name': 'Dumbbell Bench Press',   'gif': 'dumbbell_bench_press-man.gif',    'muscle': 'gogus',     'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Lat Pulldown',           'gif': 'lat_pulldown-man.gif',            'muscle': 'sirt',      'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Bodyweight Squat',       'gif': 'bodyweight_squat-man.gif',        'muscle': 'bacak',     'env': 'hepsi', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Jumping Jack',           'gif': 'jumping_jack-man.gif',            'muscle': 'full_body', 'env': 'hepsi', 'gender': 'hepsi', 'high_impact': true},
  {'name': 'Leg Press',              'gif': 'leg_press-man.gif',               'muscle': 'bacak',     'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Crunch',                 'gif': 'crunch-man.gif',                  'muscle': 'karin',     'env': 'hepsi', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Plank',                  'gif': 'plank-man.gif',                   'muscle': 'karin',     'env': 'hepsi', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Knee Push-up',           'gif': 'knee_pushups-man.gif',            'muscle': 'gogus',     'env': 'ev',    'gender': 'hepsi', 'high_impact': false},
  {'name': 'Reverse Lunge',          'gif': 'reverse_lunge-man.gif',           'muscle': 'bacak',     'env': 'hepsi', 'gender': 'kadin', 'high_impact': false},
  {'name': 'Glute Bridge',           'gif': 'glute_bridge-man.gif',            'muscle': 'bacak',     'env': 'hepsi', 'gender': 'kadin', 'high_impact': false},
  {'name': 'Superman',               'gif': 'superman-man.gif',                'muscle': 'sirt',      'env': 'hepsi', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Russian Twist',          'gif': 'russian_twist-man.gif',           'muscle': 'karin',     'env': 'hepsi', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Chair Dips',             'gif': 'chair_dips-man.gif',              'muscle': 'kol',       'env': 'ev',    'gender': 'hepsi', 'high_impact': false},
  {'name': 'Side Step',              'gif': 'side_step-man.gif',               'muscle': 'bacak',     'env': 'ev',    'gender': 'kadin', 'high_impact': false},
  {'name': 'High Knees',             'gif': 'high_knee-man.gif',               'muscle': 'bacak',     'env': 'hepsi', 'gender': 'hepsi', 'high_impact': true},
  {'name': 'Squat Jump',             'gif': 'squat_jump-man.gif',              'muscle': 'bacak',     'env': 'hepsi', 'gender': 'hepsi', 'high_impact': true},
  {'name': 'Mountain Climber',       'gif': 'mountain_climber-man.gif',        'muscle': 'karin',     'env': 'hepsi', 'gender': 'hepsi', 'high_impact': true},
  {'name': 'Box Jump',               'gif': 'box_jump-man.gif',                'muscle': 'bacak',     'env': 'salon', 'gender': 'hepsi', 'high_impact': true},
  {'name': 'Barbell Squat',          'gif': 'barbell_squat-man.gif',           'muscle': 'bacak',     'env': 'salon', 'gender': 'erkek', 'high_impact': false},
  {'name': 'Deadlift',               'gif': 'deadlift-man.gif',                'muscle': 'full_body', 'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Seated Cable Row',       'gif': 'seated_cable_row-man.gif',        'muscle': 'sirt',      'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Hamstring Curl',         'gif': 'hamstring_curl-man.gif',          'muscle': 'bacak',     'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Dumbbell Lateral Raise', 'gif': 'dumbbell_lateral_raise-man.gif',  'muscle': 'kol',       'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Pec Deck Fly',           'gif': 'pec_dec_fly-man.gif',             'muscle': 'gogus',     'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Diamond Push-up',        'gif': 'diamond_pushups-man.gif',         'muscle': 'kol',       'env': 'ev',    'gender': 'hepsi', 'high_impact': false},
  {'name': 'Push-up',                'gif': 'pushup-man.gif',                  'muscle': 'gogus',     'env': 'ev',    'gender': 'hepsi', 'high_impact': false},
  {'name': 'Barbell Biceps Curl',    'gif': 'barbell_biceps_curl-man.gif',     'muscle': 'kol',       'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Triceps Cable Pushdown', 'gif': 'triceps_cable_pushdown-man.gif',  'muscle': 'kol',       'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Dumbbell Hammer Curl',   'gif': 'dumbbell_hammer_curl-man.gif',    'muscle': 'kol',       'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Barbell Bench Press',    'gif': 'barbell_bench_press-man.gif',     'muscle': 'gogus',     'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Incline Dumbbell Press', 'gif': 'incline_dumbbell_press.gif',       'muscle': 'gogus',     'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Barbell Row',            'gif': 'barbell_row-man.gif',             'muscle': 'sirt',      'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Leg Extension',          'gif': 'leg_extension-man.gif',           'muscle': 'bacak',     'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Cable Crunch',           'gif': 'cable_crunch-man.gif',            'muscle': 'karin',     'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
  {'name': 'Hanging Leg Raise',      'gif': 'hanging_leg_raise-man.gif',       'muscle': 'karin',     'env': 'salon', 'gender': 'hepsi', 'high_impact': false},
];

String _normGender(String g) {
  if (g == 'Erkek' || g == 'erkek') return 'erkek';
  if (g == 'Kadın' || g == 'kadin') return 'kadin';
  return 'hepsi';
}

String _normEnv(String e) {
  if (e == 'Ev' || e == 'ev') return 'ev';
  if (e == 'Spor Salonu' || e == 'salon') return 'salon';
  return 'hepsi';
}

String _normMuscle(String m) {
  // Türkçe karakter sorunlarını önlemek için toLowerCase yerine explicit karşılaştırma
  final s = m.trim();
  if (s == 'Göğüs' || s == 'göğüs' || s == 'gogus') return 'gogus';
  if (s == 'Sırt'  || s == 'sırt'  || s == 'sirt')  return 'sirt';
  if (s == 'Kollar'|| s == 'kollar'|| s == 'Kol' || s == 'kol') return 'kol';
  if (s == 'Bacak' || s == 'bacak') return 'bacak';
  if (s == 'Karın' || s == 'karın' || s == 'Karin'|| s == 'karin') return 'karin';
  if (s == 'Full Body' || s == 'full body' || s == 'full_body') return 'full_body';
  return s.toLowerCase();
}

String _normGoal(String g) {
  if (g.contains('Kilo') || g.contains('kilo_ver')) return 'kilo_ver';
  if (g.contains('Kas') || g.contains('kas_kazan')) return 'kas_kazan';
  return 'formda_kal';
}

String _normLevel(String l) {
  if (l == 'Yeni Başlayan' || l == 'baslangic') return 'baslangic';
  if (l == 'Orta' || l == 'orta') return 'orta';
  if (l == 'İleri' || l == 'ileri') return 'ileri';
  return 'baslangic';
}

// BMI >= 30 → obez, yüksek darbeli egzersizler hariç tutulur
bool _isObese(double weight, double height) {
  if (height <= 0) return false;
  final bmi = weight / ((height / 100) * (height / 100));
  return bmi >= 30.0;
}

Map<String, int> _workoutParams(String goal, String level) {
  if (goal == 'kilo_ver') {
    return {
      'sets': 3,
      'reps': level == 'baslangic' ? 15 : 20,
      'rest': level == 'ileri' ? 20 : 30,
    };
  }
  if (goal == 'kas_kazan') {
    return {
      'sets': level == 'baslangic' ? 3 : (level == 'orta' ? 4 : 5),
      'reps': level == 'ileri' ? 8 : 10,
      'rest': 90,
    };
  }
  return {
    'sets': level == 'ileri' ? 4 : 3,
    'reps': level == 'baslangic' ? 12 : 15,
    'rest': level == 'ileri' ? 45 : 60,
  };
}

int _exercisesPerDay(String level) {
  if (level == 'ileri') return 6;
  if (level == 'orta') return 5;
  return 4;
}

List<List<String>> _muscleRotation({
  required List<String> targets,
  required int days,
  required String goal,
}) {
  if (goal == 'kilo_ver') {
    const cardio = [
      ['full_body', 'bacak'],
      ['bacak', 'karin'],
      ['full_body', 'karin'],
      ['bacak', 'full_body'],
      ['karin', 'bacak'],
      ['full_body', 'karin'],
      ['bacak', 'karin'],
    ];
    return List.generate(days, (i) => cardio[i % cardio.length]);
  }

  // Sadece seçilen kaslar arasında döner
  final muscles = targets.isNotEmpty ? targets : ['full_body'];
  return List.generate(days, (i) => [muscles[i % muscles.length]]);
}

List<Map<String, dynamic>> _pickForDay({
  required List<Map<String, dynamic>> eligible,
  required List<String> muscles,
  required int count,
  required Map<String, int> params,
  required Random rng,
}) {
  final shuffled = List<Map<String, dynamic>>.from(eligible)..shuffle(rng);

  final result = <Map<String, dynamic>>[];
  final used = <String>{};

  // 1. Seçilen kaslardan egzersiz seç (random sırayla)
  for (final muscle in muscles) {
    for (final ex in shuffled) {
      if (result.length >= count) break;
      final name = ex['name'] as String;
      if (ex['muscle'] == muscle && !used.contains(name)) {
        result.add(_entry(ex, params));
        used.add(name);
      }
    }
    if (result.length >= count) break;
  }

  // 2. Hâlâ eksik kaldıysa (nadir durum): full_body egzersizler öncelikli, sonra herhangi biri
  if (result.length < count) {
    for (final ex in shuffled) {
      if (result.length >= count) break;
      final name = ex['name'] as String;
      if (!used.contains(name) && ex['muscle'] == 'full_body') {
        result.add(_entry(ex, params));
        used.add(name);
      }
    }
  }
  if (result.length < count) {
    for (final ex in shuffled) {
      if (result.length >= count) break;
      final name = ex['name'] as String;
      if (!used.contains(name)) {
        result.add(_entry(ex, params));
        used.add(name);
      }
    }
  }

  return result;
}

Map<String, dynamic> _entry(Map<String, dynamic> ex, Map<String, int> p) => {
  'name': ex['name'],
  'image_path': 'assets/exercises/man/${ex['gif']}',
  'set_count': p['sets'],
  'rep_count': p['reps'],
  'rest_duration': p['rest'],
};

Map<String, List<Map<String, dynamic>>> buildFilteredSchedule({
  required List<String> userDays,
  required String gender,
  required String environment,
  required List<String> targetMuscles,
  required String goal,
  required String level,
  double weight = 70.0,
  double height = 170.0,
}) {
  final ng = _normGender(gender);
  final ne = _normEnv(environment);
  final ngoal = _normGoal(goal);
  final nlevel = _normLevel(level);
  final ntargets = targetMuscles.map(_normMuscle).toList();
  final params = _workoutParams(ngoal, nlevel);
  final perDay = _exercisesPerDay(nlevel);
  final obese = _isObese(weight, height);

  final eligible = kAllExercises.where((ex) {
    final envOk = ex['env'] == 'hepsi' || ex['env'] == ne;
    final genderOk = ex['gender'] == 'hepsi' || ex['gender'] == ng;
    final impactOk = !obese || !(ex['high_impact'] as bool);
    return envOk && genderOk && impactOk;
  }).toList();

  final rotation = _muscleRotation(targets: ntargets, days: userDays.length, goal: ngoal);
  final result = <String, List<Map<String, dynamic>>>{};

  for (int i = 0; i < userDays.length; i++) {
    final key = '${userDays[i]} — Gün ${i + 1}';
    final muscles = i < rotation.length ? rotation[i] : rotation[0];
    // Seed yok → her çağrıda tamamen farklı egzersizler
    result[key] = _pickForDay(
      eligible: eligible,
      muscles: muscles,
      count: perDay,
      params: params,
      rng: Random(),
    );
  }

  return result;
}
