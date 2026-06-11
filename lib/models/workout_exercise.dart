class WorkoutExercise {
  final String name;
  final String gifUrl;

  WorkoutExercise({
    required this.name,
    required this.gifUrl,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      name: json['name'] ?? json['exercise_name'] ?? json['egzersiz_adi'] ?? '',
      gifUrl: json['gifUrl'] ?? json['gif_url'] ?? json['gorsel_url'] ?? '',
    );
  }

  @override
  String toString() {
    return 'WorkoutExercise(name: $name, gifUrl: $gifUrl)';
  }
}
