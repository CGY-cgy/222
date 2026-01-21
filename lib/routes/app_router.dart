import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../pages/onboarding_page.dart';
import '../pages/auth/login_page_new.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/onboarding_welcome_page.dart';
import '../pages/auth/onboarding_preferences_page.dart';
import '../pages/auth/onboarding_permissions_page_simple.dart';
import '../pages/main_navigation_page.dart';
import '../pages/post_detail_page.dart'; // 确认你有这个文件
import '../models/post.dart'; // 对应你文件树中的 post.dart
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

/// 应用路由配置
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',

      redirect: (BuildContext context, GoRouterState state) async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (authProvider.isLoading) {
          return null;
        }

        final isFirstLaunch = await StorageService.isFirstLaunch();
        if (isFirstLaunch) {
          if (state.uri.path != '/onboarding') {
            return '/onboarding';
          }
          return null;
        }

        final isAuthPage = state.uri.path == '/login' || state.uri.path == '/register';
        final isOnboardingFlow = state.uri.path.startsWith('/onboarding');

        if (!authProvider.isAuthenticated && !isAuthPage && !isOnboardingFlow) {
          return '/login';
        }

        if (authProvider.isAuthenticated) {
          final user = authProvider.user;

          if (user?.isNewUser == true) {
            if (isOnboardingFlow) return null;
            return '/onboarding/welcome';
          }

          if (isAuthPage || isOnboardingFlow) {
            return '/';
          }
        }

        return null;
      },

      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('页面未找到: ${state.uri.path}')),
      ),

      routes: [
        // 1. 引导页
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),

        // 2. 认证页
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPageNew(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),

        // 3. 个性化引导流程
        GoRoute(
          path: '/onboarding/welcome',
          builder: (context, state) => const OnboardingWelcomePage(),
        ),
        GoRoute(
          path: '/onboarding/preferences',
          builder: (context, state) => const OnboardingPreferencesPage(),
        ),
        GoRoute(
          path: '/onboarding/permissions',
          builder: (context, state) => const OnboardingPermissionsPageSimple(),
        ),

        // 4. 首页
        GoRoute(
          path: '/',
          builder: (context, state) => const MainNavigationPage(),
        ),

        // 5. 帖子详情页 (新增修改点)
        // 使用 extra 传递整个对象，跳转更丝滑
        GoRoute(
          path: '/post-detail',
          builder: (context, state) {
            final post = state.extra as Post;
            return PostDetailPage(post: post);
          },
        ),
      ],
    );
  }
}