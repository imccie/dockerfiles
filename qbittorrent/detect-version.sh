#!/usr/bin/env bash

set -o pipefail

dir_shell=$(cd $(dirname $0); pwd)
dir_myscripts=$(cd $(dirname $0); cd ../../myscripts; pwd)

cd $dir_shell

## 官方版本
ver_qb_official=$(curl -s https://api.github.com/repos/qbittorrent/qBittorrent/tags | jq -r .[0]."name" | sed "s/release-//")
ver_lib_official=$(curl -s https://api.github.com/repos/arvidn/libtorrent/tags | jq -r .[]."name" | grep -m 1 "v1." | sed "s/v//")

## 本地版本
ver_qb_local=$(cat ./ver_qbittorrent)
ver_lib_local=$(cat ./ver_libtorrent)

## 检测qbittorrent官方版本与本地版本是否一致，如不一致则重新构建
if [[ $ver_qb_official != $ver_qb_local ]]; then
    echo "官方已升级qBittorrent版本至：$ver_qb_official，开始重新构建镜像..."
    . $dir_myscripts/notify.sh
    . $dir_myscripts/my_config.sh
    notify "qBittorrent已经升级" "当前官方版本信息如下：\nqBittorrent: ${ver_qb_official}\nlibtorrent: ${ver_lib_official}\n\n当前本地版本信息如下：\nqBittorrent: ${ver_qb_local}\nlibtorrent: ${ver_lib_local}\n\n已自动开始重新构建并推送镜像..."
    ./buildx-run.sh "$ver_qb_official" "$ver_lib_official" && {
        echo "$ver_qb_official" > ./ver_qbittorrent
        echo "$ver_lib_official" > ./ver_libtorrent
    }
else
    echo "qBittorrent官方版本和本地一致，均为：$ver_qb_official"
fi

