import 'package:flutter/foundation.dart';

@immutable
class GithubUser {
  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  final String? name;
  final String? company;
  final String? blog;
  final String? location;
  final String? email;
  final bool? hireable;
  final String? bio;
  final String? twitterUsername;
  final int publicRepos;
  final int publicGists;
  final int followers;
  final int following;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String type;

  const GithubUser({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    this.name,
    this.company,
    this.blog,
    this.location,
    this.email,
    this.hireable,
    this.bio,
    this.twitterUsername,
    required this.publicRepos,
    required this.publicGists,
    required this.followers,
    required this.following,
    this.createdAt,
    this.updatedAt,
    this.type = 'User',
  });

  String get displayName => (name != null && name!.trim().isNotEmpty) ? name! : login;

  String? get cleanBlogUrl {
    if (blog == null || blog!.trim().isEmpty) return null;
    final trimmed = blog!.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  factory GithubUser.fromJson(Map<String, dynamic> json) {
    return GithubUser(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      login: json['login'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      name: json['name'] as String?,
      company: json['company'] as String?,
      blog: json['blog'] as String?,
      location: json['location'] as String?,
      email: json['email'] as String?,
      hireable: json['hireable'] as bool?,
      bio: json['bio'] as String?,
      twitterUsername: json['twitter_username'] as String?,
      publicRepos: json['public_repos'] is int
          ? json['public_repos'] as int
          : int.tryParse(json['public_repos']?.toString() ?? '0') ?? 0,
      publicGists: json['public_gists'] is int
          ? json['public_gists'] as int
          : int.tryParse(json['public_gists']?.toString() ?? '0') ?? 0,
      followers: json['followers'] is int
          ? json['followers'] as int
          : int.tryParse(json['followers']?.toString() ?? '0') ?? 0,
      following: json['following'] is int
          ? json['following'] as int
          : int.tryParse(json['following']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      type: json['type'] as String? ?? 'User',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'name': name,
      'company': company,
      'blog': blog,
      'location': location,
      'email': email,
      'hireable': hireable,
      'bio': bio,
      'twitter_username': twitterUsername,
      'public_repos': publicRepos,
      'public_gists': publicGists,
      'followers': followers,
      'following': following,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type': type,
    };
  }

  GithubUser copyWith({
    int? id,
    String? login,
    String? avatarUrl,
    String? htmlUrl,
    String? name,
    String? company,
    String? blog,
    String? location,
    String? email,
    bool? hireable,
    String? bio,
    String? twitterUsername,
    int? publicRepos,
    int? publicGists,
    int? followers,
    int? following,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
  }) {
    return GithubUser(
      id: id ?? this.id,
      login: login ?? this.login,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      name: name ?? this.name,
      company: company ?? this.company,
      blog: blog ?? this.blog,
      location: location ?? this.location,
      email: email ?? this.email,
      hireable: hireable ?? this.hireable,
      bio: bio ?? this.bio,
      twitterUsername: twitterUsername ?? this.twitterUsername,
      publicRepos: publicRepos ?? this.publicRepos,
      publicGists: publicGists ?? this.publicGists,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GithubUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          login == other.login;

  @override
  int get hashCode => id.hashCode ^ login.hashCode;

  @override
  String toString() => 'GithubUser(login: $login, name: $name, repos: $publicRepos, followers: $followers)';
}
