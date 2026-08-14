import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:github_profile_explorer/core/constants/app_colors.dart';
import 'package:github_profile_explorer/core/utils/date_formatter.dart';
import 'package:github_profile_explorer/core/utils/number_formatter.dart';
import 'package:github_profile_explorer/core/widgets/language_badge.dart';
import 'package:github_profile_explorer/features/repositories/data/models/github_repo.dart';

class RepoCard extends StatelessWidget {
  final GithubRepo repo;

  const RepoCard({
    super.key,
    required this.repo,
  });

  Future<void> _launchRepoUrl(BuildContext context) async {
    final uri = Uri.tryParse(repo.htmlUrl);
    if (uri != null) {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open ${repo.htmlUrl}')),
        );
      }
    }
  }

  void _copyRepoUrl(BuildContext context) {
    Clipboard.setData(ClipboardData(text: repo.htmlUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "${repo.name}" URL to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final accentBlue = isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue;

    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: () => _launchRepoUrl(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Repo Name & Badges
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          repo.isFork ? Icons.fork_right_rounded : Icons.source_outlined,
                          size: 18,
                          color: accentBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            repo.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: accentBlue,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Public / Fork badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkBgTertiary : AppColors.lightBgTertiary),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      repo.isFork ? 'Fork' : 'Public',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, size: 18, color: textMuted),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'open',
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new_rounded, size: 16),
                            SizedBox(width: 8),
                            Text('Open on GitHub'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded, size: 16),
                            SizedBox(width: 8),
                            Text('Copy Link'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'open') _launchRepoUrl(context);
                      if (value == 'copy') _copyRepoUrl(context);
                    },
                  ),
                ],
              ),

              // Description
              if (repo.description != null && repo.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  repo.description!.trim(),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Topics
              if (repo.topics.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: repo.topics.take(4).map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: accentBlue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 14),

              // Bottom Stats Row: Language, Stars, Forks, Updated Time using Wrap for responsiveness
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (repo.language != null) LanguageBadge(language: repo.language),
                  // Stars
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_outline_rounded,
                        size: 15,
                        color: isDark
                            ? AppColors.darkAccentOrange
                            : AppColors.lightAccentOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormatter.formatCompact(repo.stargazersCount),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Forks
                  if (repo.forksCount > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fork_right_rounded,
                          size: 15,
                          color: textMuted,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          NumberFormatter.formatCompact(repo.forksCount),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  // License
                  if (repo.licenseName != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gavel_rounded, size: 13, color: textMuted),
                        const SizedBox(width: 3),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 80),
                          child: Text(
                            repo.licenseName!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  // Updated Time
                  if (repo.updatedAt != null)
                    Text(
                      'Updated ${DateFormatter.formatRelativeTime(repo.updatedAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
