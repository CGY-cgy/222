import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 统一模块标题组件 - 基于HTML原型设计
/// 
/// 使用场景：所有需要模块标题的地方
/// 特点：统一图标、文字、右侧操作
class AppSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Gradient? iconGradient;
  final String? actionText;
  final VoidCallback? onActionTap;

  const AppSectionTitle({
    Key? key,
    required this.title,
    this.icon,
    this.iconGradient,
    this.actionText,
    this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: iconGradient ??
                        LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.gold, AppColors.goldDark],
                        ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
          if (actionText != null)
            InkWell(
              onTap: onActionTap,
              child: Row(
                children: [
                  Text(
                    actionText!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.graySecondary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}



