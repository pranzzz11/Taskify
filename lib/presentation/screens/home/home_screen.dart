import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/core/utils/date_formatter.dart';
import 'package:taskify/data/models/task_model.dart';
import 'package:taskify/presentation/providers/task_provider.dart';
import 'package:taskify/presentation/screens/add_task/add_task_screen.dart';
import 'package:taskify/presentation/widgets/task_card.dart';
import 'package:taskify/presentation/widgets/empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.loadTasks,
            color: AppColors.primary,
            child: provider.totalTasks == 0
                ? _buildEmptyHome()
                : _buildDashboard(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildEmptyHome() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildGreeting(),
        const SizedBox(height: 80),
        const EmptyState(
          emoji: '📝',
          title: 'No tasks yet',
          subtitle: 'Tap the + button to create your first task!',
        ),
      ],
    );
  }

  Widget _buildDashboard(BuildContext context, TaskProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 20),
        _buildGreeting(),
        const SizedBox(height: 24),
        _buildStats(provider),
        const SizedBox(height: 20),
        _buildProgressCard(provider),
        const SizedBox(height: 28),
        _buildSectionHeader("Today's Tasks 📅", '${provider.todayTasks.length}'),
        const SizedBox(height: 12),
        if (provider.todayTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: EmptyState(
              emoji: '🎉',
              title: 'All clear for today!',
              subtitle: 'No tasks due today. Enjoy your free time!',
            ),
          )
        else
          ...provider.todayTasks.map((task) => TaskCard(
                task: task,
                onTap: () => _navigateToEdit(context, task),
                onToggleStatus: () =>
                    context.read<TaskProvider>().toggleTaskStatus(task),
                onDelete: () =>
                    context.read<TaskProvider>().deleteTask(task.id),
              )),
        if (provider.recentTasks.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSectionHeader('Recent Tasks 🕐', null),
          const SizedBox(height: 12),
          ...provider.recentTasks.map((task) => TaskCard(
                task: task,
                onTap: () => _navigateToEdit(context, task),
                onToggleStatus: () =>
                    context.read<TaskProvider>().toggleTaskStatus(task),
                onDelete: () =>
                    context.read<TaskProvider>().deleteTask(task.id),
              )),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGreeting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormatter.getGreeting()} 👋',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.todayFormatted(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text('😊', style: TextStyle(fontSize: 24)),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(TaskProvider provider) {
    return Row(
      children: [
        _StatCard(
          emoji: '📋',
          label: 'Total',
          count: provider.totalTasks,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        _StatCard(
          emoji: '✅',
          label: 'Done',
          count: provider.completedTasks,
          color: AppColors.success,
        ),
        const SizedBox(width: 12),
        _StatCard(
          emoji: '⏳',
          label: 'Pending',
          count: provider.pendingTasks,
          color: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildProgressCard(TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.completedTasks} of ${provider.totalTasks} tasks completed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: provider.completionRate,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${(provider.completionRate * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null)
          Text(
            '$trailing tasks',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  void _navigateToEdit(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(existingTask: task),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
