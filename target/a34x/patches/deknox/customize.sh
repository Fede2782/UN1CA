SKIPUNZIP=1

# [
KERNEL="https://github.com/Fede2782/android_kernel_samsung_a34x/releases/download/v1.0.2-cxk1/Vanilla-20241210-a34x-CXK1.tar.md5"

REPLACE_KERNEL_BINARIES()
{
    [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    echo "Downloading $(basename "$REAL_ZIP")"
    curl -L -s -o "$TMP_DIR/kernel.tar" "$KERNEL"

    echo "Extracting kernel binaries"
    [ -f "$WORK_DIR/kernel/boot.img" ] && rm -rf "$WORK_DIR/kernel/boot.img"
    tar xvf "$TMP_DIR/kernel.tar" -C "$WORK_DIR/kernel/"

    PDR="$(pwd)"

    cd "$WORK_DIR/kernel/"
    unlz4 boot.img.lz4
    rm boot.img.lz4
    cd "$PDR"

    rm -rf "$TMP_DIR"
}
# ]

REPLACE_KERNEL_BINARIES
