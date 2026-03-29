LOG_STEP_IN "- Adding OK Google Hotword Enrollment blobs"
DELETE_FROM_WORK_DIR "product" "priv-app/HotwordEnrollmentOKGoogleEx4CORTEXM55"
DELETE_FROM_WORK_DIR "product" "priv-app/HotwordEnrollmentXGoogleEx4CORTEXM55"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "product" "priv-app/HotwordEnrollmentOKGoogleEx4RISCV" 0 0 755 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "product" "priv-app/HotwordEnrollmentXGoogleEx4RISCV" 0 0 755 "u:object_r:system_file:s0"
LOG_STEP_OUT

LOG_STEP_IN "- Fix Photo Remaster"
# Fix Photo Remaster
EVAL "echo \"ro.midas.device u:object_r:build_prop:s0 exact string\"  >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""
SET_PROP "system" "ro.midas.device" "a34x"
HEX_PATCH "$WORK_DIR/system/system/lib64/libmidas_core.camera.samsung.so" \
    "726f2e70726f647563742e646576696365" "726f2e6d696461732e6465766963650000"
LOG_STEP_OUT

ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/libImageTagger.camera.samsung.so" 0 0 644 "u:object_r:system_lib_file:s0"

LOG_STEP_IN "- Add Instant Slow Mo"
FILES="
lib64/libmppaifrc.so
lib64/libmpp_common_vendor.so
lib64/libmppdeflicker.so
lib64/libmpp_vendor.so
lib64/vendor.samsung.hardware.media.mpp-V5-ndk.so
lib64/libaifrc.quram.so
etc/saiv/frc/db/aifrc/aifrc.dla
bin/hw/mppserver
etc/vintf/manifest/mppserver.xml
etc/init/mppserver.rc
lib64/libarcsoft_deflicker_native.so
"
for f in $FILES; do
   ADD_TO_WORK_DIR "SM-X936B/EUX" "vendor" "$f"
done

FILES="
lib64/libaifrc.aidl.quram.so
lib64/libaifrcInterface.camera.samsung.so
lib64/libmcaimegpu.samsung.so
lib64/libmppclient.so
lib64/libmpp_common.so
lib64/libmppfilter.so
lib64/libmpp.so
lib64/vendor.samsung.hardware.media.mpp-V5-ndk.so
lib64/libSlowShutter_jni.media.samsung.so
lib64/libSlowShutter-core.so
lib64/libFrucPSVTLib.so
"
for f in $FILES; do
   ADD_TO_WORK_DIR "SM-X936B/EUX" "system" "system/$f"
done

if ! grep -q "libSlowShutter_jni.media.samsung.so" "$WORK_DIR/system/system/etc/public.libraries-media.samsung.txt"; then
    LOG "Adding libSlowShutter_jni.media.samsung.so to public libraries"
    echo "libSlowShutter_jni.media.samsung.so" >> "$WORK_DIR/system/system/etc/public.libraries-media.samsung.txt"
fi

if ! grep -q "libaifrcInterface.camera.samsung.so" "$WORK_DIR/system/system/etc/public.libraries-camera.samsung.txt"; then
    LOG "Adding libaifrcInterface.camera.samsung.so to public libraries"
    echo "libaifrcInterface.camera.samsung.so" >> "$WORK_DIR/system/system/etc/public.libraries-camera.samsung.txt"
fi

unset FILES
LOG_STEP_OUT
