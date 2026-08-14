import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:github_profile_explorer/core/storage/search_history_storage.dart';

void main() {
  group('SearchHistoryStorage Tests', () {
    late SearchHistoryStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = SearchHistoryStorage(prefs);
    });

    test('initially returns empty search history', () {
      expect(storage.getRecentSearches(), isEmpty);
    });

    test('saves search and places latest at index 0', () async {
      await storage.saveSearch('flutter');
      await storage.saveSearch('dart-lang');

      final searches = storage.getRecentSearches();
      expect(searches.length, 2);
      expect(searches[0], 'dart-lang');
      expect(searches[1], 'flutter');
    });

    test('deduplicates case-insensitively and promotes to top', () async {
      await storage.saveSearch('flutter');
      await storage.saveSearch('google');
      await storage.saveSearch('Flutter'); // duplicate with different casing

      final searches = storage.getRecentSearches();
      expect(searches.length, 2);
      expect(searches[0], 'Flutter');
      expect(searches[1], 'google');
    });

    test('caps recent searches to maximum of 5', () async {
      await storage.saveSearch('user1');
      await storage.saveSearch('user2');
      await storage.saveSearch('user3');
      await storage.saveSearch('user4');
      await storage.saveSearch('user5');
      await storage.saveSearch('user6');

      final searches = storage.getRecentSearches();
      expect(searches.length, 5);
      expect(searches.first, 'user6');
      expect(searches.contains('user1'), isFalse);
    });

    test('removes specific search item', () async {
      await storage.saveSearch('alpha');
      await storage.saveSearch('beta');
      await storage.removeSearch('alpha');

      final searches = storage.getRecentSearches();
      expect(searches.length, 1);
      expect(searches.first, 'beta');
    });

    test('clears entire history', () async {
      await storage.saveSearch('alpha');
      await storage.saveSearch('beta');
      await storage.clearHistory();

      expect(storage.getRecentSearches(), isEmpty);
    });
  });
}
