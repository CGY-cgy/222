import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 空状态组件
/// 作用：没有数据时显示的组件
/// 
/// 设计风格：现代科技 + 传统玄学
/// - 使用八卦图或传统符号（传统元素）
/// - 配合现代简洁的设计和渐变效果
class EmptyStateWidget extends StatelessWidget {
  /// 主标题
  final String title;
  
  /// 副标题/描述
  final String? subtitle;
  
  /// 自定义图标
  final Widget? icon;
  
  /// 操作按钮
  final Widget? action;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标（八卦图风格）
            if (icon != null)
              icon!
            else
              _DefaultEmptyIcon(),
            
            const SizedBox(height: 24),
            
            // 标题
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grayTitle,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 副标题
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.graySecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // 操作按钮
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 默认空状态图标（八卦图风格）
class _DefaultEmptyIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryBlueLight,
            AppColors.primaryBlue.withOpacity(0.3),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外圈（八卦图元素）
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          // 内圈
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.1),
            ),
          ),
          // 中心点
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

/// 常用空状态组件（预设文案）
class CommonEmptyStates {
  /// 空列表
  static Widget emptyList({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      title: '暂无内容',
      subtitle: '这里还没有任何内容',
      action: onRefresh != null
          ? ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('刷新'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
              ),
            )
          : null,
    );
  }

  /// 空搜索结果
  static Widget emptySearch({VoidCallback? onClear}) {
    return EmptyStateWidget(
      title: '未找到相关内容',
      subtitle: '试试其他关键词吧',
      action: onClear != null
          ? TextButton(
              onPressed: onClear,
              child: const Text('清除搜索'),
            )
          : null,
    );
  }

  /// 空收藏
  static Widget emptyFavorites() {
    return EmptyStateWidget(
      title: '还没有收藏',
      subtitle: '收藏的内容会显示在这里',
    );
  }

  /// 空历史记录
  static Widget emptyHistory() {
    return EmptyStateWidget(
      title: '暂无历史记录',
      subtitle: '浏览的内容会显示在这里',
    );
  }
}





