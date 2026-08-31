class HealthLogModel {
  final String date;
  final int steps;
  final int sleepMinutes;
  final bool gymWorkoutDone;
  final int waterIntakeMl;
  final String? userId;

  HealthLogModel({
    required this.date,
    this.steps = 0,
    this.sleepMinutes = 0,
    this.gymWorkoutDone = false,
    this.waterIntakeMl = 0,
    this.userId,
  });

  factory HealthLogModel.empty(String date, [String? userId]) {
    return HealthLogModel(
      date: date,
      steps: 0,
      sleepMinutes: 0,
      gymWorkoutDone: false,
      waterIntakeMl: 0,
      userId: userId,
    );
  }

  factory HealthLogModel.fromJson(Map<String, dynamic> json) {
    return HealthLogModel(
      date: json['date'] as String,
      steps: json['steps'] as int? ?? 0,
      sleepMinutes: json['sleepMinutes'] as int? ?? 0,
      gymWorkoutDone: json['gymWorkoutDone'] as bool? ?? false,
      waterIntakeMl: json['waterIntakeMl'] as int? ?? 0,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'steps': steps,
      'sleepMinutes': sleepMinutes,
      'gymWorkoutDone': gymWorkoutDone,
      'waterIntakeMl': waterIntakeMl,
      'userId': userId,
    };
  }

  HealthLogModel copyWith({
    String? date,
    int? steps,
    int? sleepMinutes,
    bool? gymWorkoutDone,
    int? waterIntakeMl,
    String? userId,
  }) {
    return HealthLogModel(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      gymWorkoutDone: gymWorkoutDone ?? this.gymWorkoutDone,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      userId: userId ?? this.userId,
    );
  }
}
