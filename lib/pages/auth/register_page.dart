import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/app_text.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart'; // 核心修改：使用统一的 ApiService
import '../../widgets/loading_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSendingCode = false;
  int _countdown = 0;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ==================== 业务逻辑 ====================

  /// 发送验证码
  Future<void> _sendCode() async {
    if (_mobileController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的手机号')));
      return;
    }

    setState(() => _isSendingCode = true);

    try {
      // 统一调用 ApiService，它会根据 useMock 开关自动选择环境
      final response = await ApiService().post('/auth/send-code', data: {
        'mobile': _mobileController.text.trim(),
        'type': 'register',
      });

      if (response['code'] == '200') {
        setState(() {
          _countdown = 60;
          _isSendingCode = false;
        });
        _startCountdown();

        String tip = ApiService().useMock ? '验证码已发送 (测试码: 123456)' : '验证码已发送';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tip)));
      }
    } catch (e) {
      setState(() => _isSendingCode = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发送失败: $e')));
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        _startCountdown();
      }
    });
  }

  /// 执行注册
  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 调用 AuthProvider 的注册，它内部会通过 ApiService 执行请求并持久化用户信息
    final success = await authProvider.register(
      _mobileController.text.trim(),
      _codeController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      // 注册成功，按照接口文档流程，跳转到欢迎页设置生辰
      context.go('/onboarding/welcome');
    } else {
      setState(() => _errorMessage = '注册失败，请检查验证码或账号是否已存在');
    }
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTraditionalHeader(),
                const SizedBox(height: 32),

                // 手机号输入框封装
                _buildInputContainer(
                  child: TextFormField(
                    controller: _mobileController,
                    decoration: _buildDecoration('手机号', Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.length != 11) ? '请输入11位手机号' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // 验证码
                Row(
                  children: [
                    Expanded(
                      child: _buildInputContainer(
                        child: TextFormField(
                          controller: _codeController,
                          decoration: _buildDecoration('验证码', Icons.verified_user_outlined),
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.isEmpty) ? '请输入验证码' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildCodeButton(),
                  ],
                ),
                const SizedBox(height: 16),

                // 密码
                _buildInputContainer(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _buildDecoration('设置密码', Icons.lock_outline, isPassword: true,
                        obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
                    validator: (v) => (v == null || v.length < 6) ? '密码至少6位' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // 确认密码
                _buildInputContainer(
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _buildDecoration('确认密码', Icons.lock_reset, isPassword: true,
                        obscure: _obscureConfirmPassword, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                    validator: (v) => (v != _passwordController.text) ? '两次密码不一致' : null,
                  ),
                ),

                if (_errorMessage != null) _buildErrorTip(),

                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI 组件封装 ---

  Widget _buildTraditionalHeader() {
    return Column(
      children: [
        Stack(alignment: Alignment.center, children: [
          Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.line))),
          Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.line))),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.gold, width: 1.5)),
            child: Center(child: AppText('缘', style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w500))),
          ),
        ]),
        const SizedBox(height: 24),
        AppText('注册账号', style: TextStyle(color: AppColors.ink, fontSize: 24, letterSpacing: 4, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        AppText('创建您的灵境账号，开启AI命理之旅', style: TextStyle(color: AppColors.graySecondary, fontSize: 13)),
      ],
    );
  }

  InputDecoration _buildDecoration(String label, IconData icon, {bool isPassword = false, bool? obscure, VoidCallback? onToggle}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
      suffixIcon: isPassword ? IconButton(icon: Icon(obscure! ? Icons.visibility_off : Icons.visibility, size: 20, color: AppColors.graySecondary), onPressed: onToggle) : null,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  Widget _buildCodeButton() {
    return SizedBox(
      width: 100,
      height: 52,
      child: ElevatedButton(
        onPressed: _countdown > 0 || _isSendingCode ? null : _sendCode,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
        child: _isSendingCode
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : AppText(_countdown > 0 ? '${_countdown}s' : '发送', style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) return const Center(child: LoadingWidget());
        return ElevatedButton(
          onPressed: _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            elevation: 0,
          ),
          child: AppText('注册', style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 4)),
        );
      },
    );
  }

  Widget _buildErrorTip() {
    return Padding(padding: const EdgeInsets.only(top: 12), child: Text(_errorMessage!, style: TextStyle(color: AppColors.error, fontSize: 12)));
  }

  Widget _buildLoginLink() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      AppText('已有账号？', style: TextStyle(color: AppColors.graySecondary, fontSize: 13)),
      TextButton(onPressed: () => context.pop(), child: AppText('立即登录', style: TextStyle(color: AppColors.gold, fontSize: 13, decoration: TextDecoration.underline))),
    ]);
  }
}