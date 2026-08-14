import 'package:flutter/foundation.dart';
import 'package:github_profile_explorer/core/storage/search_history_storage.dart';

class RecentSearchesViewModel extends ChangeNotifier {
  final SearchHistoryStorage _storage;
  List<String> _searches = [];

  RecentSearchesViewModel(this._storage) {
    loadSearches();
  }

  List<String> get searches => List.unmodifiable(_searches);

  bool get hasSearches => _searches.isNotEmpty;

  void loadSearches() {
    _searches = _storage.getRecentSearches();
    notifyListeners();
  }

  Future<void> addSearch(String username) async {
    if (username.trim().isEmpty) return;
    await _storage.saveSearch(username);
    _searches = _storage.getRecentSearches();
    notifyListeners();
  }

  Future<void> removeSearch(String username) async {
    await _storage.removeSearch(username);
    _searches = _storage.getRecentSearches();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _storage.clearHistory();
    _searches = [];
    notifyListeners();
  }
}
