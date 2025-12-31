# add missing 64bit codecs
CODECS="
libh264dec_sa.ca7.so
libh264dec_customize.so
libHEVCdec_sa.ca7.android.so
libh264dec_se.ca7.so
libvp8dec_sa.ca7.so
libh264dec_sd.ca7.so
libvp9dec_sa.ca7.so
"

for codec in $CODECS; do
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "lib64/$codec"
done

# run in 64only mode
SET_PROP "vendor" "ro.vendor.product.cpu.abilist" "arm64-v8a"
SET_PROP "vendor" "ro.vendor.product.cpu.abilist32" ""
SET_PROP "vendor" "ro.vendor.product.cpu.abilist64" "arm64-v8a"
SET_PROP "vendor" "ro.zygote" "zygote64"
SET_PROP "vendor" "dalvik.vm.dex2oat64.enabled" "true"

# clean up 32 bit libs
DELETE_FROM_WORK_DIR "vendor" "lib"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "vendor" "lib/egl/egl.cfg"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "vendor" "lib/modules"

# delete 32bit variants
DELETE_FROM_WORK_DIR "vendor" "bin/hw/android.hardware.media.c2@1.2-mediatek"
DELETE_FROM_WORK_DIR "vendor" "bin/hw/android.hardware.media.c2-mediatek"
DELETE_FROM_WORK_DIR "vendor" "bin/hw/android.hardware.media.omx@1.0-service"
DELETE_FROM_WORK_DIR "vendor" "etc/init/android.hardware.media.c2-mediatek.rc"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/init/android.hardware.media.c2-mediatek-64b.rc"

#mtk_rcs
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "bin/volte_rcs_ua"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "lib64/vendor.mediatek.hardware.rcs-V1-ndk.so"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "lib64/vendor.mediatek.hardware.rcs@2.0.so"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "lib64/vendor.mediatek.hardware.mtkradioex.rcs-V2-ndk.so"

#aee, keep only 64 and migrate to v2
DELETE_FROM_WORK_DIR "vendor" "etc/init/aee_aedv.rc"
DELETE_FROM_WORK_DIR "vendor" "bin/aee_aedv"
DELETE_FROM_WORK_DIR "vendor" "etc/init/aee_aedv64.rc"
DELETE_FROM_WORK_DIR "vendor" "bin/aee_aedv64"
DELETE_FROM_WORK_DIR "vendor" "bin/aeev"
DELETE_FROM_WORK_DIR "vendor" "bin/aee_dumpstatev"
DELETE_FROM_WORK_DIR "vendor" "bin/rttv"

AEE_FILES="
bin/aee_dumpstatev_v2
bin/aee_aedv64_v2
bin/aeev_v2
etc/init/aee_aedv64_v2.rc
bin/rttv_v2
"

for file in $AEE_FILES; do
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "$file"
done

# nuke vpu3
DELETE_FROM_WORK_DIR "vendor" "etc/init/v3avpud.rc"
DELETE_FROM_WORK_DIR "vendor" "bin/v3avpud"

# nuke fuelguage and boringssl test
DELETE_FROM_WORK_DIR "vendor" "etc/init/fuelgauged_init.rc"
DELETE_FROM_WORK_DIR "vendor" "etc/init/fuelgauged_nvram_init.rc"
DELETE_FROM_WORK_DIR "vendor" "bin/boringssl_self_test32"
DELETE_FROM_WORK_DIR "vendor" "bin/fuelgauged"
