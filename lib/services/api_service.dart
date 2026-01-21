import 'mock_service.dart';

/// API服务类
/// 作用：统一管理所有API调用，支持 Mock 数据与真实后端接口无缝切换
///
/// 使用方式：
/// 1. 当前阶段：[useMock] 设为 true，所有请求自动转发至 MockService
/// 2. 对接阶段：[useMock] 设为 false，并在相应请求方法中实现真实的网络调用
/// 3. 调用方式：在页面中使用 ApiService().methodName() 进行单例调用
class ApiService {
  // 单例模式：确保全局只有一个 API 控制中心，节省资源并方便状态管理
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// 是否使用 Mock 数据
  /// ⚠️ 这是一个全局开关，后端接口完成后只需将此处改为 false 即可切换到真实环境
  bool get useMock => true;

  /// 基础URL
  /// 作用：后端接口的根地址，对接真实后端时使用
  String get baseUrl => 'https://api.lingjing.com/v1';

  // ==================== 基础请求方法 (CRUD) ====================

  /// GET请求
  /// 参数：path (路径), queryParameters (URL参数)
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (useMock) return _mockRouter('GET', path, query: queryParameters);
    // TODO: 实现真实网络请求
    throw UnimplementedError('尚未实现真实GET请求');
  }

  /// POST请求
  /// 参数：path (路径), data (请求体)
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (useMock) return _mockRouter('POST', path, data: data);
    // TODO: 实现真实网络请求
    throw UnimplementedError('尚未实现真实POST请求');
  }

  /// PUT请求
  /// 参数：path (路径), data (请求体)
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) async {
    if (useMock) return _mockRouter('PUT', path, data: data);
    // TODO: 实现真实网络请求
    throw UnimplementedError('尚未实现真实PUT请求');
  }

  /// DELETE请求
  /// 参数：path (路径)
  Future<Map<String, dynamic>> delete(String path) async {
    if (useMock) return _mockRouter('DELETE', path);
    // TODO: 实现真实网络请求
    throw UnimplementedError('尚未实现真实DELETE请求');
  }

  // ==================== 响应处理逻辑 ====================

  /// 处理响应
  /// 作用：统一解析响应码，提取有效 data 字段，并处理业务异常
  Map<String, dynamic> handleResponse(Map<String, dynamic> response) {
    final dynamic code = response['code'];
    if (code.toString() != '200') {
      final message = response['msg'] ?? response['message'] ?? '操作失败';
      throw Exception(message);
    }
    final data = response['data'];
    if (data == null) return {};
    if (data is List) return {'list': data};
    return data as Map<String, dynamic>;
  }

  // ==================== 1. 用户认证与设置 ====================

  /// 用户登录
  /// 接口: POST /auth/login
  Future<Map<String, dynamic>> login(String account, String password) async {
    return await post('/auth/login', data: {'account': account, 'password': password});
  }

  /// 更新个性化偏好
  /// 接口: PUT /user/preferences
  Future<Map<String, dynamic>> updatePreferences({bool? dailyReminder, String? gender}) async {
    return await put('/user/preferences', data: {'dailyReminder': dailyReminder, 'gender': gender});
  }

  // ==================== 2. 首页与搜索接口 ====================

  /// 获取首页综合数据 (节气、帖子、提醒)
  /// 接口: GET /home/index
  Future<Map<String, dynamic>> getHomeData() async {
    return await get('/home/index');
  }

  /// 全局搜索
  /// 接口: GET /search
  Future<Map<String, dynamic>> search(String keyword, {String type = 'all'}) async {
    return await get('/search', queryParameters: {'keyword': keyword, 'type': type});
  }

  // ==================== 3. AI 对话接口 ====================

  /// 发送消息给 AI
  /// 接口: POST /ai/chat/message
  Future<Map<String, dynamic>> sendAIMessage(String content) async {
    return await post('/ai/chat/message', data: {'content': content});
  }

  /// 获取对话历史
  /// 接口: GET /ai/chat/history
  Future<Map<String, dynamic>> getChatHistory() async {
    return await get('/ai/chat/history');
  }

  // ==================== 4. 健康管理接口 ====================

  /// 上传并分析图像 (手相、面相、舌诊)
  /// 接口: POST /upload/image
  Future<Map<String, dynamic>> analyzeHealthImage(String path, String type) async {
    return await post('/upload/image', data: {'filePath': path, 'type': type});
  }

  /// 获取推荐食谱
  /// 接口: GET /recipes/recommended/today
  Future<Map<String, dynamic>> getTodayRecipes() async {
    return await get('/recipes/recommended/today');
  }

  // ==================== 5. 社区帖子接口 ====================

  /// 获取社区列表
  Future<Map<String, dynamic>> getPosts({int page = 1}) async {
    return await get('/posts', queryParameters: {'page': page});
  }

  /// 发布评论
  Future<Map<String, dynamic>> publishComment({required String postId, required String content}) async {
    return await post('/posts/comment', data: {'postId': postId, 'content': content});
  }

  // ==================== Mock 路由分发中心 (核心) ====================

  /// 内部方法：将 ApiService 的调用路由到对应的 MockService 实现
  Future<Map<String, dynamic>> _mockRouter(
      String method,
      String path, {
        dynamic data,
        dynamic query,
      }) async {
    print('DEBUG: [ApiService-Mock] $method $path');

    // --- 认证与用户路由 ---
    if (path == '/auth/login') return await MockService.login(account: data['account'], password: data['password']);
    if (path == '/user/preferences') return await MockService.updatePreferences(gender: data['gender']);
    if (path == '/user/profile') return await MockService.getUserProfile();

    // --- 首页与内容路由 ---
    if (path == '/home/index') return await MockService.getHomeData();
    if (path == '/search') return await MockService.search(query['keyword'], type: query['type']);
    if (path == '/posts' && method == 'GET') {
      final posts = await MockService.getPosts();
      return {'code': 200, 'data': posts, 'message': 'success'};
    }
    if (path == '/posts/comment' && method == 'POST') {
      return await MockService.publishComment(
        postId: data['postId'],
        content: data['content'],
      );
    }

    // --- AI 对话路由 ---
    if (path == '/ai/chat/message') {
      final msg = await MockService.sendAIMessage(data['content']);
      return {'code': '200', 'data': {'content': msg.content, 'id': msg.id}};
    }
    if (path == '/ai/chat/history') {
      final history = await MockService.getChatHistory();
      return {'code': '200', 'data': history.map((e) => {'content': e.content, 'isUser': e.isUser}).toList()};
    }

    // --- 健康相关路由 ---
    if (path == '/recipes/recommended/today') {
      final recipes = await MockService.getTodayRecipes();
      return {'code': '200', 'data': recipes.map((e) => {'name': e.name, 'desc': e.description}).toList()};
    }
    if (path == '/upload/image') return await MockService.uploadImage(filePath: data['filePath'], type: data['type']);

    throw Exception('Mock路由未配置: $path');
  }
}

