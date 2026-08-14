import 'package:github_profile_explorer/core/network/api_client.dart';
import 'package:github_profile_explorer/core/network/api_exceptions.dart';
import 'package:github_profile_explorer/core/network/api_result.dart';
import 'package:github_profile_explorer/features/repositories/data/models/github_repo.dart';

abstract class GithubReposRepository {
  Future<ApiResult<List<GithubRepo>>> getUserRepositories(
    String username, {
    int perPage = 100,
  });
}

class GithubReposRepositoryImpl implements GithubReposRepository {
  final ApiClient _apiClient;

  GithubReposRepositoryImpl(this._apiClient);

  @override
  Future<ApiResult<List<GithubRepo>>> getUserRepositories(
    String username, {
    int perPage = 100,
  }) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty) {
      return const Failure(NotFoundException('Username cannot be empty.'));
    }

    try {
      final response = await _apiClient.get(
        '/users/$cleanUsername/repos',
        queryParameters: {
          'per_page': perPage,
          'sort': 'updated',
        },
      );

      if (response.data is List) {
        final list = (response.data as List)
            .map((item) => GithubRepo.fromJson(item as Map<String, dynamic>))
            .toList();
        return Success(list);
      }

      return const Failure(UnknownException('Invalid response format for repositories.'));
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }
}
