import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/app_text.dart';
import '../../widgets/common/app_card.dart';
import '../../services/mock_service.dart';
import '../../providers/auth_provider.dart';

/// 个性化引导设置页面
/// 
/// 功能：
/// 1. 核心习惯设置（是否开启每日提醒）
/// 2. 基本信息录入（出生日期和性别）
/// 3. 提交设置
class OnboardingPreferencesPage extends StatefulWidget {
  const OnboardingPreferencesPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPreferencesPage> createState() => _OnboardingPreferencesPageState();
}

class _OnboardingPreferencesPageState extends State<OnboardingPreferencesPage> {
  bool _dailyReminder = true;
  String? _selectedGender; // 'M', 'F', 'U'
  DateTime? _selectedBirthday;
  bool _isSubmitting = false;

  /// 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  /// 提交设置
  Future<void> _submitPreferences() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择性别')),
      );
      return;
    }

    if (_selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择出生日期')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await MockService.updatePreferences(
        dailyReminder: _dailyReminder,
        birthday: _selectedBirthday!.toIso8601String().split('T')[0],
        gender: _selectedGender,
      );

      if (response['code'] == '200') {
        // 更新用户信息
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user != null) {
          final updatedUser = authProvider.user!.copyWith(
            gender: _selectedGender,
            birthday: _selectedBirthday!.toIso8601String().split('T')[0],
          );
          authProvider.updateUser(updatedUser);
        }

        if (mounted) {
          // 跳转到权限申请页面
          context.push('/onboarding/permissions');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] as String)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置失败，请重试')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
              AppText.displayLarge('个性化设置'),
              const SizedBox(height: 8),
              AppText(
                '让我们更好地了解您，为您提供个性化服务',
                style: TextStyle(color: AppColors.graySecondary),
              ),

              const SizedBox(height: 40),

              // 每日提醒开关
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.displaySmall('每日提醒'),
                            const SizedBox(height: 4),
                            AppText(
                              '每日推送运势和健康建议',
                              style: TextStyle(
                                color: AppColors.graySecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _dailyReminder,
                          onChanged: (value) {
                            setState(() {
                              _dailyReminder = value;
                            });
                          },
                          activeColor: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 性别选择
              AppText.displaySmall('性别'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderOption('M', '男'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderOption('F', '女'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderOption('U', '未知'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 出生日期选择
              AppText.displaySmall('出生日期'),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        _selectedBirthday == null
                            ? '请选择出生日期'
                            : '${_selectedBirthday!.year}年${_selectedBirthday!.month}月${_selectedBirthday!.day}日',
                        style: TextStyle(
                          color: _selectedBirthday == null
                              ? AppColors.graySecondary
                              : AppColors.grayTitle,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.graySecondary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : AppText(
                          '下一步',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String value, String label) {
    final isSelected = _selectedGender == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlueLight : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: AppText(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : AppColors.grayText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

