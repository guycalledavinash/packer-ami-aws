#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
WEB_CONTENT_REPO="${WEB_CONTENT_REPO:-https://github.com/guycalledavinash/webhook-testing.git}"
WEB_CONTENT_REF="${WEB_CONTENT_REF:-main}"
WEB_ROOT="${WEB_ROOT:-/var/www/html}"
TMP_CONTENT_DIR="$(mktemp -d /tmp/web-content.XXXXXX)"
DOCKER_KEY_TMP=""

cleanup() {
  rm -rf -- "${TMP_CONTENT_DIR}"
  if [[ -n "${DOCKER_KEY_TMP}" ]]; then
    rm -f -- "${DOCKER_KEY_TMP}"
  fi
}
trap cleanup EXIT

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  gnupg \
  nginx

git clone --depth 1 --branch "${WEB_CONTENT_REF}" --single-branch "${WEB_CONTENT_REPO}" "${TMP_CONTENT_DIR}"

install -d -m 0755 "${WEB_ROOT}"
rm -f "${WEB_ROOT}/index.nginx-debian.html"
install -m 0644 "${TMP_CONTENT_DIR}/index.html" "${WEB_ROOT}/index.nginx-debian.html"
install -m 0644 "${TMP_CONTENT_DIR}/style.css" "${WEB_ROOT}/style.css"
install -m 0644 "${TMP_CONTENT_DIR}/scorekeeper.js" "${WEB_ROOT}/scorekeeper.js"

install -m 0755 -d /etc/apt/keyrings
if [[ ! -s /etc/apt/keyrings/docker.gpg ]]; then
  DOCKER_KEY_TMP="$(mktemp /etc/apt/keyrings/docker.gpg.XXXXXX)"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor > "${DOCKER_KEY_TMP}"
  install -m 0644 "${DOCKER_KEY_TMP}" /etc/apt/keyrings/docker.gpg
  rm -f -- "${DOCKER_KEY_TMP}"
  DOCKER_KEY_TMP=""
fi
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y --no-install-recommends \
  containerd.io \
  docker-buildx-plugin \
  docker-ce \
  docker-ce-cli \
  docker-compose-plugin

usermod -aG docker ubuntu
systemctl enable nginx docker
systemctl restart nginx docker

apt-get clean
rm -rf /var/lib/apt/lists/*
