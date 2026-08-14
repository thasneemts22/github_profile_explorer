import 'package:flutter/foundation.dart';

@immutable
class GithubRepo {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final String htmlUrl;
  final int stargazersCount;
  final int forksCount;
  final int openIssuesCount;
  final String? language;
  final bool isFork;
  final bool isPrivate;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final DateTime? pushedAt;
  final String? licenseName;
  final String? defaultBranch;
  final List<String> topics;

  const GithubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.htmlUrl,
    required this.stargazersCount,
    required this.forksCount,
    required this.openIssuesCount,
    this.language,
    this.isFork = false,
    this.isPrivate = false,
    this.updatedAt,
    this.createdAt,
    this.pushedAt,
    this.licenseName,
    this.defaultBranch,
    this.topics = const [],
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    String? license;
    if (json['license'] is Map<String, dynamic>) {
      final licMap = json['license'] as Map<String, dynamic>;
      license = (licMap['spdx_id'] != null && licMap['spdx_id'] != 'NOASSERTION')
          ? licMap['spdx_id'] as String?
          : licMap['name'] as String?;
    }

    List<String> topicsList = [];
    if (json['topics'] is List) {
      topicsList = (json['topics'] as List).map((e) => e.toString()).toList();
    }

    return GithubRepo(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      description: json['description'] as String?,
      htmlUrl: json['html_url'] as String? ?? '',
      stargazersCount: json['stargazers_count'] is int
          ? json['stargazers_count'] as int
          : int.tryParse(json['stargazers_count']?.toString() ?? '0') ?? 0,
      forksCount: json['forks_count'] is int
          ? json['forks_count'] as int
          : int.tryParse(json['forks_count']?.toString() ?? '0') ?? 0,
      openIssuesCount: json['open_issues_count'] is int
          ? json['open_issues_count'] as int
          : int.tryParse(json['open_issues_count']?.toString() ?? '0') ?? 0,
      language: json['language'] as String?,
      isFork: json['fork'] as bool? ?? false,
      isPrivate: json['private'] as bool? ?? false,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      pushedAt: json['pushed_at'] != null ? DateTime.tryParse(json['pushed_at'] as String) : null,
      licenseName: license,
      defaultBranch: json['default_branch'] as String?,
      topics: topicsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'html_url': htmlUrl,
      'stargazers_count': stargazersCount,
      'forks_count': forksCount,
      'open_issues_count': openIssuesCount,
      'language': language,
      'fork': isFork,
      'private': isPrivate,
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'pushed_at': pushedAt?.toIso8601String(),
      'license': licenseName != null ? {'spdx_id': licenseName} : null,
      'default_branch': defaultBranch,
      'topics': topics,
    };
  }

  GithubRepo copyWith({
    int? id,
    String? name,
    String? fullName,
    String? description,
    String? htmlUrl,
    int? stargazersCount,
    int? forksCount,
    int? openIssuesCount,
    String? language,
    bool? isFork,
    bool? isPrivate,
    DateTime? updatedAt,
    DateTime? createdAt,
    DateTime? pushedAt,
    String? licenseName,
    String? defaultBranch,
    List<String>? topics,
  }) {
    return GithubRepo(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      description: description ?? this.description,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      stargazersCount: stargazersCount ?? this.stargazersCount,
      forksCount: forksCount ?? this.forksCount,
      openIssuesCount: openIssuesCount ?? this.openIssuesCount,
      language: language ?? this.language,
      isFork: isFork ?? this.isFork,
      isPrivate: isPrivate ?? this.isPrivate,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      pushedAt: pushedAt ?? this.pushedAt,
      licenseName: licenseName ?? this.licenseName,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      topics: topics ?? this.topics,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GithubRepo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'GithubRepo(name: $name, stars: $stargazersCount, language: $language)';
}
