/// HTML到Flutter转换辅助工具
/// 
/// 这个文件提供了一些辅助函数，帮助快速将HTML原型转换为Flutter代码
/// 
/// 使用方法：
/// 1. 分析HTML结构
/// 2. 使用这些辅助函数快速构建Flutter组件
/// 3. 调整样式和交互

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// HTML常见元素到Flutter的快速转换工具
class HtmlToFlutterConverter {
  HtmlToFlutterConverter._();

  /// 将HTML的div转换为Flutter Container
  /// 
  /// HTML: <div class="card" style="padding: 16px; background: white;">
  /// Flutter: HtmlToFlutterConverter.div(...)
  static Widget div({
    Widget? child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? borderRadius,
    BoxShadow? shadow,
  }) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius)
            : null,
        boxShadow: shadow != null ? [shadow] : null,
      ),
      child: child,
    );
  }

  /// 将HTML的button转换为Flutter按钮
  /// 
  /// HTML: <button class="primary-btn">点击</button>
  /// Flutter: HtmlToFlutterConverter.button(...)
  static Widget button({
    required String text,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryBlue,
        foregroundColor: textColor ?? AppColors.white,
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? 8,
          ),
        ),
      ),
      child: Text(text),
    );
  }

  /// 将HTML的input转换为Flutter输入框
  /// 
  /// HTML: <input type="text" placeholder="请输入">
  /// Flutter: HtmlToFlutterConverter.input(...)
  static Widget input({
    String? hintText,
    String? labelText,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// 将HTML的img转换为Flutter图片
  /// 
  /// HTML: <img src="url" alt="描述">
  /// Flutter: HtmlToFlutterConverter.image(...)
  static Widget image({
    required String src,
    double? width,
    double? height,
    BoxFit? fit,
    String? alt,
  }) {
    // 判断是网络图片还是本地图片
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: AppColors.grayBackground,
            child: Icon(Icons.error, color: AppColors.graySecondary),
          );
        },
      );
    } else {
      return Image.asset(
        src,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: AppColors.grayBackground,
            child: Icon(Icons.error, color: AppColors.graySecondary),
          );
        },
      );
    }
  }

  /// 将HTML的ul/li转换为Flutter列表
  /// 
  /// HTML: <ul><li>项目1</li><li>项目2</li></ul>
  /// Flutter: HtmlToFlutterConverter.list(...)
  static Widget list({
    required List<String> items,
    Widget Function(String item, int index)? itemBuilder,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (itemBuilder != null) {
          return itemBuilder(items[index], index);
        }
        return ListTile(
          title: Text(items[index]),
        );
      },
    );
  }

  /// 将HTML的flex布局转换为Flutter布局
  /// 
  /// HTML: <div style="display: flex; flex-direction: column;">
  /// Flutter: HtmlToFlutterConverter.flexColumn(...)
  static Widget flexColumn({
    required List<Widget> children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: children,
    );
  }

  /// HTML: <div style="display: flex; flex-direction: row;">
  /// Flutter: HtmlToFlutterConverter.flexRow(...)
  static Widget flexRow({
    required List<Widget> children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: children,
    );
  }

  /// 将HTML的card转换为Flutter卡片
  /// 
  /// HTML: <div class="card">
  /// Flutter: HtmlToFlutterConverter.card(...)
  static Widget card({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 常用HTML类名到Flutter样式的映射
class HtmlClassMapper {
  HtmlClassMapper._();

  /// 将HTML的class名转换为Flutter样式
  /// 
  /// 例如：
  /// HTML: <div class="primary-button">
  /// Flutter: 使用 primaryButton() 方法
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return HtmlToFlutterConverter.button(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.primaryBlue,
      textColor: AppColors.white,
    );
  }

  static Widget secondaryButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return HtmlToFlutterConverter.button(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.grayBackground,
      textColor: AppColors.grayText,
    );
  }

  static Widget card({
    required Widget child,
  }) {
    return HtmlToFlutterConverter.card(
      child: child,
    );
  }
}





