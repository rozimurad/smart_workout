class UserProfile {
  String? nickname;
  String? gender; // 'Erkek', 'Kadın'
  int age;
  double height; // cm
  double weight; // kg
  String? goal; // 'Kilo Ver', 'Kas Kütlesi Kazan', 'Formda Kal'
  String? level; // 'Yeni Başlayan', 'Orta', 'İleri'
  String? environment; // 'Ev', 'Spor Salonu'
  List<String>? targetMuscles;
  double? targetWeight;

  UserProfile({
    this.nickname,
    this.gender,
    this.age = 25,
    this.height = 175.0,
    this.weight = 70.0,
    this.goal,
    this.level,
    this.environment,
    this.targetMuscles,
    this.targetWeight,
  });

  UserProfile copyWith({
    String? nickname,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? goal,
    String? level,
    String? environment,
    List<String>? targetMuscles,
    double? targetWeight,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      environment: environment ?? this.environment,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      targetWeight: targetWeight ?? this.targetWeight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'goal': goal,
      'level': level,
      'environment': environment,
      'targetMuscles': targetMuscles,
      'target_weight': targetWeight,
    };
  }

  @override
  String toString() {
    return 'UserProfile(nickname: $nickname, gender: $gender, age: $age, height: ${height.toStringAsFixed(0)} cm, weight: ${weight.toStringAsFixed(0)} kg, goal: $goal, level: $level, environment: $environment, targetMuscles: $targetMuscles)';
  }
}
