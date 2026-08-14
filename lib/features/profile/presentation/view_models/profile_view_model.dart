import 'package:flutter/foundation.dart';
import 'package:github_profile_explorer/core/network/api_exceptions.dart';
import 'package:github_profile_explorer/core/network/api_result.dart';
import 'package:github_profile_explorer/features/profile/data/models/github_user.dart';
import 'package:github_profile_explorer/features/profile/data/repositories/user_repository.dart';
import 'package:github_profile_explorer/features/profile/presentation/view_models/recent_searches_view_model.dart';

enum ProfileUiState { initial, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  ProfileUiState _state = ProfileUiState.initial;
  GithubUser? _user;
  AppException? _error;
  String _currentQuery = '';

  ProfileViewModel(this._userRepository);

  ProfileUiState get state => _state;
  GithubUser? get user => _user;
  AppException? get error => _error;
  String get currentQuery => _currentQuery;

  bool get isInitial => _state == ProfileUiState.initial;
  bool get isLoading => _state == ProfileUiState.loading;
  bool get isSuccess => _state == ProfileUiState.success;
  bool get isError => _state == ProfileUiState.error;

  Future<void> searchUser(
    String username, {
    RecentSearchesViewModel? recentSearchesViewModel,
  }) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;

    _currentQuery = trimmed;
    _state = ProfileUiState.loading;
    _error = null;
    notifyListeners();

    final result = await _userRepository.getUserProfile(trimmed);

    switch (result) {
      case Success<GithubUser>(data: final data):
        _user = data;
        _state = ProfileUiState.success;
        _error = null;
        if (recentSearchesViewModel != null) {
          await recentSearchesViewModel.addSearch(data.login);
        }
        break;
      case Failure<GithubUser>(exception: final exception):
        _user = null;
        _error = exception;
        _state = ProfileUiState.error;
        break;
    }

    notifyListeners();
  }

  Future<void> retry({RecentSearchesViewModel? recentSearchesViewModel}) async {
    if (_currentQuery.isNotEmpty) {
      await searchUser(_currentQuery, recentSearchesViewModel: recentSearchesViewModel);
    }
  }

  void clearSearch() {
    _state = ProfileUiState.initial;
    _user = null;
    _error = null;
    _currentQuery = '';
    notifyListeners();
  }
}
