import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/colors.dart';
import 'utils/constants.dart';
import 'views/home/home_page.dart';
import 'views/calendar/calendar_page.dart';
import 'views/menu/add_task_page.dart';
import 'widgets/custom_bottom_nav.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/calendar_viewmodel.dart';

/// アプリのルート
class CleanUpApp extends StatelessWidget {
  const CleanUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TaskViewModel()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => CalendarViewModel()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: '.SF Pro Text', // iOSのデフォルトフォント
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            background: AppColors.background,
            surface: AppColors.white,
            error: AppColors.error,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.white,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            iconTheme: IconThemeData(color: AppColors.gray800),
            titleTextStyle: AppTextStyles.h2,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

/// メイン画面（ナビゲーション付き）
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 各画面
  final List<Widget> _pages = [
    const HomePage(),
    const CalendarPage(),
    const AddTaskPage(), // タスク追加画面を直接表示
    const _PlaceholderPage(title: 'その他'),
  ];

  // ナビゲーションアイテム
  final List<NavItem> _navItems = const [
    NavItem(
      icon: Icons.home_outlined,
      label: 'ホーム',
      imagePath: 'assets/images/owl_home.jpeg',
    ),
    NavItem(
      icon: Icons.calendar_today_outlined,
      label: 'カレンダー',
      imagePath: 'assets/images/owl_calender.jpeg',
    ),
    NavItem(
      icon: Icons.cleaning_services_outlined,
      label: 'タスク',
      imagePath: 'assets/images/owl_clean.jpeg',
    ),
    NavItem(
      icon: Icons.more_horiz,
      label: 'その他',
      imagePath: 'assets/images/owl_other.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }
}

/// プレースホルダー画面（実装予定の画面用）
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(children: [Text(title, style: AppTextStyles.h1)]),
            ),

            // コンテンツ
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🦉', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: AppSpacing.lg),
                    Text('$title画面', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.sm),
                    Text('実装予定', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
