import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/common/app_card.dart';

/// 权限申请页面
/// 
/// 功能：
/// 1. 申请位置权限
/// 2. 申请通知权限
/// 3. 调用系统权限申请弹窗
class OnboardingPermissionsPage extends StatefulWidget {
  const OnboardingPermissionsPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPermissionsPage> createState() => _OnboardingPermissionsPageState();
}

class _OnboardingPermissionsPageState extends State<OnboardingPermissionsPage> {
  bool _locationGranted = false;
  bool _notificationGranted = false;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  /// 检查权限状态
  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;

    setState(() {
      _locationGranted = locationStatus.isGranted;
      _notificationGranted = notificationStatus.isGranted;
    });
  }

  /// 申请位置权限
  Future<void> _requestLocationPermission() async {
    setState(() {
      _isRequesting = true;
    });

    final status = await Permission.location.request();
    
    setState(() {
      _locationGranted = status.isGranted;
      _isRequesting = false;
    });

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('位置权限已授予')),
      );
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog('位置权限', '请在设置中手动开启位置权限');
    }
  }

  /// 申请通知权限
  Future<void> _requestNotificationPermission() async {
    setState(() {
      _isRequesting = true;
    });

    final status = await Permission.notification.request();
    
    setState(() {
      _notificationGranted = status.isGranted;
      _isRequesting = false;
    });

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('通知权限已授予')),
      );
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog('通知权限', '请在设置中手动开启通知权限');
    }
  }

  /// 显示权限说明对话框
  void _showPermissionDialog(String permissionName, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName说明'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 跳过权限申请
  void _skipPermissions() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // 标题
              AppText.displayLarge('权限申请'),
              const SizedBox(height: 8),
              AppText(
                '为了给您提供更好的服务，我们需要以下权限',
                style: TextStyle(color: AppColors.graySecondary),
              ),

              const SizedBox(height: 40),

              // 位置权限
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlueLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.displaySmall('位置权限'),
                              const SizedBox(height: 4),
                              AppText(
                                '用于提供基于位置的个性化服务',
                                style: TextStyle(
                                  color: AppColors.graySecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_locationGranted)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          )
                        else
                          ElevatedButton(
                            onPressed: _isRequesting ? null : _requestLocationPermission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              minimumSize: const Size(80, 36),
                            ),
                            child: const Text('申请', style: TextStyle(color: Colors.white)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 通知权限
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlueLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: AppColors.primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.displaySmall('通知权限'),
                              const SizedBox(height: 4),
                              AppText(
                                '用于推送每日运势和健康提醒',
                                style: TextStyle(
                                  color: AppColors.graySecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_notificationGranted)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          )
                        else
                          ElevatedButton(
                            onPressed: _isRequesting ? null : _requestNotificationPermission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              minimumSize: const Size(80, 36),
                            ),
                            child: const Text('申请', style: TextStyle(color: Colors.white)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 完成按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _skipPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: AppText(
                    '完成',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 跳过按钮
              TextButton(
                onPressed: _skipPermissions,
                child: AppText(
                  '跳过',
                  style: TextStyle(color: AppColors.graySecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




