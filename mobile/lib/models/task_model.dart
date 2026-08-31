class TaskModel {
  final String id;
  final String title;
  final String category;
  final String targetDate;
  final String? startTime;
  final bool isCompleted;
  final String? autoMetric;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.targetDate,
    this.startTime,
    required this.isCompleted,
    this.autoMetric,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? category,
    String? targetDate,
    String? startTime,
    bool? isCompleted,
    String? autoMetric,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      startTime: startTime ?? this.startTime,
      isCompleted: isCompleted ?? this.isCompleted,
      autoMetric: autoMetric ?? this.autoMetric,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    String dateStr = "";
    if (json['targetDate'] != null) {
      final raw = json['targetDate'].toString();
      dateStr = raw.contains('T') ? raw.split('T')[0] : raw;
    }

    return TaskModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'routine',
      targetDate: dateStr,
      startTime: json['startTime']?.toString(),
      isCompleted: json['isCompleted'] == true,
      autoMetric: json['autoMetric']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'targetDate': targetDate,
      'startTime': startTime,
      'isCompleted': isCompleted,
      'autoMetric': autoMetric,
    };
  }
}
