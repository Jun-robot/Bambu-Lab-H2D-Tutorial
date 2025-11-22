#!/usr/bin/env bash
set -euo pipefail

# 使い方:
#   ./optimize_jpegs.sh /path/to/target_dir
#
# 引数がなければカレントディレクトリを対象にする
TARGET_DIR="${1:-.}"

# 最大幅/高さ（これ以上大きい画像はリサイズ）
MAX_SIZE="1920x1920"

echo "Target directory: ${TARGET_DIR}"
echo "Max size: ${MAX_SIZE}"
echo "Quality: 80 (jpegoptim --max=80, strip metadata)"
echo

# JPG / jpg をすべて探して処理
find "${TARGET_DIR}" -type f \( -iname "*.JPG" -o -iname "*.jpg" \) -print0 |
  while IFS= read -r -d '' file; do
    echo "Processing: $file"

    # 1. 大きすぎる画像はリサイズ（アスペクト比を保ちつつ、MAX_SIZE以内に収める）
    #    『>』 を付けることで、既に小さい画像はリサイズしない
    mogrify -resize "${MAX_SIZE}>" "$file"

    # 2. Web向けに最適化
    #    - EXIF等のメタデータ削除
    #    - 品質80を上限として再圧縮
    jpegoptim --strip-all --max=80 "$file" || true

    echo "Done: $file"
    echo
  done

echo "All done."
