#!/usr/bin/env bash
#
# Copyright (C) 2023 BlackMesa123
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

set -Eeuo pipefail

# [
FILE_NAME="UN1CA_${ROM_VERSION}_$(date +%Y%m%d)_${TARGET_CODENAME}"
# ]

while read -r i; do
    PARTITION=$(basename "$i")
    [[ "$PARTITION" == "configs" ]] && continue
    [[ "$PARTITION" == "kernel" ]] && continue
    [[ "$PARTITION" == "system" ]] && continue
    [[ "$PARTITION" == "vendor" ]] && continue

    [ -f "$TMP_DIR/$PARTITION.img" ] && rm -f "$TMP_DIR/$PARTITION.img"
    [ -f "$WORK_DIR/$PARTITION.img" ] && rm -f "$WORK_DIR/$PARTITION.img"

    echo "Merging $PARTITION in system"
    rm -rf "$WORK_DIR/system/$PARTITION"
    rm -rf "$WORK_DIR/system/system/$PARTITION"
    sed -i "/$PARTITION /d" "$WORK_DIR/configs/file_context-system"
    sed -i "/$PARTITION /d" "$WORK_DIR/configs/fs_config-system"

    cp -a --preserve=all "$WORK_DIR/$PARTITION" "$WORK_DIR/system/system/$PARTITION"
    rm -rf "$WORK_DIR/$PARTITION"
    cat "$WORK_DIR/configs/file_context-$PARTITION" | sed "s/^\/$PARTITION/\/system\/$PARTITION/" >> "$WORK_DIR/configs/file_context-system"
    cat "$WORK_DIR/configs/fs_config-$PARTITION" | sed "s/^$PARTITION/system\/$PARTITION/" | sed "s/^ 0 0 755 capabilities\=0x0/system\/$PARTITION 0 0 755 capabilities\=0x0/" >> "$WORK_DIR/configs/fs_config-system"
    rm -rf "$WORK_DIR/configs/file_context-$PARTITION"
    rm -rf "$WORK_DIR/configs/fs_config-$PARTITION"

    ln -s "/system/$PARTITION" "$WORK_DIR/system/$PARTITION"
    if [[ "$PARTITION" == "odm" ]]; then
      echo "/$PARTITION u:object_r:vendor_file:s0" >> "$WORK_DIR/configs/file_context-system"
    else
      echo "/$PARTITION u:object_r:system_file:s0" >> "$WORK_DIR/configs/file_context-system"
    fi
    echo "$PARTITION 0 0 644 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-system"
done <<< "$(find "$WORK_DIR" -mindepth 1 -maxdepth 1 -type d)"

echo "Building system image"
bash "$SRC_DIR/scripts/build_fs_image.sh" "ext4" "$WORK_DIR/system" \
    "$WORK_DIR/configs/file_context-system" "$WORK_DIR/configs/fs_config-system" > /dev/null 2>&1

echo "Compressing system image"
gzip -c "$WORK_DIR/system.img" > "$OUT_DIR/${FILE_NAME}.img.gz"

rm -rf "$WORK_DIR/system.img"

exit 0
