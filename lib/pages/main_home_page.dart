import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/mock_service.dart';
import '../models/solar_term.dart';
import '../models/post.dart';
import '../constants/app_colors.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/common/app_search_bar.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_section_title.dart';
import '../widgets/common/app_text.dart';
import 'fortune_page.dart';
import 'health_page.dart';
import 'diet_page.dart';
import 'dashboard_page.dart';
import 'post_detail_page.dart';
import 'assistant_page.dart';
import 'search_page.dart';

/// 首页 - 使用统一组件，代码简洁
class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  SolarTerm? _solarTerm;
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final solarTerm = await MockService.getTodaySolarTerm();
      final posts = await MockService.getPosts(page: 1, limit: 10);
      setState(() {
        _solarTerm = solarTerm;
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败，请重试';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground, // 首页使用浅灰色偏白色背景
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.gold,
        child: _isLoading
            ? const LoadingWidget(message: '加载中...')
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText.bodyMedium(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: AppText.bodyMedium('重试'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top),
                        AppSearchBar(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchPage()),
                            );
                          },
                        ),
                        if (_solarTerm != null) _buildFestivalBanner(_solarTerm!),
                        _buildQuickNav(),
                        _buildCommunitySection(),
                      ],
                    ),
                  ),
      ),
      // 【开发模式】调试按钮 - 快速跳转到任意页面
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.gold.withOpacity(0.8),
              onPressed: () => _showDebugMenu(context),
              child: const Icon(Icons.bug_report, size: 18, color: Colors.white),
            )
          : null,
    );
  }

  /// 显示调试菜单 - 快速跳转到任意页面
  void _showDebugMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grayDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppText(
                '开发调试 - 快速跳转',
                style: TextStyle(
                  color: AppColors.grayTitle,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(),
            _buildDebugMenuItem(
              context,
              icon: Icons.login,
              title: '登录页',
              route: '/login',
            ),
            _buildDebugMenuItem(
              context,
              icon: Icons.person_add,
              title: '注册页',
              route: '/register',
            ),
            _buildDebugMenuItem(
              context,
              icon: Icons.tour,
              title: '引导页',
              route: '/onboarding',
            ),
            _buildDebugMenuItem(
              context,
              icon: Icons.waving_hand,
              title: '欢迎页',
              route: '/onboarding/welcome',
            ),
            _buildDebugMenuItem(
              context,
              icon: Icons.settings,
              title: '偏好设置',
              route: '/onboarding/preferences',
            ),
            _buildDebugMenuItem(
              context,
              icon: Icons.security,
              title: '权限设置',
              route: '/onboarding/permissions',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugMenuItem(BuildContext context, {required IconData icon, required String title, required String route}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold),
      title: AppText.bodyMedium(title),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }

  /// 节气Banner - 传统玄学风格（参考 index.html）
  Widget _buildFestivalBanner(SolarTerm solarTerm) {
    final now = DateTime.now();
    final weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    final weekday = weekdays[now.weekday % 7];
    final dateStr = '${now.year}年${now.month}月${now.day}日 $weekday';
    final emoji = _getSolarTermEmoji(solarTerm.name);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
       // color: AppColors.goldLight.withOpacity(0.5), // 浅黄色背景
        color: AppColors.homeBackground, // 和首页背景色一样
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.line,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('节气详情功能待实现')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // 左侧：传统圆形装饰（参考命盘设计）
            Stack(
              alignment: Alignment.center,
              children: [
                // 外圈
                Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.line,
                      width: 1,
                    ),
                  ),
                ),
                // 中圈（虚线效果）
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.line,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                // 内圈（金色）
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 20),
            
            // 右侧：节气信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 节气名称
                  AppText(
                    solarTerm.name,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 4,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 日期
                  AppText(
                    dateStr,
                    style: TextStyle(
                      color: AppColors.graySecondary,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 描述
                  AppText(
                    solarTerm.description,
                    style: TextStyle(
                      color: AppColors.grayText,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSolarTermEmoji(String name) {
    const emojiMap = {
      '立春': '🌱',
      '雨水': '💧',
      '惊蛰': '⚡',
      '春分': '🌸',
      '清明': '🌿',
      '谷雨': '🌧️',
      '立夏': '🌻',
      '小满': '🌾',
      '芒种': '🌾',
      '夏至': '☀️',
      '小暑': '🔥',
      '大暑': '🌡️',
      '立秋': '🍂',
      '处暑': '🍁',
      '白露': '💎',
      '秋分': '🍂',
      '寒露': '❄️',
      '霜降': '🧊',
      '立冬': '❄️',
      '小雪': '❄️',
      '大雪': '🌨️',
      '冬至': '❄️',
      '小寒': '🧊',
      '大寒': '❄️',
    };
    return emojiMap[name] ?? '🌸';
  }

  /// 快速导航
  Widget _buildQuickNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.homeBackground, // 和首页背景色一样
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldLight.withOpacity(0.5), // 浅黄色边框
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickNavItem(
            icon: Icons.star,
            label: '命理分析',
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3498db).withOpacity(0.7),
                const Color(0xFF2980b9).withOpacity(0.7),
              ],
            ),
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FortunePage()),
                ),
          ),
          _buildQuickNavItem(
            icon: Icons.favorite,
            label: '健康画像',
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2ecc71).withOpacity(0.7),
                const Color(0xFF27ae60).withOpacity(0.7),
              ],
            ),
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HealthPage()),
                ),
          ),
          _buildQuickNavItem(
            icon: Icons.restaurant,
            label: '饮食推荐',
            gradient: LinearGradient(
              colors: [
                const Color(0xFFf39c12).withOpacity(0.7),
                const Color(0xFFe67e22).withOpacity(0.7),
              ],
            ),
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DietPage()),
                ),
          ),
          _buildQuickNavItem(
            icon: Icons.calendar_today,
            label: '智能看板',
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9b59b6).withOpacity(0.7),
                const Color(0xFF8e44ad).withOpacity(0.7),
              ],
            ),
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavItem({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradient,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 6),
                AppText.bodySmall(label, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 社区动态区域
  Widget _buildCommunitySection() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(
            title: '社区动态',
            icon: Icons.comment,
            actionText: '全部',
            onActionTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssistantPage()),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_posts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: EmptyStateWidget(
                title: '暂无动态',
                subtitle: '社区动态会显示在这里',
              ),
            )
          else
            ..._posts.take(5).map((post) => _buildPostCard(post)),
        ],
      ),
    );
  }

  /// 帖子卡片
  Widget _buildPostCard(Post post) {
    final timeText = _formatTime(post.publishTime);

    return AppCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(post.authorAvatar, post.authorName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium(post.authorName),
                    const SizedBox(height: 2),
                    AppText.bodySmall(timeText),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText.bodyMedium(
            post.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.images.first,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildStatItem(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    count: post.likes,
                    color: post.isLiked ? AppColors.error : AppColors.graySecondary,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    icon: Icons.comment_outlined,
                    count: post.comments,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '查看全文',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gold,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl, String name) {
    final hasAvatar = avatarUrl.isNotEmpty;
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primaryBlueLight,
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
      onBackgroundImageError: hasAvatar ? (_, __) {} : null,
      child: hasAvatar
          ? null
          : Text(
              name.isNotEmpty ? name[0] : '?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                  ),
            ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.graySecondary),
        const SizedBox(width: 4),
        AppText.bodySmall('$count'),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 0) return '${difference.inDays}天前';
    if (difference.inHours > 0) return '${difference.inHours}小时前';
    if (difference.inMinutes > 0) return '${difference.inMinutes}分钟前';
    return '刚刚';
  }
}
