class TaskModel {
  final String id;
  final String title;
  final String category;
  final String targetDate;
  final String? startTime;
  final bool isCompleted;
  final String? autoMetric;
  final String? userId;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.targetDate,
    this.startTime,
    required this.isCompleted,
    this.autoMetric,
    this.userId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      targetDate: json['targetDate'] as String,
      startTime: json['startTime'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      autoMetric: json['autoMetric'] as String?,
      userId: json['userId'] as String?,
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
      'userId': userId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? category,
    String? targetDate,
    String? startTime,
    bool? isCompleted,
    String? autoMetric,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      startTime: startTime ?? this.startTime,
      isCompleted: isCompleted ?? this.isCompleted,
      autoMetric: autoMetric ?? this.autoMetric,
      userId: userId ?? this.userId,
    );
  }
}
