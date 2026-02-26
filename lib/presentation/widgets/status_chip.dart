import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/data/models/task_model.dart';

class StatusChip extends StatelessWidget {
  final TaskStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: _textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.warning.withValues(alpha: 0.12);
      case TaskStatus.inProgress:
        return AppColors.primary.withValues(alpha: 0.12);
      case TaskStatus.completed:
        return AppColors.success.withValues(alpha: 0.12);
    }
  }

  Color get _textColor {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.warning;
      case TaskStatus.inProgress:
        return AppColors.primary;
      case TaskStatus.completed:
        return AppColors.success;
    }
  }
}
