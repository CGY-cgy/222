/// 用户模型 - 用于认证和用户信息管理
class User {
  final int userId;
  final String mobile;
  final String nickname;
  final String? avatarUrl;
  final String? gender; // 'M', 'F', 'U'
  final String? birthday;
  final bool isNewUser; // 是否新用户（需要完善信息）

  User({
    required this.userId,
    required this.mobile,
    required this.nickname,
    this.avatarUrl,
    this.gender,
    this.birthday,
    this.isNewUser = false,
  });

  /// 从 JSON 创建 User 对象
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int,
      mobile: json['mobile'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] as String?,
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'mobile': mobile,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'birthday': birthday,
      'isNewUser': isNewUser,
    };
  }

  /// 创建副本（用于更新部分字段）
  User copyWith({
    int? userId,
    String? mobile,
    String? nickname,
    String? avatarUrl,
    String? gender,
    String? birthday,
    bool? isNewUser,
  }) {
    return User(
      userId: userId ?? this.userId,
      mobile: mobile ?? this.mobile,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

