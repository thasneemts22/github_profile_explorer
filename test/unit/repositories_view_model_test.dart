import 'package:flutter_test/flutter_test.dart';
import 'package:github_profile_explorer/core/network/api_result.dart';
import 'package:github_profile_explorer/features/repositories/data/models/github_repo.dart';
import 'package:github_profile_explorer/features/repositories/data/repositories/github_repos_repository.dart';
import 'package:github_profile_explorer/features/repositories/presentation/view_models/repositories_view_model.dart';

class MockGithubReposRepository implements GithubReposRepository {
  ApiResult<List<GithubRepo>>? stubbedResult;

  @override
  Future<ApiResult<List<GithubRepo>>> getUserRepositories(
    String username, {
    int perPage = 100,
  }) async {
    if (stubbedResult != null) return stubbedResult!;
    return const Success([]);
  }
}

void main() {
  group('RepositoriesViewModel Tests', () {
    late MockGithubReposRepository mockRepo;
    late RepositoriesViewModel viewModel;

    final repoAlpha = GithubRepo(
      id: 1,
      name: 'Alpha',
      fullName: 'user/Alpha',
      description: 'Alpha toolkit in Dart',
      htmlUrl: 'https://github.com/user/Alpha',
      stargazersCount: 50,
      forksCount: 5,
      openIssuesCount: 0,
      language: 'Dart',
      updatedAt: DateTime(2025, 1, 1),
    );

    final repoBeta = GithubRepo(
      id: 2,
      name: 'Beta',
      fullName: 'user/Beta',
      description: 'Beta machine learning in Python',
      htmlUrl: 'https://github.com/user/Beta',
      stargazersCount: 200,
      forksCount: 20,
      openIssuesCount: 2,
      language: 'Python',
      updatedAt: DateTime(2026, 6, 1),
    );

    final repoGamma = GithubRepo(
      id: 3,
      name: 'Gamma',
      fullName: 'user/Gamma',
      description: 'Gamma web app in TypeScript',
      htmlUrl: 'https://github.com/user/Gamma',
      stargazersCount: 10,
      forksCount: 1,
      openIssuesCount: 1,
      language: 'TypeScript',
      updatedAt: DateTime(2024, 3, 1),
    );

    setUp(() {
      mockRepo = MockGithubReposRepository();
      viewModel = RepositoriesViewModel(mockRepo);
    });

    test('fetches and sorts by stars descending by default', () async {
      mockRepo.stubbedResult = Success([repoAlpha, repoBeta, repoGamma]);

      await viewModel.fetchRepositories('user');

      expect(viewModel.isSuccess, isTrue);
      expect(viewModel.repos.length, 3);
      // Beta (200) -> Alpha (50) -> Gamma (10)
      expect(viewModel.repos[0].name, 'Beta');
      expect(viewModel.repos[1].name, 'Alpha');
      expect(viewModel.repos[2].name, 'Gamma');
    });

    test('sorts by recently updated correctly', () async {
      mockRepo.stubbedResult = Success([repoAlpha, repoBeta, repoGamma]);
      await viewModel.fetchRepositories('user');

      viewModel.setSortOption(RepoSortOption.updatedDesc);

      // Beta (2026) -> Alpha (2025) -> Gamma (2024)
      expect(viewModel.repos[0].name, 'Beta');
      expect(viewModel.repos[1].name, 'Alpha');
      expect(viewModel.repos[2].name, 'Gamma');
    });

    test('sorts by name ascending (A-Z) correctly', () async {
      mockRepo.stubbedResult = Success([repoBeta, repoGamma, repoAlpha]);
      await viewModel.fetchRepositories('user');

      viewModel.setSortOption(RepoSortOption.nameAsc);

      expect(viewModel.repos[0].name, 'Alpha');
      expect(viewModel.repos[1].name, 'Beta');
      expect(viewModel.repos[2].name, 'Gamma');
    });

    test('filters repositories by query string in name, desc, or language', () async {
      mockRepo.stubbedResult = Success([repoAlpha, repoBeta, repoGamma]);
      await viewModel.fetchRepositories('user');

      // Filter by language 'Python'
      viewModel.setFilterQuery('Python');
      expect(viewModel.repos.length, 1);
      expect(viewModel.repos.first.name, 'Beta');

      // Filter by keyword 'toolkit'
      viewModel.setFilterQuery('toolkit');
      expect(viewModel.repos.length, 1);
      expect(viewModel.repos.first.name, 'Alpha');

      // Clear filter
      viewModel.clearFilter();
      expect(viewModel.repos.length, 3);
    });
  });
}
