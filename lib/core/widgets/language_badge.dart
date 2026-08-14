import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LanguageBadge extends StatelessWidget {
  final String? language;
  final double dotSize;
  final TextStyle? textStyle;

  const LanguageBadge({
    super.key,
    required this.language,
    this.dotSize = 10,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (language == null || language!.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = AppColors.getLanguageColor(language);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            language!,
            style: textStyle ?? defaultStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
