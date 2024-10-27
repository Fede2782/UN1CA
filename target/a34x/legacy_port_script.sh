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

SOURCE_MODEL=$(echo -n "$SOURCE_FIRMWARE" | cut -d "/" -f 1)
SOURCE_REGION=$(echo -n "$SOURCE_FIRMWARE" | cut -d "/" -f 2)

# OneUI version values
SEP_VALUE=$(GET_PROP "ro.build.version.sep" "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/build.prop")
SEM_VALUE=$(GET_PROP "ro.build.version.sem" "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/build.prop")
ONEUI_VALUE=$(GET_PROP "ro.build.version.oneui" "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/build.prop")
SEHI_VALUE=$(GET_PROP "ro.system.build.version.sehi" "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/build.prop")

SET_PROP "ro.build.version.sep" \
    "$SEP_VALUE" \
    "$WORK_DIR/system/system/build.prop"

SET_PROP "ro.build.version.sem" \
    "$SEM_VALUE" \
    "$WORK_DIR/system/system/build.prop"

SET_PROP "ro.build.version.oneui" \
    "$ONEUI_VALUE" \
    "$WORK_DIR/system/system/build.prop"

SET_PROP "ro.system.build.version.sehi" \
    "$SEHI_VALUE" \
    "$WORK_DIR/system/system/build.prop"

# The following commands are available to copy files from stock and source to out as well as deleting
# ADD_TO_WORK_DIR_FROM_STOCK <partition> <relative file> <permission in X X XXX format (3args)> <secontext>
# REMOVE_FILE_FROM_WORK_DIR <absolute file path>

# New One UI 6.1.1 apps for all devices
# DO NOT PUT ANYTHING WHICH IS NOT PART OF STANDARD ONE UI 6.1.1 (tab s9 fe feature level)
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/priv-app/GlobalPostProcMgr/GlobalPostProcMgr.apk" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/etc/permissions/privapp-permissions-com.samsung.android.globalpostprocmgr.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/etc/default-permissions/default-permissions-com.samsung.android.globalpostprocmgr.xml" 0 0 644 "u:object_r:system_file:s0"

# Not used in s23 fe
REMOVE_FROM_WORK_DIR "$WORK_DIR/system/system/priv-app/SamsungCamera/SamsungCamera.apk.prof"

# Renamed
REMOVE_FROM_WORK_DIR "$WORK_DIR/system/system/priv-app/SoundAlive_U"
REMOVE_FROM_WORK_DIR "$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.sec.android.app.soundalive_U.xml"
REMOVE_FROM_WORK_DIR "$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.sec.hearingadjust_U.xml"
REMOVE_FROM_WORK_DIR "$WORK_DIR/system/system/priv-app/RubinVersion34"
REMOVE_FROM_WORK_DIR "$WORK_DIR/system/system/priv-app/AdaptSound_U"
REMOVE_FROM_WORK_DIR "$WORK_DIR/system/system/priv-app/PhotoEditor_Full"

ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/priv-app/AdaptSound_U2/AdaptSound_U2.apk" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/priv-app/SoundAlive_U2/SoundAlive_U2.apk" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/etc/permissions/privapp-permissions-com.sec.android.app.soundalive_U2.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/etc/permissions/privapp-permissions-com.sec.hearingadjust_U2.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/priv-app/RubinVersion35/RubinVersion35.apk" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/priv-app/PhotoEditor_AIFull/PhotoEditor_AIFull.apk" 0 0 644 "u:object_r:system_file:s0"

PDR="$(pwd)"
cd $WORK_DIR/system/system/priv-app
PAPPS_LIST=($(find -type f | sed 's/.\///' ))
for papp in "${PAPPS_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/priv-app/$papp" $papp
done

cd $PDR
