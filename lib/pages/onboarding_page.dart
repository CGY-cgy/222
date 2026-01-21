import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/common/app_text.dart';
import '../services/storage_service.dart';

/// 引导页 - 首次打开应用时显示
/// 
/// 功能：
/// 1. 展示应用特色功能
/// 2. 提供"立即体验"按钮
/// 3. 判断是否首次打开（使用 SharedPreferences）
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 引导页内容
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'AI命理分析',
      'description': '融合传统玄学与现代AI技术\n为您提供精准的命理分析',
      'icon': Icons.auto_awesome,
    },
    {
      'title': '健康画像',
      'description': '中西医结合\n全面了解您的健康状况',
      'icon': Icons.favorite,
    },
    {
      'title': '智能饮食推荐',
      'description': '基于"药食同源"理念\n为您推荐个性化食谱',
      'icon': Icons.restaurant,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 跳转到登录页
  Future<void> _goToLogin() async {
    // 标记已打开过引导页
    await StorageService.setFirstLaunchComplete();
    
    // 跳转到登录页
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _goToLogin,
                  child:                 AppText(
                  '跳过',
                  style: TextStyle(color: AppColors.graySecondary),
                ),
                ),
              ),
            ),

            // 引导页内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // 指示器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ),

            const SizedBox(height: 40),

            // 立即体验按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _currentPage == _pages.length - 1
                      ? _goToLogin
                      : () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: AppText(
                    _currentPage == _pages.length - 1 ? '立即体验' : '下一步',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单页内容
  Widget _buildPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              page['icon'] as IconData,
              size: 60,
              color: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 48),

          // 标题
          AppText.displayMedium(
            page['title'] as String,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // 描述
          AppText(
            page['description'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.graySecondary),
          ),
        ],
      ),
    );
  }

  /// 构建指示器
  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : AppColors.grayDivider,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

