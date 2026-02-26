import 'package:flutter/foundation.dart';
import 'package:taskify/data/models/task_model.dart';
import 'package:taskify/data/services/hive_service.dart';

class TaskProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  TaskStatus? _statusFilter;
  String _searchQuery = '';

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  TaskStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  List<Task> get filteredTasks {
    var result = List<Task>.from(_tasks);

    if (_statusFilter != null) {
      result = result.where((t) => t.status == _statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(query) ||
              t.description.toLowerCase().contains(query) ||
              t.category.toLowerCase().contains(query))
          .toList();
    }

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  int get totalTasks => _tasks.length;

  int get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).length;

  int get pendingTasks =>
      _tasks.where((t) => t.status == TaskStatus.pending).length;

  int get inProgressTasks =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).length;

  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks / totalTasks;
  }

  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return due.isAtSameMomentAs(today);
    }).toList()
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  List<Task> get recentTasks {
    final sorted = List<Task>.from(_tasks)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = _hiveService.getAllTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _hiveService.addTask(task);
    _tasks = _hiveService.getAllTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _hiveService.updateTask(task);
    _tasks = _hiveService.getAllTasks();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _hiveService.deleteTask(id);
    _tasks = _hiveService.getAllTasks();
    notifyListeners();
  }

  Future<void> toggleTaskStatus(Task task) async {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;

    final updatedTask = task.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    await updateTask(updatedTask);
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> clearAllTasks() async {
    await _hiveService.clearAll();
    _tasks = [];
    notifyListeners();
  }
}
