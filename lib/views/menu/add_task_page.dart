import 'package:flutter/material.dart';
import 'package:owl_clean/viewmodels/calendar_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../models/task.dart';
import 'task_detail_page.dart';

/// タスク追加画面（フルスクリーン）
class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // カテゴリ（全て画像に統一）
  final List<Map<String, dynamic>> _categories = [
    {'name': 'すべて', 'icon': Icons.grid_view},
    {'name': 'トイレ', 'icon': Icons.wc},
    {'name': 'キッチン', 'icon': Icons.kitchen},
    {'name': 'リビング', 'icon': Icons.living},
    {'name': '寝室', 'icon': Icons.hotel},
    {'name': 'お風呂', 'icon': Icons.bathtub},
    {'name': 'ゴミ出し', 'icon': Icons.delete},
    {'name': 'その他', 'icon': Icons.more_horiz},
  ];

  // タスクテンプレート
  final Map<String, List<Map<String, String>>> _taskTemplates = {
    'トイレ': [
      {'name': 'トイレ掃除'},
      {'name': '便座拭き'},
      {'name': 'タンク掃除'},
      {'name': 'トイレマット洗濯'},
    ],
    'キッチン': [
      {'name': 'シンク掃除'},
      {'name': 'コンロ掃除'},
      {'name': '冷蔵庫整理'},
      {'name': '換気扇掃除'},
      {'name': '食器洗い'},
      {'name': '床拭き'},
    ],
    'リビング': [
      {'name': '掃除機かけ'},
      {'name': '床掃除'},
      {'name': '窓拭き'},
      {'name': 'ソファ掃除'},
      {'name': 'テーブル拭き'},
      {'name': 'エアコン掃除'},
    ],
    '寝室': [
      {'name': 'シーツ交換'},
      {'name': '布団干し'},
      {'name': '枕カバー交換'},
      {'name': 'ベッド下掃除'},
      {'name': 'クローゼット整理'},
    ],
    'お風呂': [
      {'name': '浴槽掃除'},
      {'name': '排水口掃除'},
      {'name': 'カビ取り'},
      {'name': '鏡磨き'},
      {'name': '洗面台掃除'},
      {'name': 'お風呂マット洗濯'},
    ],
    'ゴミ出し': [
      {'name': '燃えるゴミ'},
      {'name': '燃えないゴミ'},
      {'name': '資源ゴミ'},
      {'name': 'プラスチック'},
      {'name': '紙類'},
      {'name': 'ビン・カン'},
      {'name': 'ペットボトル'},
      {'name': '粗大ゴミ'},
    ],
    'その他': [
      {'name': '玄関掃除'},
      {'name': 'ベランダ掃除'},
      {'name': '照明掃除'},
      {'name': '観葉植物の水やり'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _searchController.clear();
        _searchQuery = '';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            _buildHeader(),

            // タブバー
            _buildTabBar(),

            // メインコンテンツ
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // タブ1: テンプレート
                  _buildTemplateTab(),
                  // タブ2: マイタスク
                  _buildMyTasksTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ヘッダー
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // タイトル行
          Row(
            children: [
              Expanded(
                child: Text(
                  'タスク一覧',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToTaskDetail(),
                child: Text(
                  '新規タスク追加',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 検索バー
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'タスクを検索',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.gray400,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.gray400,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.gray50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ],
      ),
    );
  }

  /// タブバー
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'テンプレート'),
          Tab(text: 'マイタスク'),
        ],
        labelColor: AppColors.gray800,
        unselectedLabelColor: AppColors.gray400,
        indicatorColor: AppColors.gray800,
        labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w400),
        unselectedLabelStyle: AppTextStyles.body,
      ),
    );
  }

  /// テンプレートタブ
  Widget _buildTemplateTab() {
    return Row(
      children: [
        // 左側：カテゴリサイドバー
        _buildCategorySidebar(),

        // 右側：タスクリスト
        Expanded(
          child: _buildTaskList(),
        ),
      ],
    );
  }

  /// マイタスクタブ
  Widget _buildMyTasksTab() {
    final viewModel = context.watch<TaskViewModel>();
    final tasks = viewModel.tasks;

    // 検索フィルター
    final filteredTasks = _searchQuery.isEmpty
        ? tasks
        : tasks
            .where((task) => task.title.toLowerCase().contains(_searchQuery))
            .toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              _searchQuery.isEmpty
                  ? 'まだ新しく作成したタスクがありません\n「新規タスク追加」から\n自分用のタスクを追加してください'
                  : '該当するタスクが見つかりません',
              style: AppTextStyles.body.copyWith(
                color: AppColors.gray400,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return _buildMyTaskItem(task);
      },
    );
  }

  /// マイタスクアイテム
  Widget _buildMyTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: Icon(
          _getCategoryIconById(task.categoryId),
          color: AppColors.gray600,
          size: 24,
        ),
        title: Text(
          task.title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        subtitle: Text(
          _getRepeatTypeText(task.repeatType),
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: AppColors.error,
            size: 20,
          ),
          onPressed: () => _deleteTask(task),
        ),
      ),
    );
  }

  String _getRepeatTypeText(RepeatType type) {
    switch (type) {
      case RepeatType.none:
        return '繰り返しなし';
      case RepeatType.daily:
        return '毎日';
      case RepeatType.weekly:
        return '毎週';
      case RepeatType.biweekly: // ⚠️ 追加
        return '隔週';
      case RepeatType.monthly:
        return '毎月';
    }
  }

  IconData _getCategoryIconById(String? categoryId) {
    switch (categoryId) {
      case 'toilet':
        return Icons.wc;
      case 'kitchen':
        return Icons.kitchen;
      case 'living':
        return Icons.living;
      case 'bedroom':
        return Icons.hotel;
      case 'bath':
        return Icons.bathtub;
      case 'garbage':
        return Icons.delete;
      default:
        return Icons.more_horiz;
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${task.title}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '削除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final taskViewModel = context.read<TaskViewModel>();
      final calendarViewModel = context.read<CalendarViewModel>(); // ⚠️ 追加

      await taskViewModel.deleteTask(task.id);
      await calendarViewModel.loadTasks(); // ⚠️ カレンダーもリロード

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「${task.title}」を削除しました'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// カテゴリサイドバー
  Widget _buildCategorySidebar() {
    return Container(
      width: 100,
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          final icon = category['icon'] as IconData;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? AppColors.gray800 : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: isSelected ? 64 : 56, // ⚠️ 大きく
                    height: isSelected ? 64 : 56, // ⚠️ 大きく
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.gray800 : AppColors.gray200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? AppColors.white : AppColors.gray600,
                      size: isSelected ? 32 : 28, // ⚠️ 大きく
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['name'],
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w400 : FontWeight.w300,
                      color: isSelected ? AppColors.gray800 : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// タスクリスト
  Widget _buildTaskList() {
    final categoryName = _categories[_selectedCategoryIndex]['name'];

    // 「すべて」が選択されている場合
    if (_selectedCategoryIndex == 0) {
      // カテゴリーごとにグループ化して表示
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _taskTemplates.length,
        itemBuilder: (context, index) {
          final categoryName = _taskTemplates.keys.elementAt(index);
          final tasks = _taskTemplates[categoryName]!;

          // 検索フィルター
          final filteredTasks = _searchQuery.isEmpty
              ? tasks
              : tasks
                  .where((task) =>
                      task['name']!.toLowerCase().contains(_searchQuery))
                  .toList();

          if (filteredTasks.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // カテゴリーヘッダー
              if (index > 0) const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(categoryName),
                      size: 20,
                      color: AppColors.gray600,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      categoryName,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              // タスクリスト
              ...filteredTasks.map((task) {
                return _buildTaskItem(name: task['name']!);
              }).toList(),
            ],
          );
        },
      );
    }

    // 特定のカテゴリーが選択されている場合
    List<Map<String, String>> tasks = _taskTemplates[categoryName] ?? [];

    // 検索フィルター
    if (_searchQuery.isNotEmpty) {
      tasks = tasks
          .where((task) => task['name']!.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              '該当するタスクが見つかりません',
              style: AppTextStyles.body.copyWith(
                color: AppColors.gray400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(name: task['name']!);
      },
    );
  }

  /// カテゴリー名からアイコンを取得
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'トイレ':
        return Icons.wc;
      case 'キッチン':
        return Icons.kitchen;
      case 'リビング':
        return Icons.living;
      case '寝室':
        return Icons.hotel;
      case 'お風呂':
        return Icons.bathtub;
      case 'ゴミ出し':
        return Icons.delete;
      case 'その他':
        return Icons.more_horiz;
      default:
        return Icons.more_horiz;
    }
  }

  /// タスクアイテム
  Widget _buildTaskItem({required String name}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        title: Text(
          name,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14, // ⚠️ 小さく
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.gray50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.gray800,
            size: 20,
          ),
        ),
        onTap: () => _navigateToTaskDetail(taskName: name),
      ),
    );
  }

  /// タスク詳細画面に遷移
  void _navigateToTaskDetail({String? taskName}) {
    // タスク名からカテゴリーIDを推測
    String? categoryId;
    if (taskName != null) {
      for (var entry in _taskTemplates.entries) {
        if (entry.value.any((task) => task['name'] == taskName)) {
          categoryId = _getCategoryIdByName(entry.key);
          break;
        }
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(
          initialTaskName: taskName,
          categoryId: categoryId,
          isTemplate: taskName != null,
        ),
      ),
    );
  }

  /// カテゴリー名からcategoryIdを取得
  String? _getCategoryIdByName(String categoryName) {
    switch (categoryName) {
      case 'トイレ':
        return 'toilet';
      case 'キッチン':
        return 'kitchen';
      case 'リビング':
        return 'living';
      case '寝室':
        return 'bedroom';
      case 'お風呂':
        return 'bath';
      case 'ゴミ出し':
        return 'garbage';
      default:
        return null;
    }
  }
}
