import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

/// 统一加载组件
/// 作用：数据加载时显示加载动画
/// 
/// 设计风格：现代科技 + 传统玄学
/// - 使用太极图旋转动画（传统元素）
/// - 配合现代科技感的渐变和光效
class LoadingWidget extends StatefulWidget {
  /// 加载提示文字
  final String? message;
  
  /// 是否显示背景遮罩
  final bool showBackground;
  
  /// 自定义大小
  final double? size;

  const LoadingWidget({
    Key? key,
    this.message,
    this.showBackground = false,
    this.size,
  }) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 创建动画控制器，控制旋转动画
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // 重复播放
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 60.0;
    
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 太极图旋转动画
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi, // 360度旋转
              child: _TaiChiIcon(size: size),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grayText,
            ),
          ),
        ],
      ],
    );

    // 如果需要背景遮罩
    if (widget.showBackground) {
      content = Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

/// 太极图图标组件
/// 使用Canvas绘制太极图（传统元素）
class _TaiChiIcon extends StatelessWidget {
  final double size;

  const _TaiChiIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TaiChiPainter(),
    );
  }
}

/// 太极图绘制器
class _TaiChiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 绘制太极图
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 绘制外圆（白色背景）
    paint.color = AppColors.white;
    canvas.drawCircle(center, radius, paint);

    // 绘制太极图（使用渐变色体现现代感）
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // 左半圆（深色）
    paint.color = AppColors.primaryBlueDark;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi,
      true,
      paint,
    );

    // 右半圆（浅色）
    paint.color = AppColors.primaryBlueLight;
    canvas.drawArc(
      rect,
      math.pi / 2,
      math.pi,
      true,
      paint,
    );

    // 上小圆（深色）
    paint.color = AppColors.primaryBlueDark;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius / 2),
      radius / 4,
      paint,
    );

    // 下小圆（浅色）
    paint.color = AppColors.primaryBlueLight;
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius / 2),
      radius / 4,
      paint,
    );

    // 添加光效（现代科技感）
    final gradient = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryBlue.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius * 0.8, gradient);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 全屏加载组件（带背景遮罩）
class FullScreenLoading extends StatelessWidget {
  final String? message;

  const FullScreenLoading({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      message: message,
      showBackground: true,
    );
  }
}





