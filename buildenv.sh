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

# shellcheck disable=SC1091,SC2012,SC2034

set -o allexport

# [
SRC_DIR="$(git rev-parse --show-toplevel)"
OUT_DIR="$SRC_DIR/out"
TMP_DIR="$OUT_DIR/tmp"
ODIN_DIR="$OUT_DIR/odin"
FW_DIR="$OUT_DIR/fw"
APKTOOL_DIR="$OUT_DIR/apktool"
WORK_DIR="$OUT_DIR/work_dir"
TOOLS_DIR="$OUT_DIR/tools/bin"

PATH="$TOOLS_DIR:$PATH"

run_cmd()
{
    local CMD=$1
    local CMDS
    CMDS="$(ls --ignore "internal" "$SRC_DIR/scripts" | sed "s/.sh//")"

    if [ -z "$CMD" ] || [ "$CMD" = "-h" ]; then
        echo -e "Available cmds:\n$CMDS"
        return 1
    elif ! echo "$CMDS" | grep -q -w "$CMD"; then
        echo "\"$CMD\" is not valid."
        echo -e "Available cmds:\n$CMDS"
        return 1
    else
        shift
        bash -e "$SRC_DIR/scripts/$CMD.sh" "$@"
    fi
}
# ]

TARGETS="$(ls "$SRC_DIR/target")"

if [ "$#" != 1 ]; then
    echo "Usage: source buildenv.sh <target>"
    echo -e "Available devices:\n$TARGETS"
    return 1
elif ! echo "$TARGETS" | grep -q -w "$1"; then
    echo "\"$1\" is not valid target."
    echo -e "Available devices:\n$TARGETS"
    return 1
else
    mkdir -p "$OUT_DIR"
    run_cmd build_dependencies || return 1
    [ -f "$OUT_DIR/config.sh" ] && unset $(sed "/Automatically/d" "$OUT_DIR/config.sh" | cut -d= -f1)
    bash "$SRC_DIR/scripts/internal/gen_config_file.sh" "$1" || return 1
    source "$OUT_DIR/config.sh"

    echo "=============================="
    sed "/Automatically/d" "$OUT_DIR/config.sh"
    echo "=============================="
fi

unset TARGETS
set +o allexport

ADD_TO_WORK_DIR_FROM_STOCK()
{
    local MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)
    local REGION=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 2)
    local PARTITION="$1"
    local FILE_PATH="$2"
    local TMP
    case "$PARTITION" in
        "system_ext")
            if $TARGET_HAS_SYSTEM_EXT; then
                FILE_PATH="system_ext/$FILE_PATH"
            else
                PARTITION="system"
                FILE_PATH="system/system/system_ext/$FILE_PATH"
            fi
        ;;
        *)
            FILE_PATH="$PARTITION/$FILE_PATH"
            ;;
    esac
    mkdir -p "$WORK_DIR/$(dirname "$FILE_PATH")"
    cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/$FILE_PATH" "$WORK_DIR/$FILE_PATH"
    TMP="$FILE_PATH"
    [[ "$PARTITION" == "system" ]] && TMP="$(echo "$TMP" | sed 's.^system/system/.system/.')"
    while [[ "$TMP" != "." ]]
    do
        if ! grep -q "$TMP " "$WORK_DIR/configs/fs_config-$PARTITION"; then
            if [[ "$TMP" == "$FILE_PATH" ]]; then
                echo "$TMP $3 $4 $5 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-$PARTITION"
            elif [[ "$PARTITION" == "vendor" ]]; then
                echo "$TMP 0 2000 755 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-$PARTITION"
            else
                echo "$TMP 0 0 755 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-$PARTITION"
            fi
        else
            break
        fi
        TMP="$(dirname "$TMP")"
    done
    TMP="$(echo "$FILE_PATH" | sed 's/\./\\\./g')"
    [[ "$PARTITION" == "system" ]] && TMP="$(echo "$TMP" | sed 's.^system/system/.system/.')"
    while [[ "$TMP" != "." ]]
    do
        if ! grep -q "/$TMP " "$WORK_DIR/configs/file_context-$PARTITION"; then
            echo "/$TMP $6" >> "$WORK_DIR/configs/file_context-$PARTITION"
        else
            break
        fi
        TMP="$(dirname "$TMP")"
    done
}

REMOVE_FROM_WORK_DIR()
{
    local FILE_PATH="$1"
    if [ -e "$FILE_PATH" ]; then
        local FILE
        local PARTITION
        FILE="$(echo -n "$FILE_PATH" | sed "s.$WORK_DIR/..")"
        PARTITION="$(echo -n "$FILE" | cut -d "/" -f 1)"
        echo "Debloating /$FILE"
        rm -rf "$FILE_PATH"
        [[ "$PARTITION" == "system" ]] && FILE="$(echo "$FILE" | sed 's.^system/system/.system/.')"
        FILE="$(echo -n "$FILE" | sed 's/\//\\\//g')"
        sed -i "/$FILE /d" "$WORK_DIR/configs/fs_config-$PARTITION"
        FILE="$(echo -n "$FILE" | sed 's/\./\\\\\./g')"
        sed -i "/$FILE /d" "$WORK_DIR/configs/file_context-$PARTITION"
    fi
}

ADD_TO_WORK_DIR_FROM_SOURCE()
{
    local MODEL=$(echo -n "$SOURCE_FIRMWARE" | cut -d "/" -f 1)
    local REGION=$(echo -n "$SOURCE_FIRMWARE" | cut -d "/" -f 2)
    local PARTITION="$1"
    local FILE_PATH="$2"
    local TMP
    case "$PARTITION" in
        "system_ext")
            if $TARGET_HAS_SYSTEM_EXT; then
                FILE_PATH="system_ext/$FILE_PATH"
            else
                PARTITION="system"
                FILE_PATH="system/system/system_ext/$FILE_PATH"
            fi
        ;;
        *)
            FILE_PATH="$PARTITION/$FILE_PATH"
            ;;
    esac
    mkdir -p "$WORK_DIR/$(dirname "$FILE_PATH")"
    cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/$FILE_PATH" "$WORK_DIR/$FILE_PATH"
    TMP="$FILE_PATH"
    [[ "$PARTITION" == "system" ]] && TMP="$(echo "$TMP" | sed 's.^system/system/.system/.')"
    while [[ "$TMP" != "." ]]
    do
        if ! grep -q "$TMP " "$WORK_DIR/configs/fs_config-$PARTITION"; then
            if [[ "$TMP" == "$FILE_PATH" ]]; then
                echo "$TMP $3 $4 $5 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-$PARTITION"
            elif [[ "$PARTITION" == "vendor" ]]; then
                echo "$TMP 0 2000 755 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-$PARTITION"
            else
                echo "$TMP 0 0 755 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-$PARTITION"
            fi
        else
            break
        fi
        TMP="$(dirname "$TMP")"
    done
    TMP="$(echo "$FILE_PATH" | sed 's/\./\\\./g')"
    [[ "$PARTITION" == "system" ]] && TMP="$(echo "$TMP" | sed 's.^system/system/.system/.')"
    while [[ "$TMP" != "." ]]
    do
        if ! grep -q "/$TMP " "$WORK_DIR/configs/file_context-$PARTITION"; then
            echo "/$TMP $6" >> "$WORK_DIR/configs/file_context-$PARTITION"
        else
            break
        fi
        TMP="$(dirname "$TMP")"
    done
}

GET_PROP()
{
    local PROP="$1"
    local FILE="$2"

    if [ ! -f "$FILE" ]; then
        echo "File not found: $FILE"
        exit 1
    fi

    grep "^$PROP=" "$FILE" | cut -d "=" -f2-
}

SET_PROP()
{
    local PROP="$1"
    local VALUE="$2"
    local FILE="$3"

    if [ ! -f "$FILE" ]; then
        echo "File not found: $FILE"
        return 1
    fi

    if [[ "$2" == "-d" ]] || [[ "$2" == "--delete" ]]; then
        PROP="$(echo -n "$PROP" | sed 's/=//g')"
        if grep -Fq "$PROP" "$FILE"; then
            echo "Deleting \"$PROP\" prop in $FILE" | sed "s.$WORK_DIR..g"
            sed -i "/^$PROP/d" "$FILE"
        fi
    else
        if grep -Fq "$PROP" "$FILE"; then
            local LINES

            echo "Replacing \"$PROP\" prop with \"$VALUE\" in $FILE" | sed "s.$WORK_DIR..g"
            LINES="$(sed -n "/^${PROP}\b/=" "$FILE")"
            for l in $LINES; do
                sed -i "$l c${PROP}=${VALUE}" "$FILE"
            done
        else
            echo "Adding \"$PROP\" prop with \"$VALUE\" in $FILE" | sed "s.$WORK_DIR..g"
            if ! grep -q "Added by scripts" "$FILE"; then
                echo "# Added by scripts/internal/apply_modules.sh" >> "$FILE"
            fi
            echo "$PROP=$VALUE" >> "$FILE"
        fi
    fi
}

return 0
