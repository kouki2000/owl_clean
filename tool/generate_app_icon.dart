import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  print('🐱 アプリアイコンを生成中...');

  // 1024x1024のアイコンを生成
  final image = generateSleepingCatIcon(1024);

  // assets/iconディレクトリを作成
  final iconDir = Directory('assets/icon');
  if (!iconDir.existsSync()) {
    iconDir.createSync(recursive: true);
  }

  // PNGとして保存
  final pngBytes = img.encodePng(image);
  final file = File('assets/icon/app_icon.png');
  file.writeAsBytesSync(pngBytes);

  print('✅ アイコンを生成しました: ${file.path}');
  print('次のコマンドを実行してください:');
  print('flutter pub run flutter_launcher_icons');
}

img.Image generateSleepingCatIcon(int size) {
  // 白背景の画像を作成
  final image = img.Image(width: size, height: size);
  img.fill(image, color: img.ColorRgb8(255, 255, 255));

  final centerX = size ~/ 2;
  final centerY = size ~/ 2;
  final scale = size / 100.0;

  final black = img.ColorRgb8(0, 0, 0);

  // 体（横向き・楕円形）
  drawFilledEllipse(
    image,
    centerX,
    centerY,
    (25 * scale).round(),
    (15 * scale).round(),
    black,
  );

  // 頭（体の左側）
  drawFilledCircle(
    image,
    (centerX - 15 * scale).round(),
    (centerY - 5 * scale).round(),
    (10 * scale).round(),
    black,
  );

  // 左耳
  drawFilledTriangle(
    image,
    (centerX - 22 * scale).round(),
    (centerY - 12 * scale).round(),
    (centerX - 25 * scale).round(),
    (centerY - 18 * scale).round(),
    (centerX - 18 * scale).round(),
    (centerY - 14 * scale).round(),
    black,
  );

  // 右耳
  drawFilledTriangle(
    image,
    (centerX - 12 * scale).round(),
    (centerY - 14 * scale).round(),
    (centerX - 10 * scale).round(),
    (centerY - 20 * scale).round(),
    (centerX - 15 * scale).round(),
    (centerY - 15 * scale).round(),
    black,
  );

  // 尻尾（曲線）
  drawThickLine(
    image,
    (centerX + 25 * scale).round(),
    (centerY + 5 * scale).round(),
    (centerX + 20 * scale).round(),
    (centerY - 8 * scale).round(),
    (3 * scale).round(),
    black,
  );

  // 足
  drawFilledRect(
    image,
    (centerX - 5 * scale).round(),
    (centerY + 10 * scale).round(),
    (5 * scale).round(),
    (5 * scale).round(),
    black,
  );

  // Zzzマーク
  final gray = img.ColorRgb8(100, 100, 100);
  drawText(
    image,
    'Z',
    (centerX + 20 * scale).round(),
    (centerY - 25 * scale).round(),
    (15 * scale).round(),
    gray,
  );
  drawText(
    image,
    'Z',
    (centerX + 28 * scale).round(),
    (centerY - 20 * scale).round(),
    (12 * scale).round(),
    gray,
  );
  drawText(
    image,
    'Z',
    (centerX + 35 * scale).round(),
    (centerY - 15 * scale).round(),
    (10 * scale).round(),
    gray,
  );

  return image;
}

void drawFilledCircle(
    img.Image image, int cx, int cy, int radius, img.Color color) {
  for (int y = -radius; y <= radius; y++) {
    for (int x = -radius; x <= radius; x++) {
      if (x * x + y * y <= radius * radius) {
        final px = cx + x;
        final py = cy + y;
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          image.setPixel(px, py, color);
        }
      }
    }
  }
}

void drawFilledEllipse(
    img.Image image, int cx, int cy, int rx, int ry, img.Color color) {
  for (int y = -ry; y <= ry; y++) {
    for (int x = -rx; x <= rx; x++) {
      if ((x * x) / (rx * rx) + (y * y) / (ry * ry) <= 1) {
        final px = cx + x;
        final py = cy + y;
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          image.setPixel(px, py, color);
        }
      }
    }
  }
}

void drawFilledTriangle(img.Image image, int x1, int y1, int x2, int y2, int x3,
    int y3, img.Color color) {
  final minX = [x1, x2, x3].reduce(math.min);
  final maxX = [x1, x2, x3].reduce(math.max);
  final minY = [y1, y2, y3].reduce(math.min);
  final maxY = [y1, y2, y3].reduce(math.max);

  for (int y = minY; y <= maxY; y++) {
    for (int x = minX; x <= maxX; x++) {
      if (isPointInTriangle(x, y, x1, y1, x2, y2, x3, y3)) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          image.setPixel(x, y, color);
        }
      }
    }
  }
}

bool isPointInTriangle(
    int px, int py, int x1, int y1, int x2, int y2, int x3, int y3) {
  final d1 = sign(px, py, x1, y1, x2, y2);
  final d2 = sign(px, py, x2, y2, x3, y3);
  final d3 = sign(px, py, x3, y3, x1, y1);

  final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
  final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);

  return !(hasNeg && hasPos);
}

double sign(int px, int py, int x1, int y1, int x2, int y2) {
  return ((px - x2) * (y1 - y2) - (x1 - x2) * (py - y2)).toDouble();
}

void drawFilledRect(
    img.Image image, int x, int y, int width, int height, img.Color color) {
  for (int dy = 0; dy < height; dy++) {
    for (int dx = 0; dx < width; dx++) {
      final px = x + dx;
      final py = y + dy;
      if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
        image.setPixel(px, py, color);
      }
    }
  }
}

void drawThickLine(img.Image image, int x1, int y1, int x2, int y2,
    int thickness, img.Color color) {
  final dx = (x2 - x1).abs();
  final dy = (y2 - y1).abs();
  final sx = x1 < x2 ? 1 : -1;
  final sy = y1 < y2 ? 1 : -1;
  var err = dx - dy;

  var x = x1;
  var y = y1;

  while (true) {
    drawFilledCircle(image, x, y, thickness ~/ 2, color);

    if (x == x2 && y == y2) break;
    final e2 = 2 * err;
    if (e2 > -dy) {
      err -= dy;
      x += sx;
    }
    if (e2 < dx) {
      err += dx;
      y += sy;
    }
  }
}

void drawText(
    img.Image image, String text, int x, int y, int size, img.Color color) {
  // シンプルなZの描画
  if (text == 'Z') {
    // 上の横線
    for (int i = 0; i < size; i++) {
      drawFilledCircle(image, x + i, y, 2, color);
    }
    // 斜め線
    for (int i = 0; i < size; i++) {
      drawFilledCircle(image, x + size - i, y + i, 2, color);
    }
    // 下の横線
    for (int i = 0; i < size; i++) {
      drawFilledCircle(image, x + i, y + size, 2, color);
    }
  }
}
