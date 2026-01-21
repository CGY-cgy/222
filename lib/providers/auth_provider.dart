import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

/// 认证状态管理 Provider
/// 负责维护全局登录态、用户信息、以及持久化存储的同步
class AuthProvider extends ChangeNotifier {
  // ==================== 私有状态 ====================
  User? _user;
  String? _token;
  bool _isLoading = false;

  // ==================== 公开访问器 ====================
  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // 初始化时从磁盘恢复状态
    _loadAuthFromStorage();
  }

  /// 从存储恢复登录凭证
  Future<void> _loadAuthFromStorage() async {
    _isLoading = true;
    notifyListeners();
    try {
      _token = await StorageService.getToken();
      _user = await StorageService.getUser();
    } catch (e) {
      debugPrint('AuthProvider 数据恢复异常: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== 核心认证方法 ====================

  /// 注册方法
  /// [mobile] 手机号, [code] 验证码, [password] 密码
  Future<bool> register(String mobile, String code, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().post('/auth/register', data: {
        'mobile': mobile,
        'code': code,
        'password': password,
      });

      // handleResponse 会自动校验 code 200
      final data = ApiService().handleResponse(response);

      // 注册成功后直接执行登录数据落地
      await _onAuthSuccess(data);
      return true;
    } catch (e) {
      debugPrint('注册失败: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 账号密码登录
  Future<bool> login(String account, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().login(account, password);
      final data = ApiService().handleResponse(response);
      await _onAuthSuccess(data);
      return true;
    } catch (e) {
      debugPrint('登录失败: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 手机验证码登录
  Future<bool> mobileLogin(String mobile, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().post('/auth/mobile/login', data: {
        'mobile': mobile,
        'code': code,
      });
      final data = ApiService().handleResponse(response);
      await _onAuthSuccess(data);
      return true;
    } catch (e) {
      debugPrint('验证码登录失败: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== 状态更新与持久化 ====================

  /// 更新用户信息 (关键修复：解决 Onboarding 页面报错)
  /// 当用户完成生辰八字设置、更改偏好或修改头像时调用
  Future<void> updateUser(User newUser) async {
    _user = newUser;
    // 同步到磁盘，防止下次启动 App 时丢失
    await StorageService.saveUser(newUser);
    notifyListeners();
  }

  /// 统一处理登录/注册成功的后续：保存 Token 与 User
  Future<void> _onAuthSuccess(Map<String, dynamic> data) async {
    // 1. 保存 Token
    _token = data['accessToken'] as String;
    await StorageService.saveToken(_token!);

    // 2. 解析并保存 User 对象
    final userJson = data['user'] as Map<String, dynamic>;
    _user = User.fromJson(userJson);
    await StorageService.saveUser(_user!);
  }

  // ==================== 登出逻辑 ====================

  /// 退出登录
  /// 修复：不再调用不存在的 ApiService.logout()，改为通用 post
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 通知服务器 Token 失效 (Mock模式下也会返回成功)
      await ApiService().post('/auth/logout');
    } catch (e) {
      debugPrint('服务端退出失败(静默处理): $e');
    } finally {
      // 无论请求结果，强制清理本地所有状态
      await StorageService.clearAuthData();
      _token = null;
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}