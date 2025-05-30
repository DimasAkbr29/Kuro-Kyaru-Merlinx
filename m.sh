#!/bin/bash

commit_hash="0c2ad5a3a88faf23f436323566b61fff20597a80"

_log() {
    echo "[LOG] $*"
}

_err() {
    echo "[ERROR] $*" >&2
    exit 1
}

download_and_apply() {
    local url=$1
    local patch_id=$2
    local attempts=5
    local delay=60

    for attempt in $(seq 1 $attempts); do
        _log "Attempting to download patch $patch_id... [$attempt/$attempts]"
        curl -sL "$url" -o tmp.patch
        if grep -q "<!DOCTYPE html>" tmp.patch; then
            _log "Rate limit or error detected, retrying in ${delay}s... [$attempt/$attempts]"
            sleep $delay
            delay=$((delay + 5))
        else
            _log "Applying patch $patch_id"
            patch -p1 < tmp.patch || _err "Failed to apply patch $patch_id"
            rm -f tmp.patch
            return
        fi
    done

    _err "Failed to download patch $patch_id after $attempts attempts"
}

# Hapus patch lama jika ada
rm -f *.patch

_log "Applying patch from itswill00/android_kernel_xiaomi_mt6768z repo..."
download_and_apply "https://github.com/itswill00/android_kernel_xiaomi_mt6768z/commit/$commit_hash.patch" "$commit_hash"

_log "Patch applied successfully!"
