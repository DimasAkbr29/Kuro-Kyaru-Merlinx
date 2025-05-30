#!/bin/bash

# === Konfigurasi Telegram ===
CHAT_ID="-1002618275364"
BOT_TOKEN="7840824177:AAHY9VaCBO6b2xFN9xBz2MDjg2cDTTkA8Tw"
TG_API="https://api.telegram.org/bot${BOT_TOKEN}/sendDocument"
TG_MSG_API="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"
CAPTION_TIME=$(date '+%d %B %Y, %I:%M %p')

function send_to_telegram() {
    local FILE=$1
    local CAPTION=$2
    curl -s -F "chat_id=${CHAT_ID}" \
         -F "document=@${FILE}" \
         -F "caption=${CAPTION}" \
         "${TG_API}"
}

function send_message() {
    local MESSAGE=$1
    curl -s -X POST "${TG_MSG_API}" -d chat_id="${CHAT_ID}" -d text="${MESSAGE}"
}

function compile() {
    source ~/.bashrc && source ~/.profile
    export LC_ALL=C
    export ARCH=arm64
    export KBUILD_BUILD_HOST="Perf++"
    export KBUILD_BUILD_USER="Dimz-Machine"
    export USE_CCACHE=1

    make clean
    rm -rf AnyKernel
    rm -rf out
    mkdir -p out

    make O=out ARCH=arm64 merlin_defconfig
    export PATH=$HOME/aosp_clang/bin:$PATH

    START=$(date +%s)

    PATH="${PWD}/aosp_clang/bin:${PATH}" \
    make -j$(nproc) O=out \
        ARCH=$ARCH \
        CC="clang" \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-android-" \
        CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-androideabi-" \
        LLVM=1 LLVM_IAS=1 \
        LD=ld.lld AR=llvm-ar NM=llvm-nm \
        OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CONFIG_NO_ERROR_ON_MISMATCH=y \
        2>&1 | tee error.log

    END=$(date +%s)
    BUILD_TIME=$((END - START))
    BUILD_MIN=$(echo "scale=2; $BUILD_TIME / 60" | bc)

    if [ -f "out/arch/arm64/boot/Image.gz-dtb" ]; then
        echo "[OK] Build berhasil"
        return 0
    else
        echo "[X] Build gagal"
        return 1
    fi
}

function zupload() {
    git clone --depth=1 https://github.com/DimasAkbr29/AnyKernel -b main AnyKernel
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
    cd AnyKernel
    zip -r9 phoneix-merlinx.zip *

    send_to_telegram "phoneix-merlinx.zip" \
        "✅ Build Success — $CAPTION_TIME\n🕒 Duration: ${BUILD_MIN} minutes"
    cd ..
}

# === Jalankan proses ===
send_message "🛠️ Build started — $CAPTION_TIME"
compile
RESULT=$?

if [ $RESULT -eq 0 ]; then
    zupload
else
    send_to_telegram "error.log" "❌ Build Failed — $CAPTION_TIME"
fi
