#sed -i '/persist.sys.usb.config/d' "$WORK_DIR/vendor/odm_dlkm/etc/build.prop"
#echo "persist.sys.usb.config=mtp,adb" >> "$WORK_DIR/vendor/odm_dlkm/etc/build.prop"

#sed -i '/persist.sys.usb.config/d' "$WORK_DIR/vendor/vendor_dlkm/etc/build.prop"
#echo "persist.sys.usb.config=mtp,adb" >> "$WORK_DIR/vendor/vendor_dlkm/etc/build.prop"

SKIPUNZIP=1

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

SET_PROP "persist.sys.usb.config" "mtp,adb" "$WORK_DIR/vendor/odm_dlkm/etc/build.prop"
SET_PROP "persist.sys.usb.config" "mtp,adb" "$WORK_DIR/vendor/vendor_dlkm/etc/build.prop"
