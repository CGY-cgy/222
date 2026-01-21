import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 错误处理工具类
/// 作用：将技术错误转换为用户友好的提示信息
/// 

class ErrorHandler {
  ErrorHandler._(); // 私有构造函数

  /// 处理错误并返回用户友好的提示
  /// 
  /// 参数：
  /// - error: 错误对象（可能是各种类型的错误）
  /// - defaultMessage: 默认提示信息
  /// 
  /// 返回：用户友好的错误提示
  static String handleError(dynamic error, {String? defaultMessage}) {
    // 如果错误是字符串，直接返回
    if (error is String) {
      return error;
    }

    // 如果错误是Exception（异常），根据类型处理
    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      
      // 网络相关错误
      if (errorString.contains('socket') || 
          errorString.contains('network') ||
          errorString.contains('connection')) {
        return '网络连接失败，请检查网络设置';
      }
      
      // 超时错误
      if (errorString.contains('timeout')) {
        return '请求超时，请稍后重试';
      }
      
      // 服务器错误
      if (errorString.contains('500') || 
          errorString.contains('server')) {
        return '服务器繁忙，请稍后重试';
      }
      
      // 未找到错误
      if (errorString.contains('404') || 
          errorString.contains('not found')) {
        return '找不到请求的内容';
      }
      
      // 权限错误
      if (errorString.contains('401') || 
          errorString.contains('unauthorized')) {
        return '请先登录';
      }
      
      // 禁止访问
      if (errorString.contains('403') || 
          errorString.contains('forbidden')) {
        return '没有权限访问';
      }
    }

    // 默认错误提示
    return defaultMessage ?? '操作失败，请稍后重试';
  }

  /// 根据错误码返回对应的错误信息
  /// 
  /// 参数：
  /// - code: 错误码（如"2001"表示会员权限不足）
  /// 
  /// 返回：对应的错误提示
  static String getErrorMessageByCode(String code) {
    switch (code) {
      case '200':
        return '操作成功';
      case '400':
        return '请求参数错误';
      case '401':
        return '请先登录';
      case '403':
        return '没有权限访问';
      case '404':
        return '找不到请求的内容';
      case '500':
        return '服务器内部错误';
      case '1001':
        return '验证码错误';
      case '1002':
        return '验证码已过期';
      case '1003':
        return '手机号已被注册';
      case '1004':
        return '用户不存在';
      case '2001':
        return '会员权限不足，请升级会员';
      case '2002':
        return '今日使用次数已达上限';
      case '3001':
        return '文件上传失败';
      case '3002':
        return '文件格式不支持';
      case '3003':
        return '文件大小超限';
      default:
        return '操作失败，请稍后重试';
    }
  }

  /// 显示错误提示（SnackBar）
  /// 
  /// 参数：
  /// - context: 上下文（用于显示提示）
  /// - message: 错误信息
  /// - duration: 显示时长
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示成功提示
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

