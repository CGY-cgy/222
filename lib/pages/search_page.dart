import 'package:flutter/material.dart';
import '../services/mock_service.dart';
import '../models/post.dart';
import '../constants/app_colors.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_text.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import 'post_detail_page.dart';
import 'diet_page.dart';

/// 搜索页面
/// 
/// 功能：
/// 1. 搜索输入
/// 2. 标签切换（全部、帖子、食谱、健康知识）
/// 3. 搜索结果展示
class SearchPage extends StatefulWidget {
  final String? initialKeyword;

  const SearchPage({Key? key, this.initialKeyword}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'all'; // 'all', 'post', 'recipe', 'knowledge'
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialKeyword != null) {
      _searchController.text = widget.initialKeyword!;
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 执行搜索
  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final response = await MockService.search(
        keyword,
        type: _selectedType,
      );
      final data = response['data'] as Map<String, dynamic>;
      setState(() {
        _results = List<Map<String, dynamic>>.from(data['results'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchBar(),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildSearchTabs(),
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: '搜索中...')
                : _hasSearched
                    ? _buildResults()
                    : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  /// 搜索栏
  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grayDivider),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: '搜索帖子、食谱、健康知识...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.graySecondary,
              ),
          prefixIcon: const Icon(Icons.search, color: AppColors.graySecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        onSubmitted: (_) => _performSearch(),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  /// 搜索标签
  Widget _buildSearchTabs() {
    final tabs = [
      {'label': '全部', 'type': 'all'},
      {'label': '帖子', 'type': 'post'},
      {'label': '食谱', 'type': 'recipe'},
      {'label': '健康知识', 'type': 'knowledge'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isActive = _selectedType == tab['type'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedType = tab['type'] as String);
                    if (_searchController.text.trim().isNotEmpty) {
                      _performSearch();
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryBlue : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tab['label'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isActive ? AppColors.white : AppColors.graySecondary,
                          ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 搜索结果
  Widget _buildResults() {
    if (_results.isEmpty) {
      return const EmptyStateWidget(
        title: '暂无结果',
        subtitle: '试试其他关键词吧',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return _buildResultItem(_results[index]);
      },
    );
  }

  /// 结果项
  Widget _buildResultItem(Map<String, dynamic> result) {
    final type = result['type'] as String;
    final title = result['title'] as String;
    final content = result['content'] as String;
    final imageUrl = result['imageUrl'] as String?;
    final meta = result['meta'] as Map<String, dynamic>?;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _handleResultTap(result),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 类型标签
          _buildTypeTag(type),
          const SizedBox(height: 8),
          // 标题
          AppText.bodyLarge(title),
          const SizedBox(height: 8),
          // 内容
          AppText.bodySmall(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // 图片
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: AppColors.grayBackground,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.graySecondary,
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          // 元数据
          _buildMeta(meta, type),
        ],
      ),
    );
  }

  /// 类型标签
  Widget _buildTypeTag(String type) {
    final config = {
      'post': {'label': '帖子', 'color': const Color(0xFF4a7fa8), 'bg': const Color(0xFFe3f0f7)},
      'recipe': {'label': '食谱', 'color': const Color(0xFF8a6f5a), 'bg': const Color(0xFFf0e8e0)},
      'knowledge': {'label': '健康知识', 'color': const Color(0xFF5a8a6f), 'bg': const Color(0xFFe8f0ea)},
    };

    final item = config[type] ?? config['post']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: item['bg'] as Color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        item['label'] as String,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: item['color'] as Color,
              fontSize: 12,
            ),
      ),
    );
  }

  /// 元数据
  Widget _buildMeta(Map<String, dynamic>? meta, String type) {
    if (meta == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (type == 'post') ...[
          if (meta['author'] != null) ...[
            Icon(Icons.person_outline, size: 14, color: AppColors.graySecondary),
            const SizedBox(width: 4),
            AppText.bodySmall(meta['author'] as String),
            const SizedBox(width: 16),
          ],
          if (meta['time'] != null) ...[
            Icon(Icons.access_time, size: 14, color: AppColors.graySecondary),
            const SizedBox(width: 4),
            AppText.bodySmall(_formatTime(meta['time'] as String)),
            const SizedBox(width: 16),
          ],
          if (meta['likes'] != null) ...[
            Icon(Icons.favorite_outline, size: 14, color: AppColors.graySecondary),
            const SizedBox(width: 4),
            AppText.bodySmall('${meta['likes']}'),
          ],
        ] else if (type == 'recipe') ...[
          if (meta['calories'] != null) ...[
            Icon(Icons.local_fire_department, size: 14, color: AppColors.graySecondary),
            const SizedBox(width: 4),
            AppText.bodySmall('${meta['calories']} 卡路里'),
            const SizedBox(width: 16),
          ],
          if (meta['time'] != null) ...[
            Icon(Icons.access_time, size: 14, color: AppColors.graySecondary),
            const SizedBox(width: 4),
            AppText.bodySmall(meta['time'] as String),
          ],
        ] else if (type == 'knowledge') ...[
          if (meta['views'] != null) ...[
            Icon(Icons.visibility_outlined, size: 14, color: AppColors.graySecondary),
            const SizedBox(width: 4),
            AppText.bodySmall('${meta['views']} 阅读'),
          ],
        ],
      ],
    );
  }

  /// 处理结果点击
  void _handleResultTap(Map<String, dynamic> result) async {
    final type = result['type'] as String;
    final id = result['postId']?.toString() ?? 
               result['recipeId']?.toString() ?? 
               result['knowledgeId']?.toString();

    if (type == 'post' && id != null) {
      // TODO: 根据postId获取完整帖子信息
      try {
        final post = await MockService.getPostDetail(id);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载失败，请重试')),
        );
      }
    } else if (type == 'recipe') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DietPage()),
      );
    }
    // knowledge类型暂不处理
  }

  /// 格式化时间
  String _formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      final now = DateTime.now();
      final difference = now.difference(time);
      if (difference.inDays > 0) return '${difference.inDays}天前';
      if (difference.inHours > 0) return '${difference.inHours}小时前';
      if (difference.inMinutes > 0) return '${difference.inMinutes}分钟前';
      return '刚刚';
    } catch (e) {
      return timeStr;
    }
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: AppColors.graySecondary),
          const SizedBox(height: 16),
          AppText.displaySmall('开始搜索'),
          const SizedBox(height: 8),
          AppText.bodySmall('输入关键词搜索帖子、食谱、健康知识'),
        ],
      ),
    );
  }
}

