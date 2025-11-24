import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/calendar_viewmodel.dart';
import '../../models/task.dart';

/// タスク追加画面（フルスクリーン）
class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RepeatType _selectedRepeatType = RepeatType.none;

  // カテゴリ（全て画像に統一）
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'すべて',
      'image': 'assets/images/owl_all.jpeg',
    },
    {
      'name': 'トイレ',
      'image': 'assets/images/owl_toilet.jpeg',
    },
    {
      'name': 'キッチン',
      'image': 'assets/images/owl_cook.jpeg',
    },
    {
      'name': 'リビング',
      'image': 'assets/images/owl_living.jpeg',
    },
    {
      'name': '寝室',
      'image': 'assets/images/owl_sleep.jpeg',
    },
    {
      'name': 'お風呂',
      'image': 'assets/images/owl_bath.jpeg',
    },
    {
      'name': 'その他',
      'image': 'assets/images/owl_other.jpeg',
    },
  ];

  // タスクテンプレート
  final Map<String, List<Map<String, String>>> _taskTemplates = {
    'トイレ': [
      {'name': 'トイレ掃除', 'subtitle': '便器・床・壁'},
      {'name': '便座拭き', 'subtitle': '毎日のケア'},
      {'name': 'タンク掃除', 'subtitle': '月1回'},
      {'name': 'トイレマット洗濯', 'subtitle': '週1回'},
    ],
    'キッチン': [
      {'name': 'シンク掃除', 'subtitle': '水垢・油汚れ'},
      {'name': 'コンロ掃除', 'subtitle': '油汚れ除去'},
      {'name': '冷蔵庫整理', 'subtitle': '賞味期限チェック'},
      {'name': '換気扇掃除', 'subtitle': '月1回'},
      {'name': '食器洗い', 'subtitle': '毎日'},
      {'name': '床拭き', 'subtitle': '油はね対策'},
    ],
    'リビング': [
      {'name': '掃除機かけ', 'subtitle': 'カーペット・床'},
      {'name': '床掃除', 'subtitle': 'モップがけ'},
      {'name': '窓拭き', 'subtitle': '内側・外側'},
      {'name': 'ソファ掃除', 'subtitle': 'クッション整理'},
      {'name': 'テーブル拭き', 'subtitle': '毎日'},
      {'name': 'エアコン掃除', 'subtitle': 'フィルター清掃'},
    ],
    '寝室': [
      {'name': 'シーツ交換', 'subtitle': '週1回'},
      {'name': '布団干し', 'subtitle': '天日干し'},
      {'name': '枕カバー交換', 'subtitle': '週2回'},
      {'name': 'ベッド下掃除', 'subtitle': 'ホコリ除去'},
      {'name': 'クローゼット整理', 'subtitle': '衣替え'},
    ],
    'お風呂': [
      {'name': '浴槽掃除', 'subtitle': '湯垢・ヌメリ'},
      {'name': '排水口掃除', 'subtitle': '髪の毛除去'},
      {'name': 'カビ取り', 'subtitle': '壁・天井'},
      {'name': '鏡磨き', 'subtitle': '水垢除去'},
      {'name': '洗面台掃除', 'subtitle': '毎日'},
      {'name': 'お風呂マット洗濯', 'subtitle': '週2回'},
    ],
    'その他': [
      {'name': '玄関掃除', 'subtitle': '靴箱整理'},
      {'name': 'ベランダ掃除', 'subtitle': '落ち葉・ホコリ'},
      {'name': '照明掃除', 'subtitle': 'ホコリ除去'},
      {'name': '観葉植物の水やり', 'subtitle': '毎日'},
      {'name': 'ゴミ出し', 'subtitle': '地域のルール確認'},
    ],
  };

  @override
  void dispose() {
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

            // メインコンテンツ
            Expanded(
              child: Row(
                children: [
                  // 左側：カテゴリサイドバー
                  _buildCategorySidebar(),

                  // 右側：タスクリスト
                  Expanded(
                    child: _buildTaskList(),
                  ),
                ],
              ),
            ),

            // 繰り返し設定
            _buildRepeatSelector(),
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
                  'タスクを追加',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () => _showCustomTaskDialog(),
                child: Text(
                  '自由入力',
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
          final imagePath = category['image'] as String;

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
                  // フクロウ画像
                  Container(
                    width: isSelected ? 56 : 48,
                    height: isSelected ? 56 : 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
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
    List<Map<String, String>> tasks = [];

    if (categoryName == 'すべて') {
      // 全カテゴリのタスクを表示
      _taskTemplates.forEach((key, value) {
        tasks.addAll(value);
      });
    } else {
      tasks = _taskTemplates[categoryName] ?? [];
    }

    // 検索フィルター
    if (_searchQuery.isNotEmpty) {
      tasks = tasks
          .where((task) =>
              task['name']!.toLowerCase().contains(_searchQuery) ||
              task['subtitle']!.toLowerCase().contains(_searchQuery))
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
        return _buildTaskItem(
          name: task['name']!,
          subtitle: task['subtitle']!,
        );
      },
    );
  }

  /// タスクアイテム
  Widget _buildTaskItem({
    required String name,
    required String subtitle,
  }) {
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
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
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
        onTap: () => _addTask(name),
      ),
    );
  }

  /// 繰り返し設定セレクター
  Widget _buildRepeatSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            '繰り返し',
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRepeatChip('なし', RepeatType.none),
                  const SizedBox(width: AppSpacing.sm),
                  _buildRepeatChip('毎日', RepeatType.daily),
                  const SizedBox(width: AppSpacing.sm),
                  _buildRepeatChip('毎週', RepeatType.weekly),
                  const SizedBox(width: AppSpacing.sm),
                  _buildRepeatChip('毎月', RepeatType.monthly),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 繰り返しチップ
  Widget _buildRepeatChip(String label, RepeatType type) {
    final isSelected = _selectedRepeatType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRepeatType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gray800 : AppColors.gray50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: isSelected ? AppColors.white : AppColors.gray800,
          ),
        ),
      ),
    );
  }

  /// タスクを追加（カレンダーとも同期）
  void _addTask(String taskName) {
    final taskViewModel = context.read<TaskViewModel>();
    final calendarViewModel = context.read<CalendarViewModel>();

    // タスクを追加
    taskViewModel.addTask(
      title: taskName,
      repeatType: _selectedRepeatType,
    );

    // カレンダーも再読み込み（同期）
    calendarViewModel.loadTasks();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('「$taskName」を追加しました'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// カスタムタスクダイアログ
  void _showCustomTaskDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('自由入力'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'タスク名',
            hintText: '例：玄関掃除',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _addTask(titleController.text.trim());
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gray800,
              foregroundColor: AppColors.white,
            ),
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}
