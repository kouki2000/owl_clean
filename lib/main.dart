import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'views/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 日本語のロケールを初期化
  await initializeDateFormatting('ja_JP');
  Intl.defaultLocale = 'ja_JP';

  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // フェード時間を考慮して2.2秒後に切り替え開始
    // 2.2秒 + 0.8秒(フェード) = 3秒
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '猫とお掃除',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      locale: const Locale('ja', 'JP'),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800), // フェード時間800ms
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _showSplash
            ? const SplashScreen(key: ValueKey('splash'))
            : const CleanUpApp(key: ValueKey('app')),
      ),
    );
  }
}
