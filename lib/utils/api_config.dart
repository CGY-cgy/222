/// API配置类
/// 统一管理API的基础配置（服务器地址、超时时间等）
/// 
class ApiConfig {
  ApiConfig._(); // 私有构造函数，防止实例化

  // ==================== 环境配置 ====================
  
  /// 当前环境类型
  /// 开发时用 development，上线时用 production
  static const Environment _currentEnv = Environment.development;

  /// 开发环境配置
  static const String _devBaseUrl = 'http://localhost:8080/api/v1';
  
  /// 生产环境配置
  static const String _prodBaseUrl = 'https://api.lingjing.com/v1';

  // ==================== 基础配置 ====================
  
  /// 获取当前环境的Base URL
  /// 根据环境自动返回对应的服务器地址
  static String get baseUrl {
    switch (_currentEnv) {
      case Environment.development:
        return _devBaseUrl;
      case Environment.production:
        return _prodBaseUrl;
    }
  }

  /// 请求超时时间（秒）
  /// 如果30秒内服务器没响应，就认为超时
  static const int connectTimeout = 30;
  
  /// 接收超时时间（秒）
  static const int receiveTimeout = 30;

  // ==================== API路径 ====================
  
  /// 用户认证相关
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authSocialLogin = '/auth/social-login';
  
  /// 首页相关
  static const String homeIndex = '/home/index';
  static const String solarTermToday = '/solar-term/today';
  static const String solarTermDetail = '/solar-term/detail';
  
  /// AI对话相关
  static const String aiChatMessage = '/ai/chat/message';
  static const String aiChatHistory = '/ai/chat/history';
  static const String aiChatConversations = '/ai/chat/conversations';
  
  /// 健康管理相关
  static const String healthPortrait = '/health/portrait';
  static const String healthArchive = '/health/archive';
  static const String healthTongue = '/health/tongue';
  
  /// 社区相关
  static const String communityPosts = '/community/posts';
  static const String communityPost = '/community/post';
  
  /// 会员相关
  static const String memberInfo = '/member/info';
  static const String memberPackages = '/member/packages';
  
  /// 文件上传
  static const String uploadImage = '/upload/image';
  static const String uploadVideo = '/upload/video';
  static const String uploadAudio = '/upload/audio';
}

/// 环境枚举
/// 定义开发环境和生产环境
enum Environment {
  development, // 开发环境（本地测试）
  production, // 生产环境（正式上线）
}

