import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskify/data/models/task_model.dart';

class HiveService {
  static const String _taskBoxName = 'tasks';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskStatusAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>(_taskBoxName);
  }

  Box<Task> get _taskBox => Hive.box<Task>(_taskBoxName);

  List<Task> getAllTasks() {
    return _taskBox.values.toList();
  }

  Task? getTask(String id) {
    return _taskBox.get(id);
  }

  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  Future<void> clearAll() async {
    await _taskBox.clear();
  }
}
