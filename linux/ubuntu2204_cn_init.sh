#!/bin/bash

function confirm() {
  while true; do
    read -r -p "$* [y/n](default: n): " input
    case $input in
    y | Y | yes | YES | Yes)
      return 1
      ;;
    *)
      return 0
      ;;
    esac
  done
}

function Ubuntu2204CnInit() {
  tsinghuaSource="# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse"

  dockerSource = ""

  # add user pi
  useradd -m -s /bin/bash pi
  echo "Add user pi done"
  echo "Maybe consider to add sudo permission for pi"
  echo ""

  # change to tsinghua sources
  mv /etc/apt/sources.list /etc/apt/sources.backup

  apt-get update -y
  apt-get install vim net-tools ca-certificates curl gnupg -y
  echo "Change tsinghua source done"
  apt-get autoremove --purge snapd # remove ubuntu snapd
  echo "Remove ubuntu snapd done"
  echo ""

  # install docker
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  echo "Install docker now ..."
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  # TODO: change docker source
  systemctl stop docker
  rm -rf /var/lib/docker
  systemctl start docker
  echo "Docker installation done"
  echo ""
}
