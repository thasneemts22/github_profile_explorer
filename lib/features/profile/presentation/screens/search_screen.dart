import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:github_profile_explorer/core/constants/app_colors.dart';
import 'package:github_profile_explorer/core/theme/theme_view_model.dart';
import 'package:github_profile_explorer/core/widgets/error_state_view.dart';
import 'package:github_profile_explorer/core/widgets/shimmer_loading.dart';
import 'package:github_profile_explorer/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:github_profile_explorer/features/profile/presentation/view_models/recent_searches_view_model.dart';
import 'package:github_profile_explorer/features/profile/presentation/widgets/profile_card.dart';
import 'package:github_profile_explorer/features/profile/presentation/widgets/recent_searches_list.dart';
import 'package:github_profile_explorer/features/profile/presentation/widgets/search_bar_widget.dart';
import 'package:github_profile_explorer/features/repositories/presentation/screens/repositories_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;

  static const List<String> _quickSuggestions = [
    'flutter',
    'torvalds',
    'google',
    'dart-lang',
    'mitchellh',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String username) {
    final clean = username.trim();
    if (clean.isEmpty) return;

    _searchController.text = clean;
    final profileVm = context.read<ProfileViewModel>();
    final historyVm = context.read<RecentSearchesViewModel>();
    profileVm.searchUser(clean, recentSearchesViewModel: historyVm);
  }

  void _onClear() {
    context.read<ProfileViewModel>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bgTertiary = isDark ? AppColors.darkBgTertiary : AppColors.lightBgTertiary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgTertiary : AppColors.lightBgTertiary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border),
              ),
              child: Icon(
                Icons.hub_rounded,
                size: 20,
                color: isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'GitHub Explorer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<ThemeViewModel>(
            builder: (context, themeVm, _) {
              return IconButton(
                icon: Icon(
                  themeVm.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                tooltip: themeVm.isDarkMode ? 'Light Mode' : 'Dark Mode',
                onPressed: () => themeVm.toggleTheme(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              
                  Consumer<ProfileViewModel>(
                    builder: (context, profileVm, _) {
                      return SearchBarWidget(
                        controller: _searchController,
                        isLoading: profileVm.isLoading,
                        onSubmitted: _performSearch,
                        onClear: _onClear,
                      );
                    },
                  ),
                  const SizedBox(height: 20),

          
                  Consumer<RecentSearchesViewModel>(
                    builder: (context, historyVm, _) {
                      if (!historyVm.hasSearches) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: RecentSearchesList(
                          searches: historyVm.searches,
                          onSelect: _performSearch,
                          onRemove: (user) => historyVm.removeSearch(user),
                          onClearAll: () => historyVm.clearAll(),
                        ),
                      );
                    },
                  ),

              
                  Consumer<ProfileViewModel>(
                    builder: (context, profileVm, _) {
                      if (profileVm.isLoading) {
                        return const ProfileSkeletonLoading();
                      }

                      if (profileVm.isError && profileVm.error != null) {
                        final historyVm = context.read<RecentSearchesViewModel>();
                        return ErrorStateView(
                          error: profileVm.error!,
                          onRetry: () => profileVm.retry(recentSearchesViewModel: historyVm),
                        );
                      }

                      if (profileVm.isSuccess && profileVm.user != null) {
                        return ProfileCard(
                          user: profileVm.user!,
                          onViewRepositories: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RepositoriesScreen(user: profileVm.user!),
                              ),
                            );
                          },
                        );
                      }

                  
                      return _buildInitialState(
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        bgTertiary: bgTertiary,
                        border: border,
                        isDark: isDark,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState({
    required Color textPrimary,
    required Color textSecondary,
    required Color bgTertiary,
    required Color border,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 32,
              color: isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore GitHub Developers & Orgs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Search any username to inspect their public profile, follower statistics, bio, and open-source repositories.',
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'POPULAR PROFILES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _quickSuggestions.map((username) {
              return ActionChip(
                backgroundColor: bgTertiary,
                side: BorderSide(color: border),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: isDark ? AppColors.darkAccentBlue : AppColors.lightAccentBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                onPressed: () => _performSearch(username),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
