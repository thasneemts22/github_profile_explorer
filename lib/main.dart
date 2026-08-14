import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/storage/search_history_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_view_model.dart';
import 'features/profile/data/repositories/user_repository.dart';
import 'features/profile/presentation/screens/search_screen.dart';
import 'features/profile/presentation/view_models/profile_view_model.dart';
import 'features/profile/presentation/view_models/recent_searches_view_model.dart';
import 'features/repositories/data/repositories/github_repos_repository.dart';
import 'features/repositories/presentation/view_models/repositories_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  final apiClient = ApiClient();
  final searchStorage = SearchHistoryStorage(sharedPreferences);
  final userRepository = UserRepositoryImpl(apiClient);
  final reposRepository = GithubReposRepositoryImpl(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(sharedPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => RecentSearchesViewModel(searchStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RepositoriesViewModel(reposRepository),
        ),
      ],
      child: const GitHubExplorerApp(),
    ),
  );
}

class GitHubExplorerApp extends StatelessWidget {
  const GitHubExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();

    return MaterialApp(
      title: 'GitHub Profile Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      home: const SearchScreen(),
    );
  }
}
