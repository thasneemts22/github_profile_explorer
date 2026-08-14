import 'package:flutter_test/flutter_test.dart';
import 'package:github_profile_explorer/features/profile/data/models/github_user.dart';

void main() {
  group('GithubUser Model Tests', () {
    test('fromJson parses complete GitHub user JSON correctly', () {
      final json = {
        'login': 'octocat',
        'id': 583231,
        'node_id': 'MDQ6VXNlcjU4MzIzMQ==',
        'avatar_url': 'https://avatars.githubusercontent.com/u/583231?v=4',
        'html_url': 'https://github.com/octocat',
        'name': 'The Octocat',
        'company': '@github',
        'blog': 'https://github.blog',
        'location': 'San Francisco',
        'email': 'octocat@github.com',
        'hireable': true,
        'bio': 'Building the future of software.',
        'twitter_username': 'octocat',
        'public_repos': 8,
        'public_gists': 4,
        'followers': 12500,
        'following': 9,
        'created_at': '2011-01-25T18:44:36Z',
        'updated_at': '2024-03-01T12:00:00Z',
        'type': 'User',
      };

      final user = GithubUser.fromJson(json);

      expect(user.id, 583231);
      expect(user.login, 'octocat');
      expect(user.name, 'The Octocat');
      expect(user.displayName, 'The Octocat');
      expect(user.avatarUrl, 'https://avatars.githubusercontent.com/u/583231?v=4');
      expect(user.htmlUrl, 'https://github.com/octocat');
      expect(user.company, '@github');
      expect(user.blog, 'https://github.blog');
      expect(user.cleanBlogUrl, 'https://github.blog');
      expect(user.location, 'San Francisco');
      expect(user.email, 'octocat@github.com');
      expect(user.hireable, true);
      expect(user.bio, 'Building the future of software.');
      expect(user.twitterUsername, 'octocat');
      expect(user.publicRepos, 8);
      expect(user.publicGists, 4);
      expect(user.followers, 12500);
      expect(user.following, 9);
      expect(user.createdAt, DateTime.parse('2011-01-25T18:44:36Z'));
      expect(user.type, 'User');
    });

    test('fromJson handles missing / null optional fields gracefully', () {
      final json = {
        'login': 'minimal_user',
        'id': 12345,
        'avatar_url': 'https://avatars.githubusercontent.com/u/12345',
        'html_url': 'https://github.com/minimal_user',
        'public_repos': 0,
        'public_gists': 0,
        'followers': 0,
        'following': 0,
      };

      final user = GithubUser.fromJson(json);

      expect(user.login, 'minimal_user');
      expect(user.name, isNull);
      expect(user.displayName, 'minimal_user');
      expect(user.bio, isNull);
      expect(user.company, isNull);
      expect(user.blog, isNull);
      expect(user.cleanBlogUrl, isNull);
      expect(user.hireable, isNull);
      expect(user.twitterUsername, isNull);
      expect(user.createdAt, isNull);
      expect(user.type, 'User');
    });

    test('cleanBlogUrl prepends https:// if scheme is omitted', () {
      final json = {
        'login': 'webdev',
        'id': 1,
        'avatar_url': '',
        'html_url': '',
        'blog': 'mysite.dev',
        'public_repos': 0,
        'public_gists': 0,
        'followers': 0,
        'following': 0,
      };

      final user = GithubUser.fromJson(json);
      expect(user.cleanBlogUrl, 'https://mysite.dev');
    });

    test('toJson and copyWith work as expected', () {
      const user = GithubUser(
        id: 100,
        login: 'coder',
        avatarUrl: 'https://avatar.png',
        htmlUrl: 'https://github.com/coder',
        name: 'Jane Coder',
        publicRepos: 10,
        publicGists: 2,
        followers: 50,
        following: 20,
      );

      final json = user.toJson();
      expect(json['login'], 'coder');
      expect(json['name'], 'Jane Coder');
      expect(json['public_repos'], 10);

      final updated = user.copyWith(publicRepos: 15, followers: 60);
      expect(updated.publicRepos, 15);
      expect(updated.followers, 60);
      expect(updated.login, 'coder');
    });
  });
}
