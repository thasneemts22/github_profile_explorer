import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:github_profile_explorer/core/network/api_exceptions.dart';
import 'package:github_profile_explorer/core/network/api_result.dart';
import 'package:github_profile_explorer/core/storage/search_history_storage.dart';
import 'package:github_profile_explorer/core/theme/theme_view_model.dart';
import 'package:github_profile_explorer/core/widgets/error_state_view.dart';
import 'package:github_profile_explorer/features/profile/data/models/github_user.dart';
import 'package:github_profile_explorer/features/profile/data/repositories/user_repository.dart';
import 'package:github_profile_explorer/features/profile/presentation/screens/search_screen.dart';
import 'package:github_profile_explorer/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:github_profile_explorer/features/profile/presentation/view_models/recent_searches_view_model.dart';
import 'package:github_profile_explorer/features/profile/presentation/widgets/profile_card.dart';

class StubUserRepository implements UserRepository {
  ApiResult<GithubUser>? result;

  @override
  Future<ApiResult<GithubUser>> getUserProfile(String username) async {
    return result ?? const Failure(NotFoundException());
  }
}

void main() {
  late SharedPreferences prefs;
  late SearchHistoryStorage searchStorage;
  late StubUserRepository stubUserRepo;
  late ProfileViewModel profileVm;
  late RecentSearchesViewModel recentSearchesVm;
  late ThemeViewModel themeVm;

  const testUser = GithubUser(
    id: 101,
    login: 'flutterdev',
    avatarUrl: 'https://example.com/avatar.png',
    htmlUrl: 'https://github.com/flutterdev',
    name: 'Flutter Developer',
    bio: 'Flutter enthusiast and open source contributor',
    publicRepos: 18,
    publicGists: 3,
    followers: 450,
    following: 120,
    company: 'Google',
    location: 'Mountain View, CA',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    searchStorage = SearchHistoryStorage(prefs);
    stubUserRepo = StubUserRepository();
    profileVm = ProfileViewModel(stubUserRepo);
    recentSearchesVm = RecentSearchesViewModel(searchStorage);
    themeVm = ThemeViewModel(prefs);
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeVm),
        ChangeNotifierProvider.value(value: recentSearchesVm),
        ChangeNotifierProvider.value(value: profileVm),
      ],
      child: const MaterialApp(
        home: SearchScreen(),
      ),
    );
  }

  group('SearchScreen Widget Tests', () {
    testWidgets('renders initial UI with search bar and quick suggestions', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('GitHub Explorer'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Explore GitHub Developers & Orgs'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('torvalds'), findsOneWidget);
    });

    testWidgets('displays error state with retry button on 404 user not found', (tester) async {
      stubUserRepo.result = const Failure(NotFoundException('User not found'));

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Trigger search
      await tester.enterText(find.byType(TextField), 'nonexistent_user_123');
      await tester.tap(find.text('Search'));
      await tester.pump();

      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('GitHub User Not Found'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('displays ProfileCard on successful user search', (tester) async {
      stubUserRepo.result = const Success(testUser);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Enter username and search
      await tester.enterText(find.byType(TextField), 'flutterdev');
      await tester.tap(find.text('Search'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(ProfileCard), findsOneWidget);
      expect(find.text('Flutter Developer'), findsOneWidget);
      expect(find.text('@flutterdev'), findsOneWidget);
      expect(find.text('Flutter enthusiast and open source contributor'), findsOneWidget);
      expect(find.text('Followers'), findsOneWidget);
      expect(find.text('450'), findsOneWidget);
      expect(find.text('View Repositories (18)'), findsOneWidget);
    });
  });
}
