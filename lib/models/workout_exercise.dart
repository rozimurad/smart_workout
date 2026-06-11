class WorkoutExercise {
  final String name;
  final String imagePath;

  const WorkoutExercise({required this.name, required this.imagePath});

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      name: json['name'] as String? ?? 'Egzersiz',
      imagePath: json['image_path'] as String? ?? '',
    );
  }

  @override
  String toString() => 'WorkoutExercise(name: $name, imagePath: $imagePath)';
}
