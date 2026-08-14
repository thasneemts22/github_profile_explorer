import 'package:github_profile_explorer/core/network/api_client.dart';
import 'package:github_profile_explorer/core/network/api_exceptions.dart';
import 'package:github_profile_explorer/core/network/api_result.dart';
import 'package:github_profile_explorer/features/profile/data/models/github_user.dart';

abstract class UserRepository {
  Future<ApiResult<GithubUser>> getUserProfile(String username);
}

class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;

  UserRepositoryImpl(this._apiClient);

  @override
  Future<ApiResult<GithubUser>> getUserProfile(String username) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty) {
      return const Failure(NotFoundException('Username cannot be empty.'));
    }

    try {
      final response = await _apiClient.get('/users/$cleanUsername');
      if (response.data is Map<String, dynamic>) {
        final user = GithubUser.fromJson(response.data as Map<String, dynamic>);
        return Success(user);
      }
      return const Failure(UnknownException('Invalid response format from GitHub.'));
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }
}
