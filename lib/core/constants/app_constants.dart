class AppConstants {
  AppConstants._();

  static const String appName = 'GitHub Explorer';
  static const String githubApiBaseUrl = 'https://api.github.com';
  static const String recentSearchesKey = 'github_recent_searches_list';
  static const String themeModeKey = 'github_explorer_theme_mode';
  static const int maxRecentSearches = 5;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
