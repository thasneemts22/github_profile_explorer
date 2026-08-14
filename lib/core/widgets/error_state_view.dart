import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../network/api_exceptions.dart';

class ErrorStateView extends StatelessWidget {
  final AppException error;
  final VoidCallback? onRetry;
  final String? customTitle;

  const ErrorStateView({
    super.key,
    required this.error,
    this.onRetry,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final (icon, title, subtitle, badgeText) = _resolveErrorPresentation();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkAccentRed : AppColors.lightAccentRed)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isDark ? AppColors.darkAccentRed : AppColors.lightAccentRed,
              ),
            ),
            const SizedBox(height: 16),

    
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBgTertiary : AppColors.lightBgTertiary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

          
            Text(
              customTitle ?? title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

          
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

      
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  (IconData, String, String, String?) _resolveErrorPresentation() {
    if (error is NotFoundException) {
      return (
        Icons.person_search_rounded,
        'GitHub User Not Found',
        'We could not find any GitHub user with that username. Please verify the spelling and try again.',
        'HTTP 404'
      );
    }

    if (error is RateLimitException) {
      final rateError = error as RateLimitException;
      final resetNote = rateError.formattedResetTime.isNotEmpty
          ? '\n(${rateError.formattedResetTime})'
          : '';
      return (
        Icons.timer_outlined,
        'API Rate Limit Exceeded',
        'GitHub limits unauthenticated API calls to 60 requests per hour. $resetNote',
        'HTTP 403'
      );
    }

    if (error is NetworkException) {
      return (
        Icons.wifi_off_rounded,
        'Connection Problem',
        error.message,
        'Network'
      );
    }

    if (error is TimeoutException) {
      return (
        Icons.hourglass_empty_rounded,
        'Request Timed Out',
        'The connection to GitHub took too long. Please check your internet and try again.',
        'Timeout'
      );
    }

    if (error is ServerException) {
      return (
        Icons.dns_rounded,
        'GitHub Server Error',
        error.message,
        error.statusCode != null ? 'HTTP ${error.statusCode}' : '5xx'
      );
    }

    return (
      Icons.error_outline_rounded,
      'Something Went Wrong',
      error.message,
      null
    );
  }
}
