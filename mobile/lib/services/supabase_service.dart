import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../models/health_log_model.dart';
import '../core/utils/timeline_utils.dart';
import 'auth_service.dart';

class SupabaseService extends ChangeNotifier {
  // Production backend URL for database & health synchronization
  String _baseUrl = "https://winter-tracker-xi.vercel.app";

  List<TaskModel> _tasks = [];
  HealthLogModel _healthLog = HealthLogModel.empty('2026-08-31');
  Map<String, double> _heatmapRates = {};
  int _currentStreak = 0;
  String _selectedDate = '2026-08-31';
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  HealthLogModel get healthLog => _healthLog;
  Map<String, double> get heatmapRates => _heatmapRates;
  int get currentStreak => _currentStreak;
  String get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get currentUserId => AuthService().currentUser?.uid;

  SupabaseService() {
    _selectedDate = TimelineUtils.formatDateKey(DateTime.now());
  }

  void setBaseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }

  Future<void> selectDate(String date) async {
    _selectedDate = date;
    notifyListeners();
    await loadDateData(date);
  }

  Future<void> loadDateData(String date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final userIdParam = currentUserId != null ? "&userId=$currentUserId" : "";

    try {
      final res = await http.get(Uri.parse("$_baseUrl/api/tasks?date=$date$userIdParam"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['tasks'] != null && (data['tasks'] as List).isNotEmpty) {
          _tasks = (data['tasks'] as List).map((t) => TaskModel.fromJson(t)).toList();
        } else {
          _useLocalDefaultTasks(date);
          _seedTasksToServer(date);
        }
      } else {
        _useLocalDefaultTasks(date);
      }

      // Fetch health log
      final healthRes = await http.get(Uri.parse("$_baseUrl/api/sync-health?date=$date$userIdParam"));
      if (healthRes.statusCode == 200) {
        final data = jsonDecode(healthRes.body);
        if (data['log'] != null) {
          _healthLog = HealthLogModel.fromJson(data['log']);
        }
      }

      // Fetch stats
      final statsRes = await http.get(Uri.parse("$_baseUrl/api/stats/summary?$userIdParam"));
      if (statsRes.statusCode == 200) {
        final data = jsonDecode(statsRes.body);
        _currentStreak = data['streak'] ?? 0;
        if (data['heatmap'] != null) {
          final Map<String, dynamic> rawHeatmap = data['heatmap'];
          _heatmapRates = rawHeatmap.map((k, v) => MapEntry(k, (v as num).toDouble()));
        }
      }
    } catch (e) {
      // Local graceful fallback
      _useLocalDefaultTasks(date);
    } finally {
      if (_tasks.isEmpty) {
        _useLocalDefaultTasks(date);
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useLocalDefaultTasks(String date) {
    _tasks = [
      TaskModel(id: '${date}_gym', title: 'Gym Workout Session (06:00 - 07:00)', category: 'fitness', targetDate: date, startTime: '06:00', autoMetric: 'gym_workout', isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_1', title: 'Wake Up & Morning Protocol', category: 'routine', targetDate: date, startTime: '07:00', isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_2', title: 'Hydration Goal: 4-5L Water', category: 'health', targetDate: date, autoMetric: 'water_4l', isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_3', title: 'Sleep Recovery: 7-8 Hours', category: 'health', targetDate: date, autoMetric: 'sleep_7h', isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_4', title: 'Daily Movement: 10,000 Steps', category: 'fitness', targetDate: date, autoMetric: 'steps_10k', isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_5', title: 'Office Work Shift', category: 'routine', targetDate: date, startTime: '09:00', isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_6', title: 'Self-Study & Revision (If Time Permits)', category: 'study', targetDate: date, isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_7', title: 'Evening Fresh Up & Transition', category: 'routine', targetDate: date, startTime: '18:30', isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_8', title: 'DSA & Placement Preparation Shift', category: 'career', targetDate: date, startTime: '19:00', isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_9', title: 'DSA Practice & Japanese Language', category: 'career', targetDate: date, isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_10', title: 'Major Project Development', category: 'career', targetDate: date, isCompleted: false, userId: currentUserId),
      TaskModel(id: '${date}_11', title: 'Night Protocol & Sleep by 11:00 PM', category: 'routine', targetDate: date, startTime: '23:00', isCompleted: false, userId: currentUserId),
    ];
  }

  Future<void> _seedTasksToServer(String date) async {
    for (final task in _tasks) {
      try {
        await http.post(
          Uri.parse("$_baseUrl/api/tasks"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'title': task.title,
            'category': task.category,
            'targetDate': task.targetDate,
            'startTime': task.startTime,
            'autoMetric': task.autoMetric,
            'applyScope': 'today',
            'userId': currentUserId ?? 'default_hunter',
          }),
        );
      } catch (_) {}
    }
  }

  Future<void> toggleTask(String taskId, bool currentStatus) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(isCompleted: !currentStatus);
      _recalculateStats();
      notifyListeners();

      try {
        await http.patch(
          Uri.parse("$_baseUrl/api/tasks/$taskId"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'isCompleted': !currentStatus,
            'userId': currentUserId,
          }),
        );
      } catch (_) {}
    }
  }

  Future<void> saveTask(TaskModel task, String scope) async {
    final scopedTask = task.copyWith(userId: currentUserId);
    final idx = _tasks.indexWhere((t) => t.id == scopedTask.id);
    if (idx != -1) {
      _tasks[idx] = scopedTask;
    } else {
      _tasks.add(scopedTask);
    }
    _recalculateStats();
    notifyListeners();

    try {
      await http.post(
        Uri.parse("$_baseUrl/api/tasks"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': scopedTask.title,
          'category': scopedTask.category,
          'targetDate': scopedTask.targetDate,
          'startTime': scopedTask.startTime,
          'autoMetric': scopedTask.autoMetric,
          'scope': scope,
          'userId': currentUserId,
        }),
      );
    } catch (_) {}
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    _recalculateStats();
    notifyListeners();

    try {
      await http.delete(Uri.parse("$_baseUrl/api/tasks/$taskId?userId=$currentUserId"));
    } catch (_) {}
  }

  Future<void> updateWater(int delta, String mode) async {
    int newWater = _healthLog.waterIntakeMl;
    if (mode == 'set') {
      newWater = delta;
    } else {
      newWater = (newWater + delta).clamp(0, 10000);
    }

    _healthLog = _healthLog.copyWith(waterIntakeMl: newWater, userId: currentUserId);

    // Auto-check water task if threshold reached
    if (newWater >= 4000) {
      final waterIdx = _tasks.indexWhere((t) => t.autoMetric == 'water_4l');
      if (waterIdx != -1 && !_tasks[waterIdx].isCompleted) {
        _tasks[waterIdx] = _tasks[waterIdx].copyWith(isCompleted: true);
      }
    }
    _recalculateStats();
    notifyListeners();

    try {
      await http.post(
        Uri.parse("$_baseUrl/api/sync-health"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': _selectedDate,
          'waterIntakeMl': newWater,
          'steps': _healthLog.steps,
          'sleepMinutes': _healthLog.sleepMinutes,
          'gymWorkoutDone': _healthLog.gymWorkoutDone,
          'userId': currentUserId,
        }),
      );
    } catch (_) {}
  }

  Future<void> syncHealth({
    required int steps,
    required int sleepMinutes,
    required bool gymWorkoutDone,
    required int waterIntakeMl,
  }) async {
    _healthLog = HealthLogModel(
      date: _selectedDate,
      steps: steps,
      sleepMinutes: sleepMinutes,
      gymWorkoutDone: gymWorkoutDone,
      waterIntakeMl: waterIntakeMl,
      userId: currentUserId,
    );

    // Auto-complete tasks based on thresholds
    for (int i = 0; i < _tasks.length; i++) {
      final t = _tasks[i];
      if (t.autoMetric == 'steps_10k' && steps >= 10000) {
        _tasks[i] = t.copyWith(isCompleted: true);
      } else if (t.autoMetric == 'sleep_7h' && sleepMinutes >= 420) {
        _tasks[i] = t.copyWith(isCompleted: true);
      } else if (t.autoMetric == 'water_4l' && waterIntakeMl >= 4000) {
        _tasks[i] = t.copyWith(isCompleted: true);
      } else if (t.autoMetric == 'gym_workout' && gymWorkoutDone) {
        _tasks[i] = t.copyWith(isCompleted: true);
      }
    }

    _recalculateStats();
    notifyListeners();

    try {
      await http.post(
        Uri.parse("$_baseUrl/api/sync-health"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': _selectedDate,
          'steps': steps,
          'sleepMinutes': sleepMinutes,
          'gymWorkoutDone': gymWorkoutDone,
          'waterIntakeMl': waterIntakeMl,
          'userId': currentUserId,
        }),
      );
    } catch (_) {}
  }

  Future<void> sendTestAlert(String topic) async {
    try {
      await http.post(
        Uri.parse("$_baseUrl/api/notifications/trigger"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': 'test',
          'topic': topic,
          'userId': currentUserId,
        }),
      );
    } catch (_) {}
  }

  void _recalculateStats() {
    if (_tasks.isNotEmpty) {
      final completed = _tasks.where((t) => t.isCompleted).length;
      final rate = (completed / _tasks.length) * 100;
      _heatmapRates[_selectedDate] = rate;
    }
  }
}
