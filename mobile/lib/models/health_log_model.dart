class HealthLogModel {
  final String date;
  final int steps;
  final int sleepMinutes;
  final int waterIntakeMl;
  final bool gymWorkoutDone;

  HealthLogModel({
    required this.date,
    this.steps = 0,
    this.sleepMinutes = 0,
    this.waterIntakeMl = 0,
    this.gymWorkoutDone = false,
  });

  HealthLogModel copyWith({
    String? date,
    int? steps,
    int? sleepMinutes,
    int? waterIntakeMl,
    bool? gymWorkoutDone,
  }) {
    return HealthLogModel(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      gymWorkoutDone: gymWorkoutDone ?? this.gymWorkoutDone,
    );
  }

  factory HealthLogModel.fromJson(Map<String, dynamic> json) {
    String dateStr = "";
    if (json['logDate'] != null) {
      final raw = json['logDate'].toString();
      dateStr = raw.contains('T') ? raw.split('T')[0] : raw;
    } else if (json['date'] != null) {
      dateStr = json['date'].toString();
    }

    return HealthLogModel(
      date: dateStr,
      steps: int.tryParse(json['steps']?.toString() ?? '0') ?? 0,
      sleepMinutes: int.tryParse(json['sleepMinutes']?.toString() ?? '0') ?? 0,
      waterIntakeMl: int.tryParse(json['waterIntakeMl']?.toString() ?? '0') ?? 0,
      gymWorkoutDone: json['gymWorkoutDone'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'steps': steps,
      'sleepMinutes': sleepMinutes,
      'waterIntakeMl': waterIntakeMl,
      'gymWorkoutDone': gymWorkoutDone,
    };
  }
}
