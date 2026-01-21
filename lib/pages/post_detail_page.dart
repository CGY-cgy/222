import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../services/mock_service.dart';
import '../../services/api_service.dart'; // 导入 ApiService
import '../../constants/app_colors.dart'; // 导入你的颜色常量

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Post _currentPost;
  bool _isLoading = false;

  // 1. 添加评论输入控制器
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _loadPostDetail();
  }

  @override
  void dispose() {
    _commentController.dispose(); // 记得销毁控制器
    super.dispose();
  }

  Future<void> _loadPostDetail() async {
    setState(() => _isLoading = true);
    try {
      final post = await MockService.getPostDetail(widget.post.id);
      setState(() {
        _currentPost = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // 2. 发布评论的核心逻辑 (对接 ApiService)
  Future<void> _handlePublishComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);

    try {
      // 调用我们之前配置好的 API 路由
      final response = await ApiService().post('/posts/comment', data: {
        'postId': _currentPost.id,
        'content': content,
      });

      final result = ApiService().handleResponse(response);

      if (mounted && result != null) {
        // 评论成功后的反馈
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('评论成功，福报+1')),
        );

        _commentController.clear(); // 清空输入框
        Navigator.pop(context); // 关闭弹出的输入框

        // 本地模拟增加评论数
        setState(() {
          _currentPost = _currentPost.copyWith(
            comments: _currentPost.comments + 1,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('评论失败: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // 3. 弹出评论输入弹窗
  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许弹窗随键盘升高
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // 避开键盘
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _commentController,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '以此象起论...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _isSending ? null : _handlePublishComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      shape: const StadiumBorder(),
                    ),
                    child: _isSending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('发送', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 点赞处理逻辑
  void _handleLike() {
    setState(() {
      final bool newIsLiked = !_currentPost.isLiked;
      _currentPost = _currentPost.copyWith(
        isLiked: newIsLiked,
        likes: newIsLiked ? _currentPost.likes + 1 : _currentPost.likes - 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('帖子详情', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading && _currentPost.content.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorRow(),
            const SizedBox(height: 16),
            Text(_currentPost.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(_currentPost.content, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
            if (_currentPost.images.isNotEmpty) _buildImageGallery(),
            if (_currentPost.tags.isNotEmpty) _buildTagRow(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomInteractionBar(),
    );
  }

  // ... _buildAuthorRow, _buildImageGallery, _buildTagRow 保持不变 ...

  // 修正后的底部互动栏
  Widget _buildBottomInteractionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _showCommentSheet, // 4. 点击这里弹出输入框
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
                  child: const Text('写点评论...', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildIconAction(
              icon: _currentPost.isLiked ? Icons.favorite : Icons.favorite_border,
              label: '${_currentPost.likes}',
              color: _currentPost.isLiked ? Colors.red : Colors.grey[700],
              onTap: _handleLike,
            ),
            const SizedBox(width: 16),
            _buildIconAction(
                icon: Icons.chat_bubble_outline,
                label: '${_currentPost.comments}',
                onTap: _showCommentSheet // 点击评论图标也弹出输入
            ),
          ],
        ),
      ),
    );
  }

  // 辅助组件保持不变...
  Widget _buildIconAction({required IconData icon, required String label, Color? color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  // 之前代码里缺少的辅助组件
  Widget _buildAuthorRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: _currentPost.authorAvatar.isNotEmpty ? NetworkImage(_currentPost.authorAvatar) : null,
          child: _currentPost.authorAvatar.isEmpty ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentPost.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_formatTime(_currentPost.publishTime), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(backgroundColor: Colors.purple[50], shape: const StadiumBorder()),
          child: Text('关注', style: TextStyle(color: Colors.purple[700])),
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Column(
      children: [
        const SizedBox(height: 16),
        ..._currentPost.images.map((url) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildTagRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: _currentPost.tags.map((tag) => Chip(
            label: Text('# $tag'),
            backgroundColor: Colors.purple[50],
            side: BorderSide.none,
            labelStyle: TextStyle(color: Colors.purple[700], fontSize: 13),
          )).toList(),
        ),
      ],
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