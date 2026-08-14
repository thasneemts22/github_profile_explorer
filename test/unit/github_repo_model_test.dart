import 'package:flutter_test/flutter_test.dart';
import 'package:github_profile_explorer/features/repositories/data/models/github_repo.dart';

void main() {
  group('GithubRepo Model Tests', () {
    test('fromJson parses full repository JSON correctly', () {
      final json = {
        'id': 31792824,
        'name': 'flutter',
        'full_name': 'flutter/flutter',
        'description': 'Flutter makes it easy and fast to build beautiful apps for mobile and beyond',
        'html_url': 'https://github.com/flutter/flutter',
        'stargazers_count': 165000,
        'forks_count': 27000,
        'open_issues_count': 5400,
        'language': 'Dart',
        'fork': false,
        'private': false,
        'created_at': '2015-03-06T22:54:58Z',
        'updated_at': '2026-08-14T10:00:00Z',
        'pushed_at': '2026-08-14T09:30:00Z',
        'license': {
          'key': 'bsd-3-clause',
          'name': 'BSD 3-Clause "New" or "Revised" License',
          'spdx_id': 'BSD-3-Clause',
        },
        'default_branch': 'master',
        'topics': ['flutter', 'dart', 'cross-platform', 'mobile'],
      };

      final repo = GithubRepo.fromJson(json);

      expect(repo.id, 31792824);
      expect(repo.name, 'flutter');
      expect(repo.fullName, 'flutter/flutter');
      expect(repo.description, contains('Flutter makes it easy'));
      expect(repo.htmlUrl, 'https://github.com/flutter/flutter');
      expect(repo.stargazersCount, 165000);
      expect(repo.forksCount, 27000);
      expect(repo.openIssuesCount, 5400);
      expect(repo.language, 'Dart');
      expect(repo.isFork, false);
      expect(repo.isPrivate, false);
      expect(repo.licenseName, 'BSD-3-Clause');
      expect(repo.defaultBranch, 'master');
      expect(repo.topics, ['flutter', 'dart', 'cross-platform', 'mobile']);
    });

    test('fromJson handles empty/null description and license', () {
      final json = {
        'id': 999,
        'name': 'empty-repo',
        'full_name': 'user/empty-repo',
        'html_url': 'https://github.com/user/empty-repo',
        'stargazers_count': 0,
        'forks_count': 0,
        'open_issues_count': 0,
        'language': null,
        'fork': false,
        'private': false,
        'license': null,
      };

      final repo = GithubRepo.fromJson(json);

      expect(repo.name, 'empty-repo');
      expect(repo.description, isNull);
      expect(repo.language, isNull);
      expect(repo.licenseName, isNull);
      expect(repo.topics, isEmpty);
      expect(repo.updatedAt, isNull);
    });

    test('toJson and copyWith work properly', () {
      const repo = GithubRepo(
        id: 1,
        name: 'test-repo',
        fullName: 'user/test-repo',
        htmlUrl: 'https://github.com/user/test-repo',
        stargazersCount: 5,
        forksCount: 2,
        openIssuesCount: 1,
        language: 'Dart',
        licenseName: 'MIT',
      );

      final json = repo.toJson();
      expect(json['name'], 'test-repo');
      expect(json['stargazers_count'], 5);
      expect(json['license']['spdx_id'], 'MIT');

      final copy = repo.copyWith(stargazersCount: 10);
      expect(copy.stargazersCount, 10);
      expect(copy.name, 'test-repo');
    });
  });
}
