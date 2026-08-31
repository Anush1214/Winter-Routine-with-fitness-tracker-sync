import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../models/health_log_model.dart';
import '../core/utils/timeline_utils.dart';

class SupabaseService extends ChangeNotifier {
  String _baseUrl = "http://localhost:3000"; // Can be pointed to your Vercel URL
  String _selectedDate = TimelineUtils.formatDateKey(DateTime.now());

  List<TaskModel> _tasks = [];
  HealthLogModel _healthLog = HealthLogModel(date: TimelineUtils.formatDateKey(DateTime.now()));
  Map<String, double> _heatmapRates = {};
  int _currentStreak = 0;
  int _bestStreak = 0;
  bool _isLoading = false;

  String get selectedDate => _selectedDate;
  List<TaskModel> get tasks => _tasks;
  HealthLogModel get healthLog => _healthLog;
  Map<String, double> get heatmapRates => _heatmapRates;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  bool get isLoading => _isLoading;

  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    loadDateData(_selectedDate);
  }

  void selectDate(String date) {
    _selectedDate = date;
    loadDateData(date);
  }

  Future<void> loadDateData(String date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/tasks?date=$date'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final rawTasks = (data['tasks'] as List? ?? []);
          _tasks = rawTasks.map((t) => TaskModel.fromJson(t)).toList();
          
          if (data['healthLog'] != null) {
            _healthLog = HealthLogModel.fromJson(data['healthLog']);
          } else {
            _healthLog = HealthLogModel(date: date);
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading tasks from server, using local defaults: $e");
      _loadOfflineDefaults(date);
    }

    _isLoading = false;
    notifyListeners();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final summaryRes = await http.get(Uri.parse('$_baseUrl/api/stats/summary'));
      if (summaryRes.statusCode == 200) {
        final data = jsonDecode(summaryRes.body);
        _currentStreak = data['currentStreak'] ?? 0;
        _bestStreak = data['bestStreak'] ?? 0;
      }

      final heatRes = await http.get(Uri.parse('$_baseUrl/api/stats/heatmap'));
      if (heatRes.statusCode == 200) {
        final data = jsonDecode(heatRes.body);
        final days = (data['days'] as List? ?? []);
        final map = <String, double>{};
        for (final d in days) {
          map[d['date']] = (d['completionRate'] as num? ?? 0).toDouble();
        }
        _heatmapRates = map;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading stats: $e");
    }
  }

  Future<void> toggleTask(String id, bool currentStatus) async {
    final newStatus = !currentStatus;
    _tasks = _tasks.map((t) => t.id == id ? t.copyWith(isCompleted: newStatus) : t).toList();
    notifyListeners();

    try {
      await http.patch(
        Uri.parse('$_baseUrl/api/tasks/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isCompleted': newStatus}),
      );
      loadStats();
    } catch (e) {
      debugPrint("Toggle task error: $e");
    }
  }

  Future<void> updateWater(int deltaOrAmount, {String mode = 'increment'}) async {
    final currentWater = _healthLog.waterIntakeMl;
    final nextWater = mode == 'set' ? deltaOrAmount : (currentWater + deltaOrAmount).clamp(0, 10000);
    _healthLog = _healthLog.copyWith(waterIntakeMl: nextWater);
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/water-intake'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': _selectedDate,
          'amountMl': deltaOrAmount,
          'mode': mode,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['tasks'] != null) {
          _tasks = (data['tasks'] as List).map((t) => TaskModel.fromJson(t)).toList();
        }
        loadStats();
      }
    } catch (e) {
      debugPrint("Update water error: $e");
    }
  }

  Future<void> syncHealth({
    required int steps,
    required int sleepMinutes,
    required bool gymWorkoutDone,
    required int waterIntakeMl,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/sync-health'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'date': _selectedDate,
          'steps': steps,
          'sleepMinutes': sleepMinutes,
          'gymWorkoutDone': gymWorkoutDone,
          'waterIntakeMl': waterIntakeMl,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['healthLog'] != null) {
          _healthLog = HealthLogModel.fromJson(data['healthLog']);
        }
        if (data['tasks'] != null) {
          _tasks = (data['tasks'] as List).map((t) => TaskModel.fromJson(t)).toList();
        }
        notifyListeners();
        loadStats();
      }
    } catch (e) {
      debugPrint("Sync health error: $e");
    }
  }

  void _loadOfflineDefaults(String date) {
    _tasks = [
      TaskModel(id: "1", title: "Wake Up & Morning Protocol", category: "routine", targetDate: date, startTime: "07:00", isCompleted: false),
      TaskModel(id: "2", title: "Hydration Goal: 4-5L Water", category: "health", targetDate: date, isCompleted: false, autoMetric: "water_4l"),
      TaskModel(id: "3", title: "Sleep Recovery: 7-8 Hours", category: "health", targetDate: date, isCompleted: false, autoMetric: "sleep_7h"),
      TaskModel(id: "4", title: "Daily Movement: 10,000 Steps", category: "fitness", targetDate: date, isCompleted: false, autoMetric: "steps_10k"),
      TaskModel(id: "5", title: "Office Work Shift", category: "routine", targetDate: date, startTime: "09:00", isCompleted: false),
      TaskModel(id: "6", title: "Self-Study & Revision (If Time Permits)", category: "study", targetDate: date, isCompleted: false),
      TaskModel(id: "7", title: "Evening Fresh Up & Transition", category: "routine", targetDate: date, startTime: "18:30", isCompleted: false),
      TaskModel(id: "8", title: "DSA & Placement Preparation Shift", category: "career", targetDate: date, startTime: "19:00", isCompleted: false),
      TaskModel(id: "9", title: "DSA Practice & Japanese Language", category: "career", targetDate: date, isCompleted: false),
      TaskModel(id: "10", title: "Major Project Development", category: "career", targetDate: date, isCompleted: false),
      TaskModel(id: "11", title: "Night Protocol & Sleep by 11:00 PM", category: "routine", targetDate: date, startTime: "23:00", isCompleted: false),
    ];
  }
}
