import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 统一主题配置 - 基于HTML原型设计规范
/// 
/// 设计原则：
/// 1. 苹果风格：简洁、现代、统一
/// 2. 字体：统一使用黑体（FontWeight.w600/w700）
/// 3. 圆角：统一使用8px、12px、16px
/// 4. 间距：统一使用16px为主
class AppTheme {
  AppTheme._();

  /// 获取主题配置
  static ThemeData get theme {
    return ThemeData(
      // 主色调
      primaryColor: AppColors.primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryBlueDark,
      ),
      
      // 背景色
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      
      // 字体 - 统一使用黑体（苹果风格）
      fontFamily: 'PingFang SC',
      textTheme: const TextTheme(
        // 大标题
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700, // 黑体
          color: AppColors.grayTitle,
          height: 1.2,
        ),
        // 中标题
        displayMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700, // 黑体
          color: AppColors.grayTitle,
          height: 1.25,
        ),
        // 小标题
        displaySmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700, // 黑体
          color: AppColors.grayTitle,
          height: 1.3,
        ),
        // 正文大
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600, // 黑体
          color: AppColors.grayText,
          height: 1.4,
        ),
        // 正文中
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600, // 黑体
          color: AppColors.grayText,
          height: 1.35,
        ),
        // 正文小
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600, // 黑体
          color: AppColors.graySecondary,
          height: 1.4,
        ),
        // 标签
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600, // 黑体
          color: AppColors.graySecondary,
          height: 1.45,
        ),
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grayTitle,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700, // 黑体
          color: AppColors.grayTitle,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // 统一圆角16px
        ),
        shadowColor: Colors.black.withOpacity(0.08),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22), // 搜索框圆角22px
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(
          color: AppColors.graySecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600, // 黑体
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 按钮圆角12px
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600, // 黑体
          ),
        ),
      ),
      
      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600, // 黑体
          ),
        ),
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: AppColors.grayDivider,
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}





