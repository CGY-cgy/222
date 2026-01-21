import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 错误状态组件
/// 作用：出错时显示的组件，提供重试功能
/// 
/// 设计风格：现代科技 + 传统玄学
/// - 使用传统符号（如八卦图）表示错误
/// - 配合现代简洁的设计和渐变效果
class ErrorStateWidget extends StatelessWidget {
  /// 错误信息
  final String message;
  
  /// 重试回调
  final VoidCallback? onRetry;
  
  /// 自定义图标
  final Widget? icon;

  const ErrorStateWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 错误图标（传统符号风格）
            if (icon != null)
              icon!
            else
              _DefaultErrorIcon(),
            
            const SizedBox(height: 24),
            
            // 错误信息
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.grayText,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 重试按钮
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 默认错误图标（传统符号风格）
class _DefaultErrorIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.error.withOpacity(0.1),
            AppColors.error.withOpacity(0.05),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外圈（传统符号元素）
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          // 中心图标
          Icon(
            Icons.error_outline,
            size: 40,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

/// 网络错误组件（常用）
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: '网络连接失败\n请检查网络设置后重试',
      onRetry: onRetry,
    );
  }
}

/// 服务器错误组件（常用）
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({Key? key, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: '服务器繁忙\n请稍后重试',
      onRetry: onRetry,
    );
  }
}

/// 未知错误组件（常用）
class UnknownErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const UnknownErrorWidget({
    Key? key,
    this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      message: message ?? '出现未知错误\n请稍后重试',
      onRetry: onRetry,
    );
  }
}





