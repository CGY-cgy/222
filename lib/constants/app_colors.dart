import 'package:flutter/material.dart';

/// 应用颜色常量 - 基于设计规范（现代科技+传统玄学风格）
class AppColors {
  AppColors._();

  // 传统玄学配色（参考 index.html）
  static const Color paper = Color(0xFFF4F1EB); // 纸张色
  static const Color gold = Color(0xFFB89B5E); // 金色
  static const Color goldLight = Color(0xFFD4C4A8); // 浅金色
  static const Color goldDark = Color(0xFF9A8250); // 深金色
  static const Color ink = Color(0xFF2B2B2B); // 墨色
  static const Color line = Color(0x26000000); // 线条色（rgba(0,0,0,0.15)）

  // 主色调 - 使用金色替代蓝色
  static const Color primary = gold; // 主色使用金色
  static const Color primaryDark = goldDark;
  static const Color primaryLight = goldLight;

  // 兼容旧代码（逐步替换）
  static const Color primaryBlue = gold;
  static const Color primaryBlueDark = goldDark;
  static const Color primaryBlueLight = Color(0xFFF5F0E8); // 金色浅色背景

  // 白色
  static const Color white = Color(0xFFFFFFFF);

  // 灰色系统（调整为更柔和的色调）
  static const Color grayBackground = paper; // 使用纸张色作为背景
  static const Color grayDivider = Color(0xFFE5E0D8); // 更柔和的 divider
  static const Color graySecondary = Color(0xFF8B7D6B); // 柔和的灰色
  static const Color grayText = Color(0xFF4A4A4A); // 柔和的文本色
  static const Color grayTitle = ink; // 使用墨色作为标题

  // 功能色（降低饱和度）
  static const Color success = Color(0xFF6B8E5A); // 柔和的绿色
  static const Color warning = Color(0xFFD4A574); // 柔和的橙色
  static const Color error = Color(0xFFC97A7A); // 柔和的红色
  static const Color info = gold; // 使用金色作为信息色

  // 背景色
  static const Color scaffoldBackground = Color(0xFFF7F4EE); // 纸张色背景（用于登录注册页面）
  static const Color homeBackground = Color(0xFFFAFAFA); // 浅灰色偏白色（用于首页）
  static const Color cardBackground = white;
  static const Color inputBackground = Color(0xFFFAF8F4); // 更柔和的输入框背景
}

