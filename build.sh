#!/usr/bin/env bash
#

PROJECT_DIR="."
# 不要修改编译的目标地址
DIST_PATH="${PROJECT_DIR}/dist"
# 覆盖复制 不进行提示
OVERWRITE=false
# 初始化选项
SCRIPT_NAME=$(basename "$0")
# 编译排除的文件或目录
EXCLUDES=("dist" "${SCRIPT_NAME}")

while true; do
  age=$1
  [ -z "${age}" ] && break
  case "$age" in
  --overwrite)
    OVERWRITE=true
    shift
    ;;
  *)
    shift
    ;;
  esac
done

now() {
  # 当前日期时间
  date "+%Y-%m-%d %H:%M:%S"
}

info() {
  echo -e "$(now)[\033[34mINFO\033[0m] $*"
}

warning() {
  echo -e "$(now) [\033[33mWARN\033[0m] $*"
}

error() {
  echo -e "$(now) [\033[31mERROR\033[0m] $*"
}

tip() {
  echo -e "$(now) [\033[35mTip\033[0m] $*"
}

copyFile() {
  # 拷贝文件到目标目录
  if ! [ -d "${DIST_PATH}" ]; then
    mkdir -p "${DIST_PATH}"
  fi
  [ "${DIST_PATH}" == "/" ] && error "目标目录不能是根目录" && exit 12
  if [ -n "$(ls -A ${DIST_PATH})" ]; then
    if ${OVERWRITE}; then
      rm -rf "${DIST_PATH:?目标路径错误}/*" &>/dev/null
    else
      tip "如果你知道你的操作结果, 可以指定--overwrite选项忽略该提醒"
      local overwrite
      while true; do
        read -r -p"目标目录(${DIST_PATH})已经存在文件, 是否删除覆盖(Y/N):" overwrite
        overwrite=$(tr "[:upper:]" "[:lower:]" <<<"${overwrite}")
        if [ "${overwrite}" == "yes" ] || [ "${overwrite}" == "y" ]; then
          rm -rf "${DIST_PATH:?目标路径错误}/*" &>/dev/null
          break
        elif [ "${overwrite}" == "no" ] || [ "${overwrite}" == "n" ]; then
          tip "取消构建"
          exit 1
        else
          continue
        fi
      done
    fi
  fi
  local files
  local filename
  local excludes
  excludes="${EXCLUDES[*]}"
  files=$(ls -A ${PROJECT_DIR})
  for file in ${files}; do
    filename=$(basename "${file}")
    [[ "${excludes}" =~ ${filename} ]] && continue
    info "复制文件${file} --> ${DIST_PATH}/${filename}"
    cp -a "${file}" "${DIST_PATH}" &>/dev/null
  done
  info "文件复制完成"
}

copyFile
