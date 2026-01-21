import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
// 1. 必须导入这个包（如果报错，请看下方的 pubspec.yaml 说明）
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/auth_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化中文Locale
  await initializeDateFormatting('zh_CN', null);
  runApp(const LingJingApp());
}

class LingJingApp extends StatelessWidget {
  const LingJingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp.router(
        title: '灵境',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: AppRouter.createRouter(),

        // --- 在这里添加下面这段代码 ---
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CH'), // 中文
          Locale('en', 'US'), // 英文
        ],
        locale: const Locale('zh', 'CH'), // 强制指定默认语言为中文
        // ----------------------------
      ),
    );
  }
}