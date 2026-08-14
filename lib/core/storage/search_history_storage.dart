import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SearchHistoryStorage {
  final SharedPreferences _prefs;

  SearchHistoryStorage(this._prefs);

  static Future<SearchHistoryStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SearchHistoryStorage(prefs);
  }

  List<String> getRecentSearches() {
    return _prefs.getStringList(AppConstants.recentSearchesKey) ?? [];
  }

  Future<bool> saveSearch(String username) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty) return false;

    final current = getRecentSearches();
  
    final updated = current
        .where((item) => item.toLowerCase() != cleanUsername.toLowerCase())
        .toList();

    
    updated.insert(0, cleanUsername);

    
    final trimmed = updated.take(AppConstants.maxRecentSearches).toList();
    return _prefs.setStringList(AppConstants.recentSearchesKey, trimmed);
  }

  Future<bool> removeSearch(String username) async {
    final current = getRecentSearches();
    final updated = current
        .where((item) => item.toLowerCase() != username.trim().toLowerCase())
        .toList();
    return _prefs.setStringList(AppConstants.recentSearchesKey, updated);
  }

  Future<bool> clearHistory() async {
    return _prefs.remove(AppConstants.recentSearchesKey);
  }
}
