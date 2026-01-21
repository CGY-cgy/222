import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

/// 本地存储服务 - 统一管理 SharedPreferences
/// 
/// 作用：
/// 1. 封装 SharedPreferences 的复杂操作
/// 2. 统一存储 key 的命名
/// 3. 方便后续切换存储方式
/// 
/// 使用示例：
/// ```dart
/// // 保存 Token
/// await StorageService.saveToken('your_token');
/// 
/// // 读取 Token
/// final token = await StorageService.getToken();
/// 
/// // 保存用户信息
/// await StorageService.saveUser(user);
/// 
/// // 读取用户信息
/// final user = await StorageService.getUser();
/// ```
class StorageService {
  StorageService._();

  // ==================== Token 相关 ====================

  /// Token 存储的 key
  static const String _keyToken = 'auth_token';

  /// 保存 Token
  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyToken, token);
  }

  /// 读取 Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// 删除 Token
  static Future<bool> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyToken);
  }

  // ==================== 用户信息相关 ====================

  /// 用户信息存储的 key
  static const String _keyUser = 'user_info';

  /// 保存用户信息
  static Future<bool> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    return await prefs.setString(_keyUser, userJson);
  }

  /// 读取用户信息
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      // 如果解析失败，返回 null
      return null;
    }
  }

  /// 删除用户信息
  static Future<bool> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyUser);
  }

  // ==================== 首次打开标记 ====================

  /// 首次打开标记的 key
  static const String _keyFirstLaunch = 'first_launch';

  /// 检查是否首次打开
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// 标记已打开过
  static Future<bool> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyFirstLaunch, false);
  }

  // ==================== 清除所有数据 ====================

  /// 清除所有认证相关数据（用于退出登录）
  static Future<bool> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await removeToken();
    await removeUser();
    return true;
  }
}

