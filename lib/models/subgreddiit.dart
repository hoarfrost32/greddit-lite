class SubGreddiit {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final List<String> tags;
  final DateTime createdAt;
  final bool isJoined;

  SubGreddiit({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.tags,
    required this.createdAt,
    this.isJoined = false,
  });

  SubGreddiit copyWith({
    String? id,
    String? name,
    String? description,
    int? memberCount,
    List<String>? tags,
    DateTime? createdAt,
    bool? isJoined,
  }) {
    return SubGreddiit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberCount': memberCount,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'isJoined': isJoined,
    };
  }

  factory SubGreddiit.fromJson(Map<String, dynamic> json) {
    return SubGreddiit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      memberCount: json['memberCount'],
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
      isJoined: json['isJoined'] ?? false,
    );
  }
}