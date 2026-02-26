import 'package:flutter_test/flutter_test.dart';
import 'package:taskify/data/models/task_model.dart';

void main() {
  group('Task Model', () {
    test('creates task with required fields', () {
      final now = DateTime.now();
      final task = Task(
        id: 'test-1',
        title: 'Test Task',
        createdAt: now,
        updatedAt: now,
      );

      expect(task.id, 'test-1');
      expect(task.title, 'Test Task');
      expect(task.status, TaskStatus.pending);
      expect(task.priority, TaskPriority.medium);
      expect(task.description, '');
      expect(task.isOverdue, false);
    });

    test('copyWith creates a modified copy', () {
      final now = DateTime.now();
      final task = Task(
        id: 'test-1',
        title: 'Original',
        createdAt: now,
        updatedAt: now,
      );

      final updated = task.copyWith(
        title: 'Updated',
        status: TaskStatus.completed,
      );

      expect(updated.title, 'Updated');
      expect(updated.status, TaskStatus.completed);
      expect(updated.id, task.id);
    });

    test('isOverdue returns true for past due dates', () {
      final task = Task(
        id: 'test-1',
        title: 'Overdue Task',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isOverdue, true);
    });

    test('isOverdue returns false for completed tasks', () {
      final task = Task(
        id: 'test-1',
        title: 'Done Task',
        status: TaskStatus.completed,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isOverdue, false);
    });
  });

  group('TaskStatus Extension', () {
    test('has correct labels', () {
      expect(TaskStatus.pending.label, 'Pending');
      expect(TaskStatus.inProgress.label, 'In Progress');
      expect(TaskStatus.completed.label, 'Completed');
    });

    test('has correct emojis', () {
      expect(TaskStatus.pending.emoji, '⏳');
      expect(TaskStatus.inProgress.emoji, '🔄');
      expect(TaskStatus.completed.emoji, '✅');
    });
  });

  group('TaskPriority Extension', () {
    test('has correct labels', () {
      expect(TaskPriority.low.label, 'Low');
      expect(TaskPriority.medium.label, 'Medium');
      expect(TaskPriority.high.label, 'High');
    });
  });
}
