if [[ "$SOURCE_EXTRA_FIRMWARES" == "SM-A346"* ]]; then
    LOG "\033[0;33m! Nothing to do\033[0m"
    return 0
fi

ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libsupernight_auto_raw.arcsoft.so"
