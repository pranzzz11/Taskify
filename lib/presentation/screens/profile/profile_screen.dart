import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/presentation/providers/task_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text('😊', style: TextStyle(fontSize: 48)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Taskify User',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'user@taskify.app',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ProfileStat(
                        emoji: '📋',
                        value: '${provider.totalTasks}',
                        label: 'Created',
                      ),
                      Container(
                          width: 1, height: 40, color: AppColors.divider),
                      _ProfileStat(
                        emoji: '✅',
                        value: '${provider.completedTasks}',
                        label: 'Completed',
                      ),
                      Container(
                          width: 1, height: 40, color: AppColors.divider),
                      _ProfileStat(
                        emoji: '🔥',
                        value:
                            '${(provider.completionRate * 100).round()}%',
                        label: 'Rate',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _MenuItem(
                  emoji: '📊',
                  title: 'Statistics',
                  subtitle: 'View detailed task analytics',
                  onTap: () => _showStatsDialog(context, provider),
                ),
                _MenuItem(
                  emoji: '🏷️',
                  title: 'Categories',
                  subtitle: 'View task categories',
                  onTap: () => _showCategoriesDialog(context, provider),
                ),
                _MenuItem(
                  emoji: '🗑️',
                  title: 'Clear All Tasks',
                  subtitle: 'Remove all tasks permanently',
                  onTap: () => _showClearDialog(context, provider),
                  isDestructive: true,
                ),
                _MenuItem(
                  emoji: 'ℹ️',
                  title: 'About',
                  subtitle: 'Taskify v1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStatsDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('📊 Task Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatRow('Total Tasks', '${provider.totalTasks}'),
            _StatRow('Completed', '${provider.completedTasks}'),
            _StatRow('Pending', '${provider.pendingTasks}'),
            _StatRow('In Progress', '${provider.inProgressTasks}'),
            _StatRow('Overdue', '${provider.overdueTasks}'),
            _StatRow('Completion Rate',
                '${(provider.completionRate * 100).round()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCategoriesDialog(BuildContext context, TaskProvider provider) {
    final categoryCount = <String, int>{};
    for (final task in provider.tasks) {
      categoryCount[task.category] =
          (categoryCount[task.category] ?? 0) + 1;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🏷️ Categories'),
        content: categoryCount.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No tasks yet. Create some tasks to see categories!',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: categoryCount.entries
                    .map((e) => _StatRow(e.key, '${e.value} tasks'))
                    .toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🗑️ Clear All Tasks'),
        content: const Text(
          'Are you sure you want to delete all tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllTasks();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All tasks cleared! 🗑️'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ℹ️ About Taskify'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Taskify v1.0.0',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              'A beautiful task management app built with Flutter and Hive for seamless offline task tracking.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            SizedBox(height: 16),
            Text('Built with ❤️ using Flutter'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _ProfileStat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? AppColors.error
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
