import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/data/models/task_model.dart';
import 'package:taskify/presentation/providers/task_provider.dart';
import 'package:taskify/presentation/screens/add_task/add_task_screen.dart';
import 'package:taskify/presentation/widgets/task_card.dart';
import 'package:taskify/presentation/widgets/empty_state.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final tasks = provider.filteredTasks;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: const Text(
                  'My Tasks 📋',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textTertiary),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.textTertiary),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      emoji: '📋',
                      isSelected: provider.statusFilter == null,
                      onTap: () => provider.setStatusFilter(null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Pending',
                      emoji: '⏳',
                      isSelected: provider.statusFilter == TaskStatus.pending,
                      onTap: () =>
                          provider.setStatusFilter(TaskStatus.pending),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'In Progress',
                      emoji: '🔄',
                      isSelected:
                          provider.statusFilter == TaskStatus.inProgress,
                      onTap: () =>
                          provider.setStatusFilter(TaskStatus.inProgress),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Completed',
                      emoji: '✅',
                      isSelected:
                          provider.statusFilter == TaskStatus.completed,
                      onTap: () =>
                          provider.setStatusFilter(TaskStatus.completed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${tasks.length} task${tasks.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: tasks.isEmpty
                    ? const EmptyState(
                        emoji: '🔍',
                        title: 'No tasks found',
                        subtitle: 'Try adjusting your search or filters',
                      )
                    : RefreshIndicator(
                        onRefresh: provider.loadTasks,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () => _navigateToEdit(context, task),
                              onToggleStatus: () =>
                                  provider.toggleTaskStatus(task),
                              onDelete: () => provider.deleteTask(task.id),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
