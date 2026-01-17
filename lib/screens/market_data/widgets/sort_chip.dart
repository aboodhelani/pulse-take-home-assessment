import 'package:flutter/material.dart';
import 'package:pulsenow_flutter/enms/sort_type.dart';

class SortChip extends StatelessWidget {
  final String label;
  final SortType sortType;
  final SortType currentSortType;
  final bool isAscending;
  final VoidCallback onTap;

  const SortChip({
    super.key,
    required this.label,
    required this.sortType,
    required this.currentSortType,
    required this.isAscending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = currentSortType == sortType;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
