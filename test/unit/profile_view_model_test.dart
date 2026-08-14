import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:github_profile_explorer/core/network/api_exceptions.dart';
import 'package:github_profile_explorer/core/network/api_result.dart';
import 'package:github_profile_explorer/core/storage/search_history_storage.dart';
import 'package:github_profile_explorer/features/profile/data/models/github_user.dart';
import 'package:github_profile_explorer/features/profile/data/repositories/user_repository.dart';
import 'package:github_profile_explorer/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:github_profile_explorer/features/profile/presentation/view_models/recent_searches_view_model.dart';

class MockUserRepository implements UserRepository {
  ApiResult<GithubUser>? stubbedResult;

  @override
  Future<ApiResult<GithubUser>> getUserProfile(String username) async {
    if (stubbedResult != null) {
      return stubbedResult!;
    }
    return const Failure(NotFoundException());
  }
}

void main() {
  group('ProfileViewModel Tests', () {
    late MockUserRepository mockRepo;
    late ProfileViewModel viewModel;
    late RecentSearchesViewModel historyViewModel;

    const testUser = GithubUser(
      id: 1,
      login: 'flutter',
      avatarUrl: 'https://avatars.githubusercontent.com/u/1',
      htmlUrl: 'https://github.com/flutter',
      name: 'Flutter Framework',
      publicRepos: 42,
      publicGists: 5,
      followers: 120000,
      following: 0,
    );

    setUp(() async {
      mockRepo = MockUserRepository();
      viewModel = ProfileViewModel(mockRepo);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SearchHistoryStorage(prefs);
      historyViewModel = RecentSearchesViewModel(storage);
    });

    test('initial state is ProfileUiState.initial', () {
      expect(viewModel.state, ProfileUiState.initial);
      expect(viewModel.isInitial, isTrue);
      expect(viewModel.user, isNull);
      expect(viewModel.error, isNull);
    });

    test('successful search transitions through loading to success and saves to history', () async {
      mockRepo.stubbedResult = const Success(testUser);

      final future = viewModel.searchUser(
        'flutter',
        recentSearchesViewModel: historyViewModel,
      );

      expect(viewModel.state, ProfileUiState.loading);
      expect(viewModel.isLoading, isTrue);

      await future;

      expect(viewModel.state, ProfileUiState.success);
      expect(viewModel.isSuccess, isTrue);
      expect(viewModel.user, testUser);
      expect(viewModel.error, isNull);

      // Verify added to recent searches
      expect(historyViewModel.searches.contains('flutter'), isTrue);
    });

    test('failed search transitions through loading to error state', () async {
      mockRepo.stubbedResult = const Failure(NotFoundException('User not found'));

      final future = viewModel.searchUser(
        'unknown_user_999',
        recentSearchesViewModel: historyViewModel,
      );

      expect(viewModel.state, ProfileUiState.loading);

      await future;

      expect(viewModel.state, ProfileUiState.error);
      expect(viewModel.isError, isTrue);
      expect(viewModel.user, isNull);
      expect(viewModel.error, isA<NotFoundException>());
    });

    test('clearSearch resets state back to initial', () async {
      mockRepo.stubbedResult = const Success(testUser);
      await viewModel.searchUser('flutter');

      expect(viewModel.isSuccess, isTrue);

      viewModel.clearSearch();

      expect(viewModel.state, ProfileUiState.initial);
      expect(viewModel.user, isNull);
      expect(viewModel.error, isNull);
      expect(viewModel.currentQuery, isEmpty);
    });
  });
}
