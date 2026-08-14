import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:github_profile_explorer/core/network/api_result.dart';
import 'package:github_profile_explorer/features/profile/data/models/github_user.dart';
import 'package:github_profile_explorer/features/repositories/data/models/github_repo.dart';
import 'package:github_profile_explorer/features/repositories/data/repositories/github_repos_repository.dart';
import 'package:github_profile_explorer/features/repositories/presentation/screens/repositories_screen.dart';
import 'package:github_profile_explorer/features/repositories/presentation/view_models/repositories_view_model.dart';
import 'package:github_profile_explorer/features/repositories/presentation/widgets/repo_card.dart';

class StubReposRepository implements GithubReposRepository {
  ApiResult<List<GithubRepo>>? result;

  @override
  Future<ApiResult<List<GithubRepo>>> getUserRepositories(
    String username, {
    int perPage = 100,
  }) async {
    return result ?? const Success([]);
  }
}

void main() {
  late StubReposRepository stubRepo;
  late RepositoriesViewModel repoVm;

  const testUser = GithubUser(
    id: 101,
    login: 'flutterdev',
    avatarUrl: 'https://example.com/avatar.png',
    htmlUrl: 'https://github.com/flutterdev',
    name: 'Flutter Developer',
    publicRepos: 2,
    publicGists: 0,
    followers: 100,
    following: 10,
  );

  final testRepos = [
    GithubRepo(
      id: 1,
      name: 'awesome-flutter-app',
      fullName: 'flutterdev/awesome-flutter-app',
      description: 'A beautiful Flutter showcase app',
      htmlUrl: 'https://github.com/flutterdev/awesome-flutter-app',
      stargazersCount: 350,
      forksCount: 45,
      openIssuesCount: 2,
      language: 'Dart',
      updatedAt: DateTime(2026, 1, 1),
    ),
    GithubRepo(
      id: 2,
      name: 'flutter-state-management',
      fullName: 'flutterdev/flutter-state-management',
      description: 'State management patterns and samples',
      htmlUrl: 'https://github.com/flutterdev/flutter-state-management',
      stargazersCount: 890,
      forksCount: 110,
      openIssuesCount: 5,
      language: 'Dart',
      updatedAt: DateTime(2026, 2, 1),
    ),
  ];

  setUp(() {
    stubRepo = StubReposRepository();
    repoVm = RepositoriesViewModel(stubRepo);
  });

  Widget buildTestableWidget() {
    return ChangeNotifierProvider<RepositoriesViewModel>.value(
      value: repoVm,
      child: const MaterialApp(
        home: RepositoriesScreen(user: testUser),
      ),
    );
  }

  group('RepositoriesScreen Widget Tests', () {
    testWidgets('renders repositories list with cards and user banner', (tester) async {
      stubRepo.result = Success(testRepos);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text("flutterdev's Repositories"), findsOneWidget);
      expect(find.text('@flutterdev'), findsOneWidget);
      expect(find.text('2 Repos'), findsOneWidget);

      // Verify repo cards
      expect(find.byType(RepoCard), findsNWidgets(2));
      expect(find.text('awesome-flutter-app'), findsOneWidget);
      expect(find.text('flutter-state-management'), findsOneWidget);
      expect(find.text('A beautiful Flutter showcase app'), findsOneWidget);
    });

    testWidgets('displays empty state when user has no repositories', (tester) async {
      stubRepo.result = const Success([]);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('No public repositories found'), findsOneWidget);
    });
  });
}
