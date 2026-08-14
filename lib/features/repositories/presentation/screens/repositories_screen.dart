import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:github_profile_explorer/core/constants/app_colors.dart';
import 'package:github_profile_explorer/core/widgets/empty_state_view.dart';
import 'package:github_profile_explorer/core/widgets/error_state_view.dart';
import 'package:github_profile_explorer/core/widgets/shimmer_loading.dart';
import 'package:github_profile_explorer/features/profile/data/models/github_user.dart';
import 'package:github_profile_explorer/features/repositories/presentation/view_models/repositories_view_model.dart';
import 'package:github_profile_explorer/features/repositories/presentation/widgets/repo_card.dart';
import 'package:github_profile_explorer/features/repositories/presentation/widgets/repo_sort_filter_bar.dart';

class RepositoriesScreen extends StatefulWidget {
  final GithubUser user;

  const RepositoriesScreen({
    super.key,
    required this.user,
  });

  @override
  State<RepositoriesScreen> createState() => _RepositoriesScreenState();
}

class _RepositoriesScreenState extends State<RepositoriesScreen> {
  late final TextEditingController _filterController;

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepositoriesViewModel>().fetchRepositories(widget.user.login);
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accentBlue = isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.user.login}\'s Repositories',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Consumer<RepositoriesViewModel>(
              builder: (context, repoVm, _) {
                return RefreshIndicator(
                  onRefresh: () => repoVm.fetchRepositories(widget.user.login),
                  child: CustomScrollView(
                    slivers: [
                
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBgSecondary
                                  : AppColors.lightBgPrimary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'user-avatar-${widget.user.login}',
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: accentBlue.withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        widget.user.avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.person,
                                          size: 28,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.user.displayName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '@${widget.user.login}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: accentBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isDark
                                        ? AppColors.darkBgTertiary
                                        : AppColors.lightBgTertiary),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: border),
                                  ),
                                  child: Text(
                                    '${widget.user.publicRepos} Repos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                  
                      if (!repoVm.isError)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: RepoSortFilterBar(
                              filterController: _filterController,
                              currentSort: repoVm.sortOption,
                              totalCount: repoVm.totalRepoCount,
                              filteredCount: repoVm.repos.length,
                              onSortChanged: (sort) => repoVm.setSortOption(sort),
                              onFilterChanged: (query) => repoVm.setFilterQuery(query),
                              onClearFilter: () => repoVm.clearFilter(),
                            ),
                          ),
                        ),

                    
                      if (repoVm.isLoading)
                        const SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          sliver: SliverToBoxAdapter(
                            child: RepoSkeletonLoading(itemCount: 6),
                          ),
                        )
                      else if (repoVm.isError && repoVm.error != null)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ErrorStateView(
                              error: repoVm.error!,
                              onRetry: () => repoVm.retry(),
                            ),
                          ),
                        )
                      else if (repoVm.repos.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyStateView(
                            icon: Icons.source_outlined,
                            title: repoVm.searchFilter.isNotEmpty
                                ? 'No matching repositories'
                                : 'No public repositories found',
                            message: repoVm.searchFilter.isNotEmpty
                                ? 'No repositories found matching "${repoVm.searchFilter}". Try a different keyword.'
                                : '${widget.user.login} does not have any public repositories yet.',
                            actionLabel: repoVm.searchFilter.isNotEmpty ? 'Clear Filter' : null,
                            onAction: repoVm.searchFilter.isNotEmpty
                                ? () {
                                    _filterController.clear();
                                    repoVm.clearFilter();
                                  }
                                : null,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final repo = repoVm.repos[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: RepoCard(repo: repo),
                                );
                              },
                              childCount: repoVm.repos.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
