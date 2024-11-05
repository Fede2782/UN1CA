source buildenv.sh a34x

NEED_FW_DOWNLOAD=false
bash "$SRC_DIR/scripts/extract_fw.sh" &> /dev/null || NEED_FW_DOWNLOAD=true
if $NEED_FW_DOWNLOAD; then
    bash "$SRC_DIR/scripts/download_fw.sh"
    bash "$SRC_DIR/scripts/extract_fw.sh"
fi

PDR="$(pwd)"

SOURCE_REGION=$(echo -n "$SOURCE_FIRMWARE" | cut -d "/" -f 2)
SOURCE_MODEL=$(echo -n "$SOURCE_FIRMWARE" | cut -d "/" -f 1)

TARGET_REGION=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 2)
TARGET_MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)

echo "Setting up workdir..."
rm -rf $WORK_DIR

run_cmd cleanup work_dir
run_cmd cleanup apktool

mkdir -p $WORK_DIR

# Copy stock
mkdir "$WORK_DIR/configs"
mkdir "$WORK_DIR/kernel"

TARGET_PARTITIONS=("system" "vendor" "odm" "system_ext")
SOURCE_PARTITIONS=("product")

for partition in "${TARGET_PARTITIONS[@]}"
do
	echo "Copying $partition from target..."
	mkdir "$WORK_DIR/$partition"
	cp --preserve=all -a "$FW_DIR/${TARGET_MODEL}_${TARGET_REGION}/$partition" "$WORK_DIR"
	cp --preserve=all "$FW_DIR/${TARGET_MODEL}_${TARGET_REGION}/fs_config-$partition" "$WORK_DIR/configs/fs_config-$partition"
        cp --preserve=all "$FW_DIR/${TARGET_MODEL}_${TARGET_REGION}/file_context-$partition" "$WORK_DIR/configs/file_context-$partition"
done

for partition in "${SOURCE_PARTITIONS[@]}"
do
        echo "Copying $partition from source..."
        mkdir "$WORK_DIR/$partition"
        cp --preserve=all -a "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/$partition" "$WORK_DIR"
        cp --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/fs_config-$partition" "$WORK_DIR/configs/fs_config-$partition"
        cp --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/file_context-$partition" "$WORK_DIR/configs/file_context-$partition"
done

echo "Copying stock kernel..."
cp --preserve=all "$FW_DIR/${TARGET_MODEL}_${TARGET_REGION}/boot.img" "$WORK_DIR/kernel/"
cp --preserve=all "$FW_DIR/${TARGET_MODEL}_${TARGET_REGION}/dtbo.img" "$WORK_DIR/kernel/"

# Debloat

bash "$SRC_DIR/scripts/internal/apply_debloat.sh"

# Handle priv-apps

echo "Porting priv-apps from source..."
sed -i "s/AdaptSound_U/AdaptSound_U2/g" "$WORK_DIR/configs/file_context-system"
sed -i "s/AdaptSound_U/AdaptSound_U2/g" "$WORK_DIR/configs/fs_config-system"

sed -i "s/SoundAlive_U/SoundAlive_U2/g" "$WORK_DIR/configs/file_context-system"
sed -i "s/SoundAlive_U/SoundAlive_U2/g" "$WORK_DIR/configs/fs_config-system"

sed -i "s/RubinVersion34/RubinVersion35/g" "$WORK_DIR/configs/file_context-system"
sed -i "s/RubinVersion34/RubinVersion35/g" "$WORK_DIR/configs/fs_config-system"

sed -i "s/PhotoEditor_Full/PhotoEditor_AIFull/g" "$WORK_DIR/configs/file_context-system"
sed -i "s/PhotoEditor_Full/PhotoEditor_AIFull/g" "$WORK_DIR/configs/fs_config-system"

mv "$WORK_DIR/system/system/priv-app/AdaptSound_U/AdaptSound_U.apk" "$WORK_DIR/system/system/priv-app/AdaptSound_U/AdaptSound_U2.apk"
mv "$WORK_DIR/system/system/priv-app/AdaptSound_U" "$WORK_DIR/system/system/priv-app/AdaptSound_U2"

mv "$WORK_DIR/system/system/priv-app/SoundAlive_U/SoundAlive_U.apk" "$WORK_DIR/system/system/priv-app/SoundAlive_U/SoundAlive_U2.apk"
mv "$WORK_DIR/system/system/priv-app/SoundAlive_U" "$WORK_DIR/system/system/priv-app/SoundAlive_U2"

mv "$WORK_DIR/system/system/priv-app/RubinVersion34/RubinVersion34.apk" "$WORK_DIR/system/system/priv-app/RubinVersion34/RubinVersion35.apk"
mv "$WORK_DIR/system/system/priv-app/RubinVersion34" "$WORK_DIR/system/system/priv-app/RubinVersion35"

mv "$WORK_DIR/system/system/priv-app/PhotoEditor_Full/PhotoEditor_Full.apk" "$WORK_DIR/system/system/priv-app/PhotoEditor_Full/PhotoEditor_AIFull.apk"
mv "$WORK_DIR/system/system/priv-app/PhotoEditor_Full" "$WORK_DIR/system/system/priv-app/PhotoEditor_AIFull"

cd $WORK_DIR/system/system/priv-app
PAPPS_LIST=($(find -type f | sed 's/.\///' ))
for papp in "${PAPPS_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/priv-app/$papp" $papp
done

echo "Porting frameworks from source..."
cd $WORK_DIR/system/system/framework
FWK_LIST=($(find -type f | sed 's/.\///' | sed '/verizon.net.sip.jar/d' | sed '/msync-lib.jar/d' ))
for fwk in "${FWK_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/framework/$fwk" $fwk
done

echo "Porting apps from source..."
cd $WORK_DIR/system/system/app
APPS_LIST=($(find -type f | sed 's/.\///' | sed '/FunModeSDK/d' | sed '/SecFactoryPhoneTest/d' ))
for app in "${APPS_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/app/$app" $app
done

ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/app/MhsAiService/MhsAiService.apk" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/app/VisualCloudCore/VisualCloudCore.apk" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/app/SilentLog/SilentLog.apk" 0 0 644 "u:object_r:system_file:s0"

echo "Porting fonts from source..."
cd $WORK_DIR/system/system/fonts
FONT_LIST=($(find -type f | sed 's/.\///' ))
for font in "${FONT_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/fonts/$font" $font
done

echo "Porting usr from source..."
cd $WORK_DIR/system/system/usr
USR_LIST=($(find ./ -type f  | sed '/icu/d' | sed '/alsa/d' | sed 's/.\///' ))
for usr in "${USR_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/usr/$usr" $usr
done

echo "Porting heimdalldata from source..."
cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/heimdallddata/spec.txt" "$WORK_DIR/system/system/heimdallddata/spec.txt"

echo "Porting etc from source..."
cd $WORK_DIR/system/system/etc/default-permissions
DF_PERM_LIST=($(find -type f | sed 's/.\///' ))
for perm in "${DF_PERM_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/etc/default-permissions/$perm" $perm
done

ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/etc/default-permissions/default-permissions-com.samsung.android.globalpostprocmgr.xml" 0 0 644 "u:object_r:system_file:s0"

sed -i "s/privapp-permissions-com.sec.hearingadjust_U/privapp-permissions-com.sec.hearingadjust_U2/g" "$WORK_DIR/configs/file_context-system"
sed -i "s/privapp-permissions-com.sec.hearingadjust_U/privapp-permissions-com.sec.hearingadjust_U2/g" "$WORK_DIR/configs/fs_config-system"

sed -i "s/privapp-permissions-com.sec.android.app.soundalive_U/privapp-permissions-com.sec.android.app.soundalive_U2/g" "$WORK_DIR/configs/file_context-system"
sed -i "s/privapp-permissions-com.sec.android.app.soundalive_U/privapp-permissions-com.sec.android.app.soundalive_U2/g" "$WORK_DIR/configs/fs_config-system"

mv "$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.sec.android.app.soundalive_U.xml" "$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.sec.android.app.soundalive_U2.xml"
mv "$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.sec.hearingadjust_U.xml" "$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.sec.hearingadjust_U2.xml"

cd $WORK_DIR/system/system/etc/permissions
PERM_LIST=($(find -type f | sed 's/.\///' | sed '/com.sec.feature.battauthmanager.xml/d' | sed '/com.sec.feature.nsflp_level_600.xml/d' | sed '/com.sec.feature.sensorhub_level100.xml/d' |  sed '/verizon_net/d' | sed '/privapp-permissions-mediatek/d' | sed '/handheld_core_hardware/d' ))
for perm in "${PERM_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/etc/permissions/$perm" $perm
done

ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/etc/permissions/privapp-permissions-com.samsung.android.globalpostprocmgr.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/etc/permissions/com.samsung.android.oneui.version.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR_FROM_SOURCE "system" "system/etc/permissions/com.samsung.feature.audio_listenback.xml" 0 0 644 "u:object_r:system_file:s0"

echo "Customizing product from source..."
cd $WORK_DIR/product
cp "$FW_DIR/${TARGET_MODEL}_${TARGET_REGION}/product/overlay/framework-res__auto_generated_rro_product.apk" "$WORK_DIR/product/overlay/framework-res__auto_generated_rro_product.apk"

ADD_TO_WORK_DIR_FROM_STOCK "product" "etc/permissions/product-permissions-mediatek.xml" 0 0 644 "u:object_r:system_file:s0"

rm -rf "$WORK_DIR/product/priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM55"
cp -a --preserve=all "$FW_DIR/${TARGET_MODEL}_${TARGET_REGION}/product/priv-app/HotwordEnrollmentOKGoogleEx4RISCV" "$WORK_DIR/product/priv-app"
rm -rf "$WORK_DIR/product/priv-app/HotwordEnrollmentXGoogleEx4CORTEXM55"
cp -a --preserve=all "$FW_DIR/${TARGET_MODEL}_${TARGET_REGION}/product/priv-app/HotwordEnrollmentXGoogleEx4RISCV" "$WORK_DIR/product/priv-app"
sed -i "s/HotwordEnrollmentXGoogleEx4CORTEXM55/HotwordEnrollmentXGoogleEx4RISCV/g" "$WORK_DIR/configs/file_context-product"
sed -i "s/HotwordEnrollmentXGoogleEx4CORTEXM55/HotwordEnrollmentXGoogleEx4RISCV/g" "$WORK_DIR/configs/fs_config-product"
sed -i "s/HotwordEnrollmentOKGoogleEx4CORTEXM55/HotwordEnrollmentOKGoogleEx4RISCV/g" "$WORK_DIR/configs/file_context-product"
sed -i "s/HotwordEnrollmentOKGoogleEx4CORTEXM55/HotwordEnrollmentOKGoogleEx4RISCV/g" "$WORK_DIR/configs/fs_config-product"

cp "$FW_DIR/${TARGET_MODEL}_${TARGET_REGION}/product/etc/build.prop" "$WORK_DIR/product/etc/build.prop"

echo "Porting system_ext priv-app from source..."

cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/system_ext/etc/permissions/com.android.systemui.xml" "$WORK_DIR/system_ext/etc/permissions/com.android.systemui.xml"

cd $WORK_DIR/system_ext/priv-app
PAPPS_LIST=($(find -type f | sed 's/.\///' | sed '/MtkEmergencyInfo/d' | sed '/ApmService/d' ))
for papp in "${PAPPS_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/system_ext/priv-app/$papp" $papp
done

# Debloat again in case i missed something
bash "$SRC_DIR/scripts/internal/apply_debloat.sh"

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

cd "$WORK_DIR/system/system/apex"
APEX_LIST=($(find -type f | sed 's/.\///' )) #| grep google))
for apex in "${APEX_LIST[@]}"
do
  cp -a --preserve=all "$FW_DIR/${SOURCE_MODEL}_${SOURCE_REGION}/system/system/apex/$apex" $apex
done

echo "Applying patches..."
bash "$SRC_DIR/scripts/internal/apply_modules.sh" "$SRC_DIR/target/a34x/patches"

echo -e "\n- Recompiling APKs/JARs..."
while read -r i; do
    bash "$SRC_DIR/scripts/apktool.sh" b "$i"
done <<< "$(find "$OUT_DIR/apktool" -type d \( -name "*.apk" -o -name "*.jar" \) -printf "%p\n" | sed "s.$OUT_DIR/apktool..")"

[[ "$TARGET_INSTALL_METHOD" == "zip" ]] && BUILD_ZIP=true
[[ "$TARGET_INSTALL_METHOD" == "odin" ]] && BUILD_TAR=true

if $BUILD_ZIP; then
    echo "- Building ROM zip..."
    bash "$SRC_DIR/scripts/internal/build_flashable_zip.sh"
    echo ""
elif $BUILD_TAR; then
    echo "- Building ROM tar..."
    bash "$SRC_DIR/scripts/internal/build_odin_package.sh"
    echo ""
fi

cd $PDR

# Base system is now OK. We must apply patches now

