#!/bin/bash

# Daftar commit patch URLs (urut sesuai keinginanmu)
PATCH_URLS=(
  "https://github.com/MoeKernel/android_kernel_xiaomi_ginkgo/commit/bc180f014c19c6289dbadd2349ea715402d8c2c5.patch"
  "https://github.com/MoeKernel/android_kernel_xiaomi_ginkgo/commit/3bd9c3b88cc63f00fe30038ffd8a5ffd49408a32.patch"
  "https://github.com/MoeKernel/android_kernel_xiaomi_ginkgo/commit/deb6bcbfa25f241eb674448296f0bce846cfb635.patch"
  "https://github.com/MoeKernel/android_kernel_xiaomi_ginkgo/commit/f49d671070ee629a2da37c24dd8852d1d9a75cb6.patch"
)

for url in "${PATCH_URLS[@]}"; do
  echo "======================================="
  echo "Downloading patch from $url"
  PATCH_FILE="patch_tmp.patch"
  curl -L "$url" -o "$PATCH_FILE"
  if [ $? -ne 0 ]; then
    echo "[ERROR] Gagal mengunduh patch dari $url"
    exit 1
  fi

  echo "Trying to apply patch (dry-run)..."
  patch -p1 --dry-run < "$PATCH_FILE"
  if [ $? -ne 0 ]; then
    echo "[ERROR] Patch gagal diterapkan pada dry-run, abort."
    rm -f "$PATCH_FILE"
    exit 1
  fi

  echo "Applying patch..."
  patch -p1 < "$PATCH_FILE"
  if [ $? -ne 0 ]; then
    echo "[ERROR] Gagal menerapkan patch."
    rm -f "$PATCH_FILE"
    exit 1
  fi

  echo "Patch berhasil diterapkan."
  rm -f "$PATCH_FILE"
done

echo "Semua patch berhasil diterapkan."
