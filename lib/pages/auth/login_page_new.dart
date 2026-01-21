import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/app_text.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart'; // 核心：使用 ApiService 调度中心
import '../../widgets/loading_widget.dart';

/// 登录页 - 传统玄学风格
///
/// 设计：纸张色背景 + 金色命盘装饰 (参考 index.html)
/// 逻辑：
/// 1. UI 层：负责数据校验与交互反馈。
/// 2. Provider 层：负责全局认证状态管理。
/// 3. Service 层：ApiService 根据 useMock 开关调度数据。
class LoginPageNew extends StatefulWidget {
  const LoginPageNew({Key? key}) : super(key: key);

  @override
  State<LoginPageNew> createState() => _LoginPageNewState();
}

class _LoginPageNewState extends State<LoginPageNew> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 账号密码登录表单控制器
  final _accountFormKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _accountError;

  // 手机号验证码登录表单控制器
  final _mobileFormKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isSendingCode = false;
  int _countdown = 0;
  String? _mobileError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // ==================== 业务逻辑 ====================

  /// 账号密码登录
  Future<void> _handleAccountLogin() async {
    setState(() => _accountError = null);
    if (!_accountFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _accountController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      _handleLoginSuccess();
    } else {
      setState(() => _accountError = '登录失败，请检查账号和密码');
    }
  }

  /// 手机号一键登录
  Future<void> _handleMobileLogin() async {
    setState(() => _mobileError = null);
    if (!_mobileFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.mobileLogin(
      _mobileController.text.trim(),
      _codeController.text.trim(),
    );

    if (success && mounted) {
      _handleLoginSuccess();
    } else {
      setState(() => _mobileError = '登录失败，请检查验证码');
    }
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    if (_mobileController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的手机号')));
      return;
    }

    setState(() => _isSendingCode = true);
    try {
      final response = await ApiService().post('/auth/send-code', data: {
        'mobile': _mobileController.text.trim(),
        'type': 'login',
      });

      if (response['code'] == '200') {
        setState(() {
          _countdown = 60;
          _isSendingCode = false;
        });
        _startCountdown();

        String tip = ApiService().useMock ? '验证码已发送 (测试码: 123456)' : '验证码已发送';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tip)));
      } else {
        throw Exception(response['message'] ?? '发送失败');
      }
    } catch (e) {
      setState(() => _isSendingCode = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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

  void _handleLoginSuccess() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.isNewUser == true) {
      context.go('/onboarding/welcome');
    } else {
      context.go('/');
    }
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTraditionalHeader(),
              const SizedBox(height: 32),
              _buildTabBar(),
              const SizedBox(height: 24),
              SizedBox(
                height: 340,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAccountLoginForm(),
                    _buildMobileLoginForm(),
                  ],
                ),
              ),
              _buildSocialLogin(),
              const SizedBox(height: 20),
              _buildRegisterLink(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: kDebugMode ? _buildDebugFab() : null,
    );
  }

  Widget _buildTraditionalHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.line))),
            Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.line))),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.gold, width: 1.5)),
              child: Center(child: AppText('命', style: TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.w500))),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppText('灵境', style: TextStyle(color: AppColors.ink, fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        AppText('以数起局 · 以象观命', style: TextStyle(color: AppColors.graySecondary, fontSize: 12, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(color: AppColors.inputBackground, borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        indicator: null,
        labelColor: AppColors.gold,
        unselectedLabelColor: Colors.black,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        tabs: const [Tab(text: '账号密码登录'), Tab(text: '手机号一键登录')],
      ),
    );
  }

  Widget _buildAccountLoginForm() {
    return Form(
      key: _accountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(_accountController, '请输入手机号或账号', Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(
            _passwordController, '请输入密码', Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          if (_accountError != null) _buildErrorText(_accountError!),
          const SizedBox(height: 24),
          _buildSubmitButton('登录', _handleAccountLogin),
        ],
      ),
    );
  }

  Widget _buildMobileLoginForm() {
    return Form(
      key: _mobileFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(_mobileController, '请输入手机号', Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(_codeController, '验证码', Icons.verified_user_outlined, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              _buildCodeButton(),
            ],
          ),
          if (_mobileError != null) _buildErrorText(_mobileError!),
          const SizedBox(height: 24),
          _buildSubmitButton('一键登录', _handleMobileLogin),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, bool obscureText = false, VoidCallback? onToggleVisibility, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.gold),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.graySecondary), onPressed: onToggleVisibility) : null,
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (v) => (v == null || v.isEmpty) ? '内容不能为空' : null,
    );
  }

  Widget _buildCodeButton() {
    return SizedBox(
      width: 100,
      height: 50,
      child: ElevatedButton(
        onPressed: _countdown > 0 || _isSendingCode ? null : _sendCode,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
        child: _isSendingCode
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : AppText(_countdown > 0 ? '${_countdown}s' : '发送', style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) return const SizedBox(height: 50, child: Center(child: LoadingWidget()));
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
          child: AppText(label, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 4)),
        );
      },
    );
  }

  Widget _buildErrorText(String text) {
    return Padding(padding: const EdgeInsets.only(top: 8), child: Text(text, style: TextStyle(color: AppColors.error, fontSize: 12)));
  }

// ==================== UI 组件封装 ====================

  /// 第三方登录区域
  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: Divider(color: AppColors.line)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppText('第三方登录', style: TextStyle(color: AppColors.graySecondary, fontSize: 12))
          ),
          Expanded(child: Divider(color: AppColors.line))
        ]),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.chat, '微信', const Color(0xFFB4E1B4), () => context.go('/')),
            const SizedBox(width: 32),
            _buildSocialIcon(Icons.account_balance_wallet, '支付宝', const Color(0xFFB4D9FF), () => context.go('/')),
          ],
        ),
      ],
    );
  }

  /// 社交平台图标按钮
  /// 修复：确保这里是非命名参数定义，以匹配你上面的调用方式
  Widget _buildSocialIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Column(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 4),
              AppText(label, style: TextStyle(color: color, fontSize: 12))
            ]
        )
    );
  }

  /// 注册跳转链接
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText('还没有账号？', style: TextStyle(color: AppColors.graySecondary, fontSize: 13)),
        TextButton(
            onPressed: () => context.push('/register'),
            child: AppText(
                '立即注册',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 13,
                    decoration: TextDecoration.underline
                )
            )
        ),
      ],
    );
  }

  /// 调试用的悬浮按钮 (仅在 Debug 模式显示)
  Widget _buildDebugFab() {
    return FloatingActionButton(
      mini: true,
      backgroundColor: AppColors.gold.withOpacity(0.8),
      onPressed: () => showModalBottomSheet(
          context: context,
          builder: (bottomSheetContext) => ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('跳过登录进首页'),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      context.go('/');
                    }
                ),
                ListTile(
                    leading: const Icon(Icons.app_registration),
                    title: const Text('前往注册页'),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      context.push('/register');
                    }
                ),
              ]
          )
      ),
      child: const Icon(Icons.bug_report, size: 18, color: Colors.white),
    );
  }
} // 结束类定义