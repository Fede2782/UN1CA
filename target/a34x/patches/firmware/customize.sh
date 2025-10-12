A346B_FIRMWARE_URL="https://github.com/UN1CA/proprietary_vendor_samsung_a34x/releases/download/EYI7-firmware/A346BXXUBEYI7_mtk_fw.tar.md5"
A346E_FIRMWARE_URL="https://github.com/UN1CA/proprietary_vendor_samsung_a34x/releases/download/EYI7-firmware/A346EXXUAEYI7_mtk_fw.tar.md5"
A346M_FIRMWARE_URL="https://github.com/UN1CA/proprietary_vendor_samsung_a34x/releases/download/EYI7-firmware/A346MUBUBEYI7_mtk_fw.tar.md5"
A3460_FIRMWARE_URL="https://github.com/UN1CA/proprietary_vendor_samsung_a34x/releases/download/EYI7-firmware/A3460ZHUAEYI7_mtk_fw.tar.md5"
A346N_FIRMWARE_URL="https://github.com/UN1CA/proprietary_vendor_samsung_a34x/releases/download/EYI7-firmware/A346NKSSAEYI8_mtk_fw.tar.md5"

if [ -d "$WORK_DIR/firmware" ]; then
   EVAL "rm -rf \"$WORK_DIR/firmware\""
fi

for f in A346B A346E A346M A3460 A346N; do
    LOG "- Downloading firmware package for $f"

    var="${f}_FIRMWARE_URL"
    FIRMWARE_URL="${!var}"

    if [ -d "$TMP_DIR" ]; then
        EVAL "rm -rf \"$TMP_DIR\""
    fi
    EVAL "mkdir -p \"$TMP_DIR\""

    DOWNLOAD_FILE "$FIRMWARE_URL" "$TMP_DIR/firmware.tar"

    EXPECTED_HASH="$(tail -z -n 1 "$TMP_DIR/firmware.tar" | cut -d' ' -f 1)"
    HASH="$(cat "$TMP_DIR/firmware.tar" | xxd -p -c 0 | sed "s/$(tail -z -n 1 "$TMP_DIR/firmware.tar" | xxd -p -c 0)//" | xxd -p -r -c 0 | md5sum | cut -d' ' -f 1)"

    [[ "$HASH" == "$EXPECTED_HASH" ]] || ABORT "- Downloaded firmware .tar.md5 file hash missing or mismatches. Aborting"

    EVAL "tar xf \"$TMP_DIR/firmware.tar\" -C \"$TMP_DIR\""

    PARTITIONS="
    audio_dsp-verified.img
    cam_vpu1-verified.img
    cam_vpu2-verified.img
    cam_vpu3-verified.img
    dtbo.img
    scp-verified.img
    "

    EVAL "mkdir -p \"$WORK_DIR/firmware/$f\""
    for i in $PARTITIONS; do
        [[ ! -f "$TMP_DIR/$i.lz4" ]] && ABORT "- Missing $i in $f firmware package"
        EVAL "unlz4 -f \"$TMP_DIR/$i.lz4\" \"$WORK_DIR/firmware/$f/$i\""
    done

    EVAL "rm -rf \"$TMP_DIR\""

    unset FIRMWARE_URL var HASH EXPECTED_HASH
done

EVAL "rm \"$WORK_DIR/kernel/dtbo.img\""
