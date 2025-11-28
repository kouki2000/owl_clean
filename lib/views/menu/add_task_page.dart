import 'package:flutter/material.dart';
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

class _AddTaskPageState extends State<AddTaskPage> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // カテゴリ（アイコンに統一）
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'すべて',
      'icon': Icons.grid_view,
    },
    {
      'name': 'トイレ',
      'icon': Icons.wc,
    },
    {
      'name': 'キッチン',
      'icon': Icons.kitchen,
    },
    {
      'name': 'リビング',
      'icon': Icons.living,
    },
    {
      'name': '寝室',
      'icon': Icons.hotel,
    },
    {
      'name': 'お風呂',
      'icon': Icons.bathtub,
    },
    {
      'name': 'ゴミ出し',
      'icon': Icons.delete,
    },
    {
      'name': 'その他',
      'icon': Icons.more_horiz,
    },
  ];

// タスクテンプレート（categoryId nullable対応）
  final Map<String, List<Map<String, String?>>> _taskTemplates = {
    'トイレ': [
      {'name': 'トイレ掃除', 'subtitle': '便器・床・壁', 'categoryId': 'toilet'},
      {'name': '便座拭き', 'subtitle': '毎日のケア', 'categoryId': 'toilet'},
      {'name': 'タンク掃除', 'subtitle': '月1回', 'categoryId': 'toilet'},
      {'name': 'トイレマット洗濯', 'subtitle': '週1回', 'categoryId': 'toilet'},
    ],
    'キッチン': [
      {'name': 'シンク掃除', 'subtitle': '水垢・油汚れ', 'categoryId': 'kitchen'},
      {'name': 'コンロ掃除', 'subtitle': '油汚れ除去', 'categoryId': 'kitchen'},
      {'name': '冷蔵庫整理', 'subtitle': '賞味期限チェック', 'categoryId': 'kitchen'},
      {'name': '換気扇掃除', 'subtitle': '月1回', 'categoryId': 'kitchen'},
      {'name': '食器洗い', 'subtitle': '毎日', 'categoryId': 'kitchen'},
      {'name': '床拭き', 'subtitle': '油はね対策', 'categoryId': 'kitchen'},
    ],
    'リビング': [
      {'name': '掃除機かけ', 'subtitle': 'カーペット・床', 'categoryId': 'living'},
      {'name': '床掃除', 'subtitle': 'モップがけ', 'categoryId': 'living'},
      {'name': '窓拭き', 'subtitle': '内側・外側', 'categoryId': 'living'},
      {'name': 'ソファ掃除', 'subtitle': 'クッション整理', 'categoryId': 'living'},
      {'name': 'テーブル拭き', 'subtitle': '毎日', 'categoryId': 'living'},
      {'name': 'エアコン掃除', 'subtitle': 'フィルター清掃', 'categoryId': 'living'},
    ],
    '寝室': [
      {'name': 'シーツ交換', 'subtitle': '週1回', 'categoryId': 'bedroom'},
      {'name': '布団干し', 'subtitle': '天日干し', 'categoryId': 'bedroom'},
      {'name': '枕カバー交換', 'subtitle': '週2回', 'categoryId': 'bedroom'},
      {'name': 'ベッド下掃除', 'subtitle': 'ホコリ除去', 'categoryId': 'bedroom'},
      {'name': 'クローゼット整理', 'subtitle': '衣替え', 'categoryId': 'bedroom'},
    ],
    'お風呂': [
      {'name': '浴槽掃除', 'subtitle': '湯垢・ヌメリ', 'categoryId': 'bath'},
      {'name': '排水口掃除', 'subtitle': '髪の毛除去', 'categoryId': 'bath'},
      {'name': 'カビ取り', 'subtitle': '壁・天井', 'categoryId': 'bath'},
      {'name': '鏡磨き', 'subtitle': '水垢除去', 'categoryId': 'bath'},
      {'name': '洗面台掃除', 'subtitle': '毎日', 'categoryId': 'bath'},
      {'name': 'お風呂マット洗濯', 'subtitle': '週2回', 'categoryId': 'bath'},
    ],
    'ゴミ出し': [
      {'name': '燃えるゴミ', 'subtitle': '週2回', 'categoryId': 'garbage'},
      {'name': '燃えないゴミ', 'subtitle': '月2回', 'categoryId': 'garbage'},
      {'name': '資源ゴミ', 'subtitle': '週1回', 'categoryId': 'garbage'},
      {'name': 'プラスチック', 'subtitle': '週1回', 'categoryId': 'garbage'},
      {'name': '紙類', 'subtitle': '月1回', 'categoryId': 'garbage'},
      {'name': 'ビン・カン', 'subtitle': '週1回', 'categoryId': 'garbage'},
      {'name': 'ペットボトル', 'subtitle': '週1回', 'categoryId': 'garbage'},
      {'name': '粗大ゴミ', 'subtitle': '要予約', 'categoryId': 'garbage'},
    ],
    'その他': [
      {'name': '玄関掃除', 'subtitle': '靴箱整理', 'categoryId': null},
      {'name': 'ベランダ掃除', 'subtitle': '落ち葉・ホコリ', 'categoryId': null},
      {'name': '照明掃除', 'subtitle': 'ホコリ除去', 'categoryId': null},
      {'name': '観葉植物の水やり', 'subtitle': '毎日', 'categoryId': null},
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
                onPressed: () => _navigateToTaskDetail(),
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
                  // アイコン
                  Container(
                    width: isSelected ? 56 : 48,
                    height: isSelected ? 56 : 48,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.gray800 : AppColors.gray200,
                      borderRadius: BorderRadius.circular(12),
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
                    child: Icon(
                      icon,
                      color: isSelected ? AppColors.white : AppColors.gray600,
                      size: isSelected ? 28 : 24,
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
    List<Map<String, String?>> tasks = []; // ⚠️ String?に変更

    // 検索クエリがある場合、またはカテゴリが「すべて」の場合
    if (_searchQuery.isNotEmpty || categoryName == 'すべて') {
      // 全カテゴリのタスクを表示
      _taskTemplates.forEach((key, value) {
        tasks.addAll(value);
      });
    } else {
      // 選択されたカテゴリのタスクのみ
      tasks = _taskTemplates[categoryName] ?? [];
    }

    // 検索フィルター（検索クエリがある場合のみ）
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
              _searchQuery.isNotEmpty
                  ? '「$_searchQuery」に該当するタスクが見つかりません'
                  : '該当するタスクが見つかりません',
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
          categoryId: task['categoryId'],
        );
      },
    );
  }

  /// タスクアイテム
  Widget _buildTaskItem({
    required String name,
    required String subtitle,
    String? categoryId, // 追加
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
        onTap: () => _navigateToTaskDetail(
          taskName: name,
          categoryId: categoryId, // 追加
        ),
      ),
    );
  }

  /// タスク詳細画面に遷移
  void _navigateToTaskDetail({String? taskName, String? categoryId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(
          initialTaskName: taskName,
          categoryId: categoryId,
        ),
      ),
    );
  }

  /// カテゴリー名からcategoryIdに変換
  String? _getCategoryId(String categoryName) {
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
        return null; // すべて、その他
    }
  }
}
