import 'package:flutter/material.dart';
import 'package:github_profile_explorer/core/constants/app_colors.dart';
import 'package:github_profile_explorer/features/repositories/presentation/view_models/repositories_view_model.dart';

class RepoSortFilterBar extends StatelessWidget {
  final TextEditingController filterController;
  final RepoSortOption currentSort;
  final ValueChanged<RepoSortOption> onSortChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onClearFilter;
  final int totalCount;
  final int filteredCount;

  const RepoSortFilterBar({
    super.key,
    required this.filterController,
    required this.currentSort,
    required this.onSortChanged,
    required this.onFilterChanged,
    required this.onClearFilter,
    required this.totalCount,
    required this.filteredCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accentBlue = isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
        TextField(
          controller: filterController,
          onChanged: onFilterChanged,
          style: TextStyle(fontSize: 14, color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Find a repository by name or language...',
            prefixIcon: Icon(Icons.filter_list_rounded, size: 18, color: textMuted),
            suffixIcon: filterController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    onPressed: () {
                      filterController.clear();
                      onClearFilter();
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),

      
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              filteredCount == totalCount
                  ? '$totalCount ${totalCount == 1 ? "repository" : "repositories"}'
                  : '$filteredCount of $totalCount matching',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          
            PopupMenuButton<RepoSortOption>(
              initialValue: currentSort,
              tooltip: 'Sort repositories',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: border),
              ),
              color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary,
              onSelected: onSortChanged,
              itemBuilder: (context) => RepoSortOption.values.map((option) {
                final isSelected = option == currentSort;
                return PopupMenuItem<RepoSortOption>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_rounded : Icons.circle_outlined,
                        size: 16,
                        color: isSelected ? accentBlue : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? accentBlue : textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBgTertiary : AppColors.lightBgTertiary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sort_rounded, size: 16, color: accentBlue),
                    const SizedBox(width: 6),
                    Text(
                      'Sort: ${currentSort.label}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down_rounded, size: 18, color: textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
