class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String title;
  final String content;
  final List<String> images;
  final List<String> videos;
  final List<String> tags;
  int likes;
  int comments;     // 修正：去掉 final，改为可变以支持本地 UI 快速更新
  final int shares;
  bool isLiked;
  final DateTime publishTime;
  final bool isPublic;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.title,
    required this.content,
    this.images = const [],
    this.videos = const [],
    this.tags = const [],
    this.likes = 0,
    this.comments = 0, // 修正：移除 constructor 中重复定义的 comments
    this.shares = 0,
    this.isLiked = false,
    required this.publishTime,
    this.isPublic = true,
  });

  // 完善 copyWith，确保所有必要字段都包含在内
  Post copyWith({
    int? likes,
    bool? isLiked,
    int? comments,
  }) {
    return Post(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      title: title,
      content: content,
      images: images,
      videos: videos,
      tags: tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares,
      isLiked: isLiked ?? this.isLiked,
      publishTime: publishTime,
      isPublic: isPublic,
    );
  }

  // 确保 toJson 定义正确，解决 MockService 中的调用报错
  Map<String, dynamic> toJson() {
    return {
      'postId': id, // 文档中使用 postId
      'authorName': authorName,
      'avatar': authorAvatar, // 文档中使用 avatar
      'title': title,
      'content': content,
      'images': images,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
      'createTime': publishTime.toIso8601String(), // 对齐文档字段名
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? '未知用户',
      authorAvatar: json['authorAvatar']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      videos: (json['videos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      publishTime: json['publishTime'] != null
          ? DateTime.parse(json['publishTime'])
          : DateTime.now(),
      isPublic: json['isPublic'] as bool? ?? true,
    );
  }
}