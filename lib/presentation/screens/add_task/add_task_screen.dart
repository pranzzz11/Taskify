import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/core/utils/date_formatter.dart';
import 'package:taskify/data/models/task_model.dart';
import 'package:taskify/presentation/providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;

  const AddTaskScreen({super.key, this.existingTask});

  bool get isEditing => existingTask != null;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  late TaskPriority _selectedPriority;
  late TaskStatus _selectedStatus;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _selectedCategory = task?.category ?? Task.categories[0];
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedStatus = task?.status ?? TaskStatus.pending;
    _selectedDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formBody = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isEditing) ...[
              const Text(
                'Create Task ✨',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Fill in the details for your new task',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
            ],
                const _SectionLabel(text: 'Title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter task title',
                    prefixIcon: Icon(Icons.title_rounded,
                        color: AppColors.textTertiary),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                const _SectionLabel(text: 'Description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter task description (optional)',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 20),
                const _SectionLabel(text: 'Category'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Task.categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const _SectionLabel(text: 'Priority'),
                const SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedPriority = priority),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            right: priority != TaskPriority.high ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _priorityColor(priority).withValues(alpha: 0.12)
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(color: _priorityColor(priority))
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${priority.emoji} ${priority.label}',
                              style: TextStyle(
                                color: isSelected
                                    ? _priorityColor(priority)
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (widget.isEditing) ...[
                  const _SectionLabel(text: 'Status'),
                  const SizedBox(height: 8),
                  Row(
                    children: TaskStatus.values.map((status) {
                      final isSelected = _selectedStatus == status;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedStatus = status),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                              right:
                                  status != TaskStatus.completed ? 8 : 0,
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(color: AppColors.primary)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '${status.emoji} ${status.label}',
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                const _SectionLabel(text: 'Due Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.textTertiary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate != null
                              ? DateFormatter.formatDate(_selectedDate!)
                              : 'Select due date (optional)',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedDate != null)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDate = null),
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.textTertiary, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isEditing ? 'Update Task ✅' : 'Create Task ✨',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );

    if (widget.isEditing) {
      return Scaffold(
        backgroundColor: AppColors.gradientStart,
        appBar: AppBar(
          title: const Text('Edit Task ✏️'),
          backgroundColor: AppColors.gradientStart,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: AppColors.backgroundGradient,
          child: formBody,
        ),
      );
    }

    return SafeArea(child: formBody);
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.success;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.high:
        return AppColors.error;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TaskProvider>();
    final now = DateTime.now();

    try {
      if (widget.isEditing) {
        final updatedTask = Task(
          id: widget.existingTask!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          category: _selectedCategory,
          dueDate: _selectedDate,
          createdAt: widget.existingTask!.createdAt,
          updatedAt: now,
        );
        await provider.updateTask(updatedTask);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully! ✅'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final newTask = Task(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          status: TaskStatus.pending,
          priority: _selectedPriority,
          category: _selectedCategory,
          dueDate: _selectedDate,
          createdAt: now,
          updatedAt: now,
        );
        await provider.addTask(newTask);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully! 🎉'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _resetForm();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _formKey.currentState?.reset();
    setState(() {
      _selectedCategory = Task.categories[0];
      _selectedPriority = TaskPriority.medium;
      _selectedStatus = TaskStatus.pending;
      _selectedDate = null;
    });
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
