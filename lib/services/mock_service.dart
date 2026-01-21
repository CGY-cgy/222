import '../models/post.dart';
import '../models/ai_message.dart';
import '../models/membership.dart';
import '../models/solar_term.dart';
import '../models/recipe.dart';
import '../models/health_data.dart';
import '../models/fortune_analysis.dart';

/// Mock数据服务
/// TODO: 后端开发完成后，替换为真实API调用
/// 所有方法都标注了对应的API接口路径，方便后续对接
class MockService {
  // ==================== 1. 用户认证接口 ====================

  /// TODO: 用户登录
  /// 接口: POST /auth/login
  static Future<Map<String, dynamic>> login({
    required String account,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'accessToken': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'userId': 12345,
          'mobile': account,
          'nickname': '用户${account.substring(account.length - 4)}',
          'avatarUrl': '', // 使用默认头像
          'gender': 'U',
          'birthday': null,
          'isNewUser': false,
        },
      },
    };
  }

  /// TODO: 第三方授权登录
  /// 接口: POST /auth/social-login
  static Future<Map<String, dynamic>> socialLogin({
    required String platform, // wechat, alipay
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'accessToken': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'userId': 12345,
          'nickname': platform == 'wechat' ? '微信用户' : '支付宝用户',
          'avatarUrl': '', // 使用默认头像
          'isNewUser': true,
        },
      },
    };
  }

  /// TODO: 个性化引导设置
  /// 接口: PUT /user/preferences
  static Future<Map<String, dynamic>> updatePreferences({
    bool? dailyReminder,
    String? birthday,
    String? gender,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'success': true,
      },
    };
  }

  /// TODO: 用户注册
  /// 接口: POST /auth/register
  static Future<Map<String, dynamic>> register({
    required String mobile,
    required String code,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟验证码错误
    if (code != '123456') {
      return {
        'code': '1001',
        'message': '验证码错误',
      };
    }

    return {
      'code': '200',
      'message': '注册成功',
      'data': {
        'accessToken': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'userId': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'mobile': mobile,
          'nickname': '用户${mobile.substring(mobile.length - 4)}',
          'avatarUrl': '',
          'gender': 'U',
          'birthday': null,
          'isNewUser': true,
        },
      },
    };
  }

  /// TODO: 发送验证码
  /// 接口: POST /auth/send-code
  static Future<Map<String, dynamic>> sendCode({
    required String mobile,
    String type = 'register', // register, login
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // 模拟发送失败（手机号格式错误）
    if (mobile.length != 11) {
      return {
        'code': '400',
        'message': '手机号格式错误',
      };
    }

    return {
      'code': '200',
      'message': '验证码已发送',
      'data': {
        'code': '123456', // Mock 环境返回验证码，生产环境不返回
        'expiresIn': 300, // 5分钟过期
      },
    };
  }

  /// TODO: 手机号一键登录（验证码登录）
  /// 接口: POST /auth/mobile/login
  static Future<Map<String, dynamic>> mobileLogin({
    required String mobile,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 模拟验证码错误
    if (code != '123456') {
      return {
        'code': '1001',
        'message': '验证码错误',
      };
    }

    return {
      'code': '200',
      'message': '登录成功',
      'data': {
        'accessToken': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'userId': 12345,
          'mobile': mobile,
          'nickname': '用户${mobile.substring(mobile.length - 4)}',
          'avatarUrl': '',
          'gender': 'U',
          'birthday': null,
          'isNewUser': false, // 一键登录默认不是新用户
        },
      },
    };
  }

  /// TODO: 退出登录
  /// 接口: POST /auth/logout
  static Future<Map<String, dynamic>> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'code': '200',
      'message': '退出成功',
    };
  }

  // ==================== 2. 首页接口 ====================

  /// TODO: 获取首页数据
  /// 接口: GET /home/index
  static Future<Map<String, dynamic>> getHomeData({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final solarTerm = await getTodaySolarTerm();
    final posts = await getPosts(page: page, limit: pageSize);
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'solarTerm': {
          'name': solarTerm.name,
          'message': solarTerm.description,
        },
        'posts': posts.map((p) => p.toJson()).toList(),
        'total': 100,
        'page': page,
        'pageSize': pageSize,
      },
    };
  }

  /// TODO: 获取当日节气/节日信息
  /// 接口: GET /solar-term/today
  static Future<SolarTerm> getTodaySolarTerm() async {
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    return SolarTerm(
      id: '1',
      name: '立春',
      date: DateTime.now(),
      backgroundImage: 'https://picsum.photos/400/200?random=1',
      description: '立春是二十四节气中的第一个节气，标志着春天的开始。',
      lunarDate: '甲辰年正月初一',
      healthAdvice: '立春时节，宜早睡早起，多食新鲜蔬菜，保持心情愉悦。',
    );
  }

  /// TODO: 获取今日行事准则
  /// 接口: GET /api/guidelines/today
  static Future<DailyGuidelines> getTodayGuidelines() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DailyGuidelines(
      doList: ['适宜重要决策', '进行运动锻炼', '与朋友交流'],
      dontList: ['避免熬夜', '不宜冲动消费', '避免争吵'],
      fortuneSummary: '今日整体运势平稳，适合规划未来，注意情绪管理。',
    );
  }

  /// TODO: 获取今日运势能量分布
  /// 接口: GET /api/fortune/energy/today
  static Future<FortuneEnergy> getTodayFortuneEnergy() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return FortuneEnergy(
      career: 85,
      health: 78,
      wealth: 92,
      emotion: 80,
    );
  }

  /// TODO: 获取今日推荐食谱
  /// 接口: GET /recipes/recommended/today
  static Future<List<Recipe>> getTodayRecipes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Recipe(
        id: '1',
        name: '红枣枸杞粥',
        description: '适合平和质人群，具有滋阴润燥的功效',
        imageUrl: 'https://picsum.photos/400/300?random=1',
        ingredients: ['红枣', '枸杞', '大米', '冰糖'],
        cookingSteps: '1. 将大米洗净，红枣去核\n2. 加水煮至米粒开花\n3. 加入枸杞和冰糖，煮5分钟即可',
        nutrition: {'calories': 280.0, 'protein': 8.0, 'carbs': 60.0},
        tags: ['药食同源', '温补'],
        mealType: '早餐',
        cookingTime: 30,
        difficulty: 2,
      ),
    ];
  }

// ==================== 社区帖子相关 ====================
  /// TODO: 发布评论 (新增此方法以匹配 ApiService)
  /// 接口: POST /posts/comment
  /// 模拟发布评论
  /// 模拟发布评论逻辑
// lib/services/mock_service.dart

  static Future<Map<String, dynamic>> publishComment({
    required String postId,
    required String content,
  }) async {
    // 模拟 500 毫秒的网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟成功返回的数据结构
    return {
      'code': 200,
      'message': '评论发表成功',
      'data': {
        'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
        'postId': postId,
        'content': content,
        'authorName': '道友(我)',
        'createTime': '刚刚',
      }
    };
  }
  /// 1. 定义私有的固定数据池 (确保数据源唯一且固定)
  static final List<Post> _fixedPostSource = [
    Post(
      id: 'post_1',
      authorId: 'user_1',
      authorName: '命理达人',
      authorAvatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Luck',
      title: '我的命理故事：岁末感悟',
      content: '时间飞逝，转眼又是一年。在研究命理的过程中，我发现心态的转变往往比改运更重要。\n\n顺应自然、保持内心的平静才是长久之道。立春将至，肝气渐旺，建议大家多运动，少熬夜。',
      images: ['https://picsum.photos/id/10/800/600'],
      videos: [],
      tags: ['节气养生', '我的命理故事'],
      likes: 120,
      comments: 45,
      shares: 10,
      isLiked: false,
      publishTime: DateTime.now().subtract(const Duration(hours: 3)), // 3小时前
      isPublic: true,
    ),
    Post(
      id: 'post_2',
      authorId: 'user_2',
      authorName: '山间行者',
      authorAvatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Bear',
      title: '山医命相卜：传统五术初探',
      content: '今天在山中漫步，感悟到气场对人的影响确实无处不在。所谓五术，其实核心都在于“天人合一”的平衡。',
      images: ['https://picsum.photos/id/20/800/600'],
      videos: [],
      tags: ['国学感悟'],
      likes: 88,
      comments: 12,
      shares: 5,
      isLiked: false,
      publishTime: DateTime.now().subtract(const Duration(minutes: 30)), // 30分钟前 (最新)
      isPublic: true,
    ),
    Post(
      id: 'post_3',
      authorId: 'user_3',
      authorName: '禅茶一味',
      authorAvatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Tea',
      title: '春季饮食调理建议',
      content: '春属木，入肝经。此时饮食宜减酸增甘，以养脾气。分享几个简单的食疗方子给大家：红枣粥、山药汤。',
      images: ['https://picsum.photos/id/30/800/600'],
      videos: [],
      tags: ['饮食养生'],
      likes: 210,
      comments: 56,
      shares: 30,
      isLiked: false,
      publishTime: DateTime.now().subtract(const Duration(hours: 1)), // 1小时前
      isPublic: true,
    ),
    Post(
      id: 'post_4',
      authorId: 'user_4',
      authorName: '易学爱好者',
      authorAvatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Study',
      title: '如何看懂自己的流年运势',
      content: '流年代表了当年的能量变化。通过对干支的观察，我们可以提前预判可能遇到的挑战，从而做到心中有数。',
      images: ['https://picsum.photos/id/40/800/600'],
      videos: [],
      tags: ['术数干货'],
      likes: 340,
      comments: 89,
      shares: 45,
      isLiked: false,
      publishTime: DateTime.now().subtract(const Duration(days: 1)), // 1天前
      isPublic: true,
    ),
    Post(
      id: 'post_5',
      authorId: 'user_5',
      authorName: '知行合一',
      authorAvatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Act',
      title: '环境对心理状态的暗示',
      content: '居家办公时，光线和通风不仅影响生理健康，更会潜移默化影响我们的决策判断。保持整洁非常重要。',
      images: ['https://picsum.photos/id/50/800/600'],
      videos: [],
      tags: ['生活方式'],
      likes: 156,
      comments: 24,
      shares: 8,
      isLiked: false,
      publishTime: DateTime.now().subtract(const Duration(days: 2)), // 2天前
      isPublic: true,
    ),
  ];

  /// 获取社区帖子列表 (已按发布时间倒序排序)
  static Future<List<Post>> getPosts({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // 拷贝数据并按照 publishTime 从新到旧排序
    List<Post> sortedPosts = List.from(_fixedPostSource);
    sortedPosts.sort((a, b) => b.publishTime.compareTo(a.publishTime));

    return sortedPosts;
  }

  /// 获取帖子详情 (根据 ID 精准匹配，确保对应)
  static Future<Post> getPostDetail(String postId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // 在固定源中查找对应 ID 的帖子
    return _fixedPostSource.firstWhere(
          (post) => post.id == postId,
      orElse: () => _fixedPostSource.first, // 如果找不到则返回第一个
    );
  }

  /// 发布动态
  static Future<Map<String, dynamic>> publishPost({
    required String title,
    required String content,
    required List<String> images,
    required List<String> tags,
    bool isPublic = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {'code': '200', 'message': '发布成功'};
  }

  /// 点赞/取消点赞
  static Future<Map<String, dynamic>> toggleLike(String postId, bool isLike) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'code': '200',
      'data': {'like_count': isLike ? 121 : 120},
    };
  }

  /// 获取评论列表
  static Future<Map<String, dynamic>> getPostComments({
    required String postId,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'code': '200',
      'data': {
        'comments': [
          {'nickname': '用户A', 'content': '内容很有深度，学习了！', 'create_time': '2024-05-20'},
          {'nickname': '用户B', 'content': '感谢分享，期待下一篇。', 'create_time': '2024-05-21'},
        ],
        'total': 2,
      },
    };
  }


  // ==================== 7. 会员接口 ====================

  /// TODO: 获取会员信息
  /// 接口: GET /member/info
  static Future<Map<String, dynamic>> getMembershipInfo() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final status = await getMembershipStatus();
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'membershipId': 1,
        'membershipType': status.isMember ? 'monthly' : 'free',
        'isActive': status.isMember,
        'startTime': status.isMember ? DateTime.now().subtract(const Duration(days: 10)).toIso8601String() : null,
        'endTime': status.expireDate?.toIso8601String(),
        'benefits': [
          {'id': 1, 'name': 'AI对话风格切换', 'desc': '可切换AI对话风格'},
          {'id': 2, 'name': '定时发布帖子', 'desc': '可设置定时发布'},
        ],
      },
    };
  }

  /// TODO: 获取会员套餐
  /// 接口: GET /member/packages
  static Future<Map<String, dynamic>> getMembershipPackagesList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final packages = await getMembershipPackages();
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'packages': packages.map((p) => {
          'packageId': int.parse(p.id),
          'packageName': p.name,
          'price': p.price,
          'validPeriod': p.durationDays,
          'description': '${p.name}套餐描述',
          'isActive': true,
        }).toList(),
      },
    };
  }

  /// TODO: 获取会员权益对比
  /// 接口: GET /member/privileges
  static Future<Map<String, dynamic>> getMembershipPrivileges() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'free': {
          'privileges': [
            {
              'privilegeId': 1,
              'privilegeName': '基础功能',
              'privilegeDesc': '基础功能描述',
              'privilegeIcon': 'https://picsum.photos/50/50?random=1',
            },
          ],
        },
        'member': {
          'privileges': [
            {
              'privilegeId': 2,
              'privilegeName': 'AI对话风格切换',
              'privilegeDesc': '可切换AI对话风格',
              'privilegeIcon': 'https://picsum.photos/50/50?random=2',
            },
            {
              'privilegeId': 3,
              'privilegeName': '定时发布帖子',
              'privilegeDesc': '可设置定时发布',
              'privilegeIcon': 'https://picsum.photos/50/50?random=3',
            },
          ],
        },
      },
    };
  }

  /// TODO: 创建会员订单
  /// 接口: POST /member/order/create
  static Future<Map<String, dynamic>> createMembershipOrder({
    required int packageId,
    required String paymentMethod, // wechat, alipay
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'orderId': 'order_${DateTime.now().millisecondsSinceEpoch}',
        'orderAmount': 29.9,
        'paymentMethod': paymentMethod,
        'orderStatus': 0,
        'payTime': null,
        'expireTime': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      },
    };
  }

  /// TODO: 查询订单状态
  /// 接口: GET /member/order/{orderId}
  static Future<Map<String, dynamic>> getOrderStatus(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'orderId': orderId,
        'packageId': 1,
        'packageName': '月度会员',
        'orderAmount': 29.9,
        'paymentMethod': 'wechat',
        'orderStatus': 1,
        'payTime': DateTime.now().toIso8601String(),
        'expireTime': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'createTime': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      },
    };
  }

  // ==================== 8. 个人中心接口 ====================

  /// TODO: 获取个人信息
  /// 接口: GET /user/profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'userId': 12345,
        'nickname': '用户昵称',
        'avatarUrl': '', // 使用默认头像
        'mobile': '138****8888',
        'gender': 'M',
        'birthday': '1990-01-01',
        'membershipType': 'free',
        'membershipTypeName': '免费用户',
        'stats': {
          'following': 10,
          'followers': 20,
          'posts': 5,
        },
      },
    };
  }

  /// TODO: 更新个人信息
  /// 接口: PUT /user/profile
  static Future<Map<String, dynamic>> updateUserProfile({
    String? nickname,
    String? avatarUrl,
    String? gender,
    String? birthday,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': '更新成功',
      'data': {
        'success': true,
      },
    };
  }

  /// TODO: 获取命理信息
  /// 接口: GET /user/fortune-info
  static Future<Map<String, dynamic>> getFortuneInfo() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'baziId': 1,
        'birthYearGan': '甲',
        'birthYearZhi': '子',
        'birthMonthGan': '丙',
        'birthMonthZhi': '寅',
        'birthDayGan': '戊',
        'birthDayZhi': '午',
        'birthHourGan': '庚',
        'birthHourZhi': '申',
        'lunarBirthDate': '甲子年正月初一',
        'ganZhiRelation': '干支关系摘要',
        'isVerified': true,
      },
    };
  }

  /// TODO: 更新命理信息
  /// 接口: PUT /user/fortune-info
  static Future<Map<String, dynamic>> updateFortuneInfo({
    required String birthday,
    required String birthTime,
    required String gender,
    String? province,
    String? city,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': '更新成功',
      'data': {
        'baziId': 1,
        'success': true,
      },
    };
  }

  /// TODO: 获取隐私设置
  /// 接口: GET /user/privacy
  static Future<Map<String, dynamic>> getPrivacySettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'privacySettings': {
          'publicProfile': true,
          'publicHealth': false,
          'publicSchedule': false,
          'allowStrangerMessage': false,
          'receiveNotifications': true,
        },
        'policyLinks': {
          'privacyPolicy': {
            'url': '/privacy-policy',
            'title': '隐私政策',
          },
          'termsOfService': {
            'url': '/terms-of-service',
            'title': '服务条款',
          },
        },
      },
    };
  }

  /// TODO: 更新隐私设置
  /// 接口: PUT /user/privacy
  static Future<Map<String, dynamic>> updatePrivacySettings({
    bool? publicProfile,
    bool? publicHealth,
    bool? publicSchedule,
    bool? allowStrangerMessage,
    bool? receiveNotifications,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'privacySettings': {
          'publicProfile': publicProfile ?? true,
          'publicHealth': publicHealth ?? false,
          'publicSchedule': publicSchedule ?? false,
          'allowStrangerMessage': allowStrangerMessage ?? false,
          'receiveNotifications': receiveNotifications ?? true,
        },
        'policyLinks': {
          'privacyPolicy': {
            'url': '/privacy-policy',
            'title': '隐私政策',
          },
          'termsOfService': {
            'url': '/terms-of-service',
            'title': '服务条款',
          },
        },
      },
    };
  }

  /// TODO: 获取账户安全设置
  /// 接口: GET /user/security
  static Future<Map<String, dynamic>> getSecuritySettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'mobile': '138****8888',
        'hasPassword': true,
        'wechatBound': false,
        'alipayBound': false,
      },
    };
  }

  /// TODO: 修改密码
  /// 接口: PUT /user/security/password
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': '修改成功',
      'data': {
        'success': true,
      },
    };
  }

  /// TODO: 绑定手机号
  /// 接口: PUT /user/security/mobile
  static Future<Map<String, dynamic>> bindMobile({
    required String mobile,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'code': '200',
      'message': '绑定成功',
      'data': {
        'success': true,
      },
    };
  }

  // ==================== 9. 文件上传接口 ====================

  /// TODO: 上传图片
  /// 接口: POST /upload/image
  static Future<Map<String, dynamic>> uploadImage({
    required String filePath,
    required String type, // avatar, post, health, tongue, face
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'url': 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
        'thumbnail': 'https://picsum.photos/200/200?random=${DateTime.now().millisecondsSinceEpoch}',
        'fileSize': 1024000,
      },
    };
  }

  /// TODO: 上传视频
  /// 接口: POST /upload/video
  static Future<Map<String, dynamic>> uploadVideo({
    required String filePath,
    required String type, // post
  }) async {
    await Future.delayed(const Duration(seconds: 3));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'url': 'https://example.com/video.mp4',
        'thumbnail': 'https://picsum.photos/400/300?random=1',
        'duration': 60,
        'fileSize': 10485760,
      },
    };
  }

  /// TODO: 上传语音
  /// 接口: POST /upload/audio
  static Future<Map<String, dynamic>> uploadAudio({
    required String filePath,
    required String type, // post, ai
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'code': '200',
      'message': 'success',
      'data': {
        'url': 'https://example.com/audio.mp3',
        'duration': 30,
        'fileSize': 512000,
      },
    };
  }

  // ==================== 原有方法（保持兼容） ====================

  // ==================== 原有方法（保持兼容） ====================

  /// TODO: 获取AI对话历史（兼容旧方法）
  /// 接口: GET /ai/chat/history
  static Future<List<AIMessage>> getChatHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      AIMessage(
        id: '1',
        isUser: true,
        content: '今日运势如何？',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      AIMessage(
        id: '2',
        isUser: false,
        content: '根据您的命理分析，今日整体运势平稳，事业运较佳，适合重要决策。',
        timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
      ),
    ];
  }

  /// TODO: 发送AI消息（兼容旧方法）
  /// 接口: POST /ai/chat/message
  static Future<AIMessage> sendAIMessage(String content) async {
    await Future.delayed(const Duration(milliseconds: 1500)); // 模拟AI响应时间
    return AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: false,
      content: '这是AI的回复：$content',
      timestamp: DateTime.now(),
    );
  }

  /// TODO: 获取会员套餐列表（兼容旧方法）
  /// 接口: GET /member/packages
  static Future<List<MembershipPackage>> getMembershipPackages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      MembershipPackage(
        id: '1',
        name: '月度会员',
        durationDays: 30,
        price: 29.9,
        originalPrice: 39.9,
        isPopular: false,
      ),
      MembershipPackage(
        id: '2',
        name: '季度会员',
        durationDays: 90,
        price: 79.9,
        originalPrice: 119.7,
        isPopular: true,
      ),
      MembershipPackage(
        id: '3',
        name: '年度会员',
        durationDays: 365,
        price: 299.9,
        originalPrice: 478.8,
        isPopular: false,
      ),
    ];
  }

  /// TODO: 获取当前会员状态（兼容旧方法）
  /// 接口: GET /member/info
  static Future<MembershipStatus> getMembershipStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MembershipStatus(
      isMember: false,
      memberType: null,
      expireDate: null,
      autoRenewal: false,
    );
  }

  /// TODO: 购买会员（兼容旧方法）
  /// 接口: POST /member/order/create
  static Future<bool> purchaseMembership({
    required String packageId,
    required String paymentMethod, // wechat, alipay
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // 模拟支付流程
    // TODO: 实际应该调用支付接口
    return true;
  }

  /// TODO: 全局搜索
  /// 接口: GET /search?keyword={keyword}&type={type}&page={page}&pageSize={pageSize}
  static Future<Map<String, dynamic>> search(String keyword, {
    String type = 'all', // 'all', 'post', 'recipe', 'knowledge'
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final posts = await getPosts(page: page, limit: pageSize);
    final recipes = await getTodayRecipes();

    // 模拟搜索结果
    final results = <Map<String, dynamic>>[];

    // 帖子结果
    if (type == 'all' || type == 'post') {
      results.addAll(posts.take(3).map((post) => {
        'type': 'post',
        'postId': post.id,
        'title': post.title,
        'content': post.content,
        'imageUrl': post.images.isNotEmpty ? post.images.first : null,
        'meta': {
          'author': post.authorName,
          'time': post.publishTime.toIso8601String(),
          'likes': post.likes,
        },
      }));
    }

    // 食谱结果
    if (type == 'all' || type == 'recipe') {
      results.addAll(recipes.take(2).map((recipe) => {
        'type': 'recipe',
        'recipeId': recipe.id,
        'title': recipe.name,
        'content': recipe.description,
        'imageUrl': recipe.imageUrl,
        'meta': {
          'calories': recipe.nutrition['calories'],
          'time': '${recipe.cookingTime}分钟',
        },
      }));
    }

    // 健康知识结果（模拟）
    if (type == 'all' || type == 'knowledge') {
      results.add({
        'type': 'knowledge',
        'knowledgeId': 'knowledge_1',
        'title': '春季如何提高免疫力',
        'content': '春季是万物复苏的季节，也是人体免疫力需要提升的关键时期。通过合理的饮食搭配、适量运动和充足睡眠，可以有效提高身体免疫力...',
        'meta': {
          'views': 1200,
        },
      });
    }

    return {
      'code': '200',
      'message': 'success',
      'data': {
        'results': results,
        'total': results.length,
        'page': page,
        'pageSize': pageSize,
      },
    };
  }

  /// TODO: 上传面相/手相图片进行分析（兼容旧方法）
  /// 接口: POST /health/face-analysis
  static Future<FortuneAnalysis> analyzeImage({
    required String imagePath,
    required String type, // face, palm
  }) async {
    await Future.delayed(const Duration(seconds: 3)); // 模拟AI分析时间
    // TODO: 实际上传图片到服务器，调用AI分析接口
    return FortuneAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      analysisDate: DateTime.now(),
      analysisType: type,
      faceAnalysis: {},
      palmAnalysis: {},
      baziAnalysis: {},
      fortuneScores: {'career': 85, 'health': 78, 'wealth': 92, 'emotion': 80},
      summary: '分析结果总结...',
      suggestions: ['建议1', '建议2'],
    );
  }

  /// TODO: 获取历史分析报告（兼容旧方法）
  /// 接口: GET /health/reports
  static Future<List<FortuneAnalysis>> getAnalysisHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  /// TODO: 连接智能设备（兼容旧方法）
  /// 接口: POST /health/device/connect
  static Future<bool> connectHealthDevice({
    required String deviceType, // huawei, xiaomi, apple_watch
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    // TODO: 实际应该调用设备SDK进行连接
    return true;
  }

  /// TODO: 同步健康数据（兼容旧方法）
  /// 接口: GET /health/data/sync
  static Future<List<HealthData>> syncHealthData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return [];
  }

  /// TODO: 上传舌象照片（兼容旧方法）
  /// 接口: POST /health/tongue
  static Future<HealthData> uploadTongueImage(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));
    return HealthData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      constitutionType: '平和质',
    );
  }
}


