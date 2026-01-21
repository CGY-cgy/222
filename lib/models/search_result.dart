/// 搜索结果模型
class SearchResult {
  final String type; // 'post', 'recipe', 'knowledge'
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final Map<String, dynamic>? meta; // 元数据（作者、时间、点赞数等）

  SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.meta,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      type: json['type'] as String,
      id: json['postId']?.toString() ?? json['recipeId']?.toString() ?? '',
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
}

