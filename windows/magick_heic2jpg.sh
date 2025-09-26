#!/bin/bash
set -euo pipefail

usage() {
    echo "Usage: $0 -i|--input <file or directory> -o|--output <directory> -t|--type <jpg|png|...>"
    echo ""
    echo "  -i, --input  input file or directory"
    echo "  -o, --output output directory, default output directory named imagemagick at parent directory of input"
    echo "  -t, --type   output file type, e.g. jpg, png and so on, default is jpg"
    exit 1
}

input=""
output_dir="imagemagick"
output_image_type="jpg"
cmds=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input)
            input="$2"
            shift 2
            ;;
        -o|--output)
            output_dir="$2"
            shift 2
            ;;
        -t|--type)
            output_image_type="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -e "$input" ]]; then
    echo "the path is not exist"
    usage
    exit 1
fi

get_cmds() {
    local path="$1"

    if [[ -f "$path" ]]; then
        cmds+=('magick "$path" -format "$output_image_type" "${path%.*}.$output_image_type"')
        echo "file"
    elif [[ -d "$path" ]]; then
        echo "directory"
    else
        echo "unknown error: $path"
        exit 1
    fi
}

get_cmds "$input"

# 判断输入是文件还是文件夹
if [[ -f "$INPUT_PATH" ]]; then
    # 是文件
    EXT="${INPUT_PATH##*.}"
    if [[ "${EXT,,}" != "heic" ]]; then
        echo "只支持HEIC文件"
        exit 1
    fi
    OUT_FILE="${INPUT_PATH%.*}.jpg"
    magick "$INPUT_PATH" "$OUT_FILE"
    echo "转换完成: $OUT_FILE"
elif [[ -d "$INPUT_PATH" ]]; then
    # 是文件夹
    JPG_DIR="$(dirname "$INPUT_PATH")/jpg"
    mkdir -p "$JPG_DIR"
    shopt -s nullglob
    HEIC_FILES=("$INPUT_PATH"/*.heic "$INPUT_PATH"/*.HEIC)
    if [[ ${#HEIC_FILES[@]} -eq 0 ]]; then
        echo "文件夹下没有HEIC文件"
        exit 1
    fi
    for FILE in "${HEIC_FILES[@]}"; do
        BASENAME="$(basename "$FILE" .heic)"
        BASENAME="${BASENAME%.HEIC}"
        OUT_FILE="$JPG_DIR/$BASENAME.jpg"
        magick "$FILE" "$OUT_FILE"
        echo "转换: $FILE -> $OUT_FILE"
    done
    echo "全部转换完成，JPG文件在: $JPG_DIR"
else
    echo "输入路径无效"
    exit 1
fi

# 假设有10个命令，分别用数组保存
cmds=(
  "sleep 3"
  "sleep 2"
  "sleep 4"
  "sleep 1"
  "sleep 5"
  "sleep 2"
  "sleep 3"
  "sleep 1"
  "sleep 2"
  "sleep 4"
)

max_jobs=2  # 最大并发数

for cmd in "${cmds[@]}"; do
  eval "$cmd" &  # 后台运行命令
  while (( $(jobs -r | wc -l) >= max_jobs )); do
    sleep 0.5     # 检查当前后台任务数，达到上限则等待
  done
done

wait  # 等待所有后台任务完成
echo "所有命令已完成"
