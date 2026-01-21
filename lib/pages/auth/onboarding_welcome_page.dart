import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/app_text.dart';

/// 首次使用欢迎页面 - 展示核心功能亮点
/// 
/// 功能：
/// 1. 展示应用核心功能亮点
/// 2. 提供"开始设置"按钮
/// 3. 玄学传统元素设计
class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部装饰（玄学元素）
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // 传统元素装饰
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 60,
                        color: AppColors.primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 欢迎标题
                    AppText.displayLarge(
                      '欢迎来到灵境',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    AppText(
                      '融合传统玄学与现代AI技术',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.graySecondary,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // 核心功能亮点
                    _buildFeatureItem(
                      icon: Icons.face,
                      title: 'AI命理分析',
                      description: '面相、手相、八字，全方位命理解读',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      icon: Icons.favorite,
                      title: '健康画像',
                      description: '中西医结合，全面了解健康状况',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      icon: Icons.restaurant,
                      title: '智能饮食推荐',
                      description: '基于"药食同源"，个性化食谱推荐',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      icon: Icons.calendar_today,
                      title: '智能看板',
                      description: '结合传统历法，每日行事准则',
                    ),
                  ],
                ),
              ),
            ),

            // 开始设置按钮
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/onboarding/preferences');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: AppText(
                    '开始设置',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryBlueLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.displaySmall(title),
              const SizedBox(height: 4),
              AppText(
                description,
                style: TextStyle(
                  color: AppColors.graySecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

