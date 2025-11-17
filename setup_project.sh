#!/bin/bash

echo "🦉 CleanUp アプリのセットアップを開始します..."
echo ""

# カレントディレクトリがowl_cleanかチェック
CURRENT_DIR=$(basename "$PWD")
if [ "$CURRENT_DIR" != "owl_clean" ]; then
    echo "⚠️  警告: 現在のディレクトリが 'owl_clean' ではありません"
    echo "現在のディレクトリ: $PWD"
    read -p "このまま続行しますか？ (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "📁 フォルダ構成を作成中..."

# libディレクトリに移動
cd lib 2>/dev/null || { echo "❌ libフォルダが見つかりません。flutter createを先に実行してください。"; exit 1; }

# フォルダ構成を作成
mkdir -p models
mkdir -p viewmodels
mkdir -p views/home
mkdir -p views/calendar/widgets
mkdir -p views/menu/widgets
mkdir -p views/other/widgets
mkdir -p widgets
mkdir -p services
mkdir -p utils
mkdir -p repositories

echo "✅ フォルダ構成を作成しました"
echo ""

echo "📄 ファイルを作成中..."

# Utilsファイル
touch utils/constants.dart
touch utils/colors.dart
touch utils/date_utils.dart

# Modelsファイル
touch models/task.dart
touch models/task_category.dart
touch models/garbage_schedule.dart
touch models/notification_setting.dart

# ViewModelsファイル
touch viewmodels/task_viewmodel.dart
touch viewmodels/calendar_viewmodel.dart
touch viewmodels/garbage_viewmodel.dart
touch viewmodels/settings_viewmodel.dart

# Servicesファイル
touch services/database_service.dart
touch services/notification_service.dart
touch services/storage_service.dart

# Repositoriesファイル
touch repositories/task_repository.dart
touch repositories/garbage_repository.dart

# Widgetsファイル
touch widgets/owl_character.dart
touch widgets/task_card.dart
touch widgets/custom_bottom_nav.dart
touch widgets/completion_animation.dart
touch widgets/custom_dialog.dart

# Viewsファイル - Home
touch views/home/home_page.dart

# Viewsファイル - Calendar
touch views/calendar/calendar_page.dart
touch views/calendar/widgets/calendar_tab_view.dart
touch views/calendar/widgets/task_list_item.dart

# Viewsファイル - Menu
touch views/menu/menu_page.dart
touch views/menu/widgets/category_manager.dart
touch views/menu/widgets/notification_settings.dart

# Viewsファイル - Other
touch views/other/other_page.dart
touch views/other/widgets/settings_section.dart
touch views/other/widgets/about_section.dart

# app.dart
touch app.dart

cd ..

# assetsフォルダを作成
echo ""
echo "🎨 assetsフォルダを作成中..."
mkdir -p assets/images
mkdir -p assets/icons

echo "✅ assetsフォルダを作成しました"
echo ""

# 作成されたファイル数を表示
FILE_COUNT=$(find lib -type f -name "*.dart" | wc -l | tr -d ' ')
echo "✅ すべてのファイルが作成されました！"
echo ""
echo "📊 作成されたファイル数: ${FILE_COUNT} ファイル"
echo ""

# フォルダ構成を表示
echo "📂 プロジェクト構成:"
echo ""
tree lib -L 3 2>/dev/null || find lib -type d | sed 's|[^/]*/| |g'

echo ""
echo "🎉 セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "1. pubspec.yaml にパッケージを追加"
echo "2. flutter pub get を実行"
echo "3. assets/images/ にフクロウ画像を配置"
echo "4. コードの実装を開始"
echo ""
echo "詳細は setup_guide.md を確認してください 📝"