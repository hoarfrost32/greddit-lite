class Post {
  final String id;
  final String title;
  final String body;
  final String authorName;
  final String subGreddiitId;
  final String subGreddiitName;
  final DateTime createdAt;
  final String? imagePath;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final bool isUpvoted;
  final bool isDownvoted;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.subGreddiitId,
    required this.subGreddiitName,
    required this.createdAt,
    this.imagePath,
    this.upvotes = 0,
    this.downvotes = 0,
    this.commentCount = 0,
    this.isUpvoted = false,
    this.isDownvoted = false,
  });

  Post copyWith({
    String? id,
    String? title,
    String? body,
    String? authorName,
    String? subGreddiitId,
    String? subGreddiitName,
    DateTime? createdAt,
    String? imagePath,
    int? upvotes,
    int? downvotes,
    int? commentCount,
    bool? isUpvoted,
    bool? isDownvoted,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      authorName: authorName ?? this.authorName,
      subGreddiitId: subGreddiitId ?? this.subGreddiitId,
      subGreddiitName: subGreddiitName ?? this.subGreddiitName,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      isUpvoted: isUpvoted ?? this.isUpvoted,
      isDownvoted: isDownvoted ?? this.isDownvoted,
    );
  }

  int get netVotes => upvotes - downvotes;

  bool containsBannedWords(List<String> bannedWords) {
    final content = '$title $body'.toLowerCase();
    return bannedWords.any((word) => content.contains(word.toLowerCase()));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'authorName': authorName,
      'subGreddiitId': subGreddiitId,
      'subGreddiitName': subGreddiitName,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'isUpvoted': isUpvoted,
      'isDownvoted': isDownvoted,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      authorName: json['authorName'],
      subGreddiitId: json['subGreddiitId'],
      subGreddiitName: json['subGreddiitName'],
      createdAt: DateTime.parse(json['createdAt']),
      imagePath: json['imagePath'],
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isUpvoted: json['isUpvoted'] ?? false,
      isDownvoted: json['isDownvoted'] ?? false,
    );
  }
}