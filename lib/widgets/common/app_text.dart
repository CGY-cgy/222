import 'package:flutter/material.dart';

/// 统一文本组件 - 使用主题样式
/// 
/// 使用场景：所有文本显示
/// 特点：自动使用主题中的字体样式（黑体）
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextThemeType? type;

  const AppText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.type,
  }) : super(key: key);

  /// 大标题
  AppText.displayLarge(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  })  : style = null,
        type = TextThemeType.displayLarge,
        super(key: key);

  /// 中标题
  AppText.displayMedium(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  })  : style = null,
        type = TextThemeType.displayMedium,
        super(key: key);

  /// 小标题
  AppText.displaySmall(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  })  : style = null,
        type = TextThemeType.displaySmall,
        super(key: key);

  /// 正文大
  AppText.bodyLarge(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  })  : style = null,
        type = TextThemeType.bodyLarge,
        super(key: key);

  /// 正文中
  AppText.bodyMedium(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  })  : style = null,
        type = TextThemeType.bodyMedium,
        super(key: key);

  /// 正文小
  AppText.bodySmall(
    this.text, {
    Key? key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  })  : style = null,
        type = TextThemeType.bodySmall,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? finalStyle = style;
    
    if (style == null && type != null) {
      final theme = Theme.of(context).textTheme;
      switch (type!) {
        case TextThemeType.displayLarge:
          finalStyle = theme.displayLarge;
          break;
        case TextThemeType.displayMedium:
          finalStyle = theme.displayMedium;
          break;
        case TextThemeType.displaySmall:
          finalStyle = theme.displaySmall;
          break;
        case TextThemeType.bodyLarge:
          finalStyle = theme.bodyLarge;
          break;
        case TextThemeType.bodyMedium:
          finalStyle = theme.bodyMedium;
          break;
        case TextThemeType.bodySmall:
          finalStyle = theme.bodySmall;
          break;
      }
    } else if (style == null) {
      finalStyle = Theme.of(context).textTheme.bodyMedium;
    }

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

enum TextThemeType {
  displayLarge,
  displayMedium,
  displaySmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
}

