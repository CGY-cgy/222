import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/mock_service.dart';
import '../constants/app_colors.dart';
import 'post_detail_page.dart';
import 'ai_chat_page.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({Key? key}) : super(key: key);

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Post> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 加载帖子 - 切换Tab回来时也会触发，确保读取的是 MockService 里的最新静态数据
  Future<void> _loadPosts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final posts = await MockService.getPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 处理点赞逻辑 - 这里的关键是调用修改后的 MockService.toggleLike
  Future<void> _handleLike(Post post) async {
    final bool targetStatus = !post.isLiked;

    // 1. 立即更新界面反馈（顺滑交互）
    setState(() {
      post.isLiked = targetStatus;
      post.likes += targetStatus ? 1 : -1;
    });

    // 2. 同步到 MockService 的静态数据源，确保切换 Tab 不丢失
    await MockService.toggleLike(post.id, targetStatus);
  }

  /// 跳转详情页 - 使用 await 等待返回后刷新列表
  void _handleGoDetail(Post post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
    );
    // 从详情页返回后，强制刷新当前列表 UI 状态
    // 因为 PostDetailPage 和这里共用一个 post 对象引用，
    // 详情页的修改会直接反映在对象上，setState 会同步 UI
    if (mounted) setState(() {});
  }

  /// 分享面板
  void _handleShare(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('分享帖子', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareTypeItem(Icons.wechat, '微信', Colors.green),
                _buildShareTypeItem(Icons.alternate_email, '朋友圈', Colors.greenAccent),
                _buildShareTypeItem(Icons.copy, '复制链接', Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareTypeItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        title: const Text('灵境智能助手'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.graySecondary,
          tabs: const [
            Tab(text: '社区', icon: Icon(Icons.people_outline)),
            Tab(text: 'AI对话', icon: Icon(Icons.chat_bubble_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCommunityFeed(), const AIChatPage()],
      ),
    );
  }

  Widget _buildCommunityFeed() {
    if (_isLoading && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (_posts.isEmpty) {
      return const Center(child: Text('暂无动态', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) => _buildPostCard(_posts[index]),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 4), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleGoDetail(post),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryBlueLight,
                        backgroundImage: post.authorAvatar.isNotEmpty ? NetworkImage(post.authorAvatar) : null,
                        child: post.authorAvatar.isEmpty ? Text(post.authorName[0]) : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(_formatTime(post.publishTime), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(post.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(post.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, height: 1.4)),

                  if (post.images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.images.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              post.images[index],
                              width: 240,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 240,
                                color: Colors.grey[100],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                        label: '${post.likes}',
                        // 修正：点赞时显示红色，否则显示灰色
                        color: post.isLiked ? Colors.red : Colors.grey[600],
                        onTap: () => _handleLike(post),
                      ),
                      const SizedBox(width: 24),
                      _buildActionButton(
                          icon: Icons.comment_outlined,
                          label: '${post.comments}',
                          color: Colors.grey[600], // 修正：传入 color 参数
                          onTap: () => _handleGoDetail(post)
                      ),
                      const SizedBox(width: 24),
                      _buildActionButton(
                          icon: Icons.share_outlined,
                          label: '${post.shares}',
                          color: Colors.grey[600], // 修正：传入 color 参数
                          onTap: () => _handleShare(post)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, Color? color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}天前';
    if (diff.inHours > 0) return '${diff.inHours}小时前';
    if (diff.inMinutes > 0) return '${diff.inMinutes}分钟前';
    return '刚刚';
  }
}