import 'package:flutter/foundation.dart';
import 'package:github_profile_explorer/core/network/api_exceptions.dart';
import 'package:github_profile_explorer/core/network/api_result.dart';
import 'package:github_profile_explorer/features/repositories/data/models/github_repo.dart';
import 'package:github_profile_explorer/features/repositories/data/repositories/github_repos_repository.dart';

enum RepoUiState { initial, loading, success, error }

enum RepoSortOption {
  starsDesc('Most Stars', 'stars'),
  updatedDesc('Recently Updated', 'updated'),
  nameAsc('Name (A-Z)', 'name'),
  forksDesc('Most Forks', 'forks');

  final String label;
  final String key;
  const RepoSortOption(this.label, this.key);
}

class RepositoriesViewModel extends ChangeNotifier {
  final GithubReposRepository _reposRepository;

  RepoUiState _state = RepoUiState.initial;
  List<GithubRepo> _allRepos = [];
  List<GithubRepo> _filteredRepos = [];
  AppException? _error;
  String _currentUsername = '';
  String _searchFilter = '';
  RepoSortOption _sortOption = RepoSortOption.starsDesc;

  RepositoriesViewModel(this._reposRepository);

  RepoUiState get state => _state;
  List<GithubRepo> get repos => _filteredRepos;
  int get totalRepoCount => _allRepos.length;
  AppException? get error => _error;
  String get currentUsername => _currentUsername;
  String get searchFilter => _searchFilter;
  RepoSortOption get sortOption => _sortOption;

  bool get isLoading => _state == RepoUiState.loading;
  bool get isSuccess => _state == RepoUiState.success;
  bool get isError => _state == RepoUiState.error;
  bool get isEmpty => _state == RepoUiState.success && _filteredRepos.isEmpty;

  Future<void> fetchRepositories(String username) async {
    final clean = username.trim();
    if (clean.isEmpty) return;

    _currentUsername = clean;
    _state = RepoUiState.loading;
    _error = null;
    notifyListeners();

    final result = await _reposRepository.getUserRepositories(clean);

    switch (result) {
      case Success<List<GithubRepo>>(data: final data):
        _allRepos = data;
        _state = RepoUiState.success;
        _error = null;
        _applyFilterAndSort();
        break;
      case Failure<List<GithubRepo>>(exception: final exception):
        _allRepos = [];
        _filteredRepos = [];
        _error = exception;
        _state = RepoUiState.error;
        break;
    }

    notifyListeners();
  }

  void setSortOption(RepoSortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    _applyFilterAndSort();
    notifyListeners();
  }

  void setFilterQuery(String query) {
    _searchFilter = query;
    _applyFilterAndSort();
    notifyListeners();
  }

  void clearFilter() {
    _searchFilter = '';
    _applyFilterAndSort();
    notifyListeners();
  }

  Future<void> retry() async {
    if (_currentUsername.isNotEmpty) {
      await fetchRepositories(_currentUsername);
    }
  }

  void _applyFilterAndSort() {
    List<GithubRepo> list = List.from(_allRepos);

    
    if (_searchFilter.trim().isNotEmpty) {
      final q = _searchFilter.trim().toLowerCase();
      list = list.where((repo) {
        final matchesName = repo.name.toLowerCase().contains(q);
        final matchesDesc = repo.description?.toLowerCase().contains(q) ?? false;
        final matchesLang = repo.language?.toLowerCase().contains(q) ?? false;
        return matchesName || matchesDesc || matchesLang;
      }).toList();
    }

  
    switch (_sortOption) {
      case RepoSortOption.starsDesc:
        list.sort((a, b) => b.stargazersCount.compareTo(a.stargazersCount));
        break;
      case RepoSortOption.updatedDesc:
        list.sort((a, b) {
          if (a.updatedAt == null && b.updatedAt == null) return 0;
          if (a.updatedAt == null) return 1;
          if (b.updatedAt == null) return -1;
          return b.updatedAt!.compareTo(a.updatedAt!);
        });
        break;
      case RepoSortOption.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case RepoSortOption.forksDesc:
        list.sort((a, b) => b.forksCount.compareTo(a.forksCount));
        break;
    }

    _filteredRepos = list;
  }
}
