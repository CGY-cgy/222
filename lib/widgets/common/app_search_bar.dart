import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 统一搜索栏组件 - 基于HTML原型设计
/// 
/// 使用场景：所有需要搜索的地方
/// 特点：统一样式、圆角、图标
class AppSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final bool readOnly;

  const AppSearchBar({
    Key? key,
    this.hintText = '搜索帖子、食谱、健康知识...',
    this.onTap,
    this.readOnly = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.grayDivider,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: AppColors.graySecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                hintText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.graySecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





