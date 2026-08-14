import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:github_profile_explorer/core/constants/app_colors.dart';
import 'package:github_profile_explorer/core/utils/date_formatter.dart';
import 'package:github_profile_explorer/core/widgets/metric_card.dart';
import 'package:github_profile_explorer/features/profile/data/models/github_user.dart';

class ProfileCard extends StatelessWidget {
  final GithubUser user;
  final VoidCallback onViewRepositories;

  const ProfileCard({
    super.key,
    required this.user,
    required this.onViewRepositories,
  });

  Future<void> _launchExternalUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final accentBlue = isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue;

    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Handle, Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Hero transition
                Hero(
                  tag: 'user-avatar-${user.login}',
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentBlue.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        user.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? AppColors.darkBgTertiary : AppColors.lightBgTertiary,
                          child: Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.login}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: accentBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (user.type.isNotEmpty)
                            _buildPill(
                              label: user.type,
                              isDark: isDark,
                              color: accentBlue,
                            ),
                          if (user.hireable == true)
                            _buildPill(
                              label: 'Available for hire',
                              isDark: isDark,
                              color: isDark
                                  ? AppColors.darkAccentGreenBright
                                  : AppColors.lightAccentGreenBright,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bio
            if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                user.bio!.trim(),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: textPrimary,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Metrics Grid with fixed mainAxisExtent to prevent overflow
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 72,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricCard(
                  icon: Icons.people_outline_rounded,
                  count: user.followers,
                  label: 'Followers',
                  iconColor: accentBlue,
                ),
                MetricCard(
                  icon: Icons.person_add_alt_1_outlined,
                  count: user.following,
                  label: 'Following',
                  iconColor: isDark
                      ? AppColors.darkAccentPurple
                      : AppColors.lightAccentPurple,
                ),
                MetricCard(
                  icon: Icons.source_outlined,
                  count: user.publicRepos,
                  label: 'Repositories',
                  iconColor: isDark
                      ? AppColors.darkAccentOrange
                      : AppColors.lightAccentOrange,
                  onTap: onViewRepositories,
                ),
                MetricCard(
                  icon: Icons.code_rounded,
                  count: user.publicGists,
                  label: 'Public Gists',
                  iconColor: isDark
                      ? AppColors.darkAccentGreenBright
                      : AppColors.lightAccentGreenBright,
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: border),
            const SizedBox(height: 14),

            // Detailed metadata list
            if (user.company != null && user.company!.trim().isNotEmpty)
              _buildMetaRow(
                icon: Icons.business_rounded,
                text: user.company!.trim(),
                textSecondary: textSecondary,
              ),
            if (user.location != null && user.location!.trim().isNotEmpty)
              _buildMetaRow(
                icon: Icons.location_on_outlined,
                text: user.location!.trim(),
                textSecondary: textSecondary,
              ),
            if (user.cleanBlogUrl != null)
              _buildMetaRow(
                icon: Icons.link_rounded,
                text: user.blog!.trim(),
                textSecondary: textSecondary,
                isLink: true,
                onTap: () => _launchExternalUrl(context, user.cleanBlogUrl!),
              ),
            if (user.twitterUsername != null && user.twitterUsername!.trim().isNotEmpty)
              _buildMetaRow(
                icon: Icons.alternate_email_rounded,
                text: '@${user.twitterUsername!.trim()}',
                textSecondary: textSecondary,
                isLink: true,
                onTap: () => _launchExternalUrl(
                  context,
                  'https://twitter.com/${user.twitterUsername!.trim()}',
                ),
              ),
            if (user.createdAt != null)
              _buildMetaRow(
                icon: Icons.calendar_today_outlined,
                text: 'Joined ${DateFormatter.formatJoinedDate(user.createdAt)}',
                textSecondary: textSecondary,
              ),

            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewRepositories,
                    icon: const Icon(Icons.folder_open_rounded, size: 18),
                    label: Text(
                      'View Repositories (${user.publicRepos})',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkAccentGreen
                          : AppColors.lightAccentGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.outlined(
                  onPressed: () => _launchExternalUrl(context, user.htmlUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 20),
                  tooltip: 'Open in GitHub',
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: border),
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required bool isDark,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String text,
    required Color textSecondary,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isLink ? AppColors.darkAccentBlue : textSecondary,
                decoration: isLink ? TextDecoration.underline : TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (isLink && onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: row,
      );
    }

    return row;
  }
}
