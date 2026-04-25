# [
MATCH_TARGET_FEATURES()
{
    local SOURCE_FEATURES
    local TARGET_FEATURES

    SOURCE_FEATURES="$(find "$WORK_DIR/system/system/etc/permissions" -name "com.sec.feature*" -printf "%f\n")"
    SOURCE_FEATURES="$(sort <<< "$SOURCE_FEATURES")"
    TARGET_FEATURES="$(find "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/permissions" -name "com.sec.feature*" -printf "%f\n")"
    TARGET_FEATURES="$(sort <<< "$TARGET_FEATURES")"

    for f in $SOURCE_FEATURES; do
        if ! grep -q "$f" <<< "$TARGET_FEATURES"; then
            DELETE_FROM_WORK_DIR "system" "system/etc/permissions/$f"
        fi
    done
    for f in $TARGET_FEATURES; do
        if ! grep -q "$f" <<< "$SOURCE_FEATURES"; then
            ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/permissions/$f" 0 0 644 "u:object_r:system_file:s0"
        fi
    done
}
# ]

TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

MATCH_TARGET_FEATURES

if [ -d "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/saiv" ]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" \
        "system/etc/saiv/image_understanding/db/aic_classifier/aic_classifier_cnn.info" 0 0 644 "u:object_r:system_file:s0"
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" \
        "system/etc/saiv/image_understanding/db/aic_detector/aic_detector_cnn.info" 0 0 644 "u:object_r:system_file:s0"
else
    if [ -d "$WORK_DIR/system/system/etc/saiv" ]; then
        DELETE_FROM_WORK_DIR "system" "system/etc/saiv"
    fi
fi

# TODO add APE/DSD extractor libs if required
if [ -f "$WORK_DIR/system/system/lib64/extractors/libsapeextractor.so" ] && \
        [ ! "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_APE_FORMAT")" ]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/extractors/libsapeextractor.so"
fi
if [ -f "$WORK_DIR/system/system/lib64/extractors/libsdffextractor.so" ] && \
        [ ! "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_DSD_FORMAT")" ]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/extractors/libsdffextractor.so"
fi
if [ -f "$WORK_DIR/system/system/lib64/extractors/libsdsfextractor.so" ] && \
        [ ! "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_DSD_FORMAT")" ]; then
    DELETE_FROM_WORK_DIR "system" "system/lib64/extractors/libsdsfextractor.so"
fi

ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/media/bootsamsung.qmg" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/media/bootsamsungloop.qmg" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/media/shutdown.qmg" 0 0 644 "u:object_r:system_file:s0"

if [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/priv-app/SohService/SohService.apk" ]; then
    DECODE_APK "system" "system/priv-app/SohService/SohService.apk"

    LOG "- Adding target BSOH blobs"
    EVAL "rm -r \"$APKTOOL_DIR/system/priv-app/SohService/SohService.apk/assets\""
    EVAL "unzip -q \"$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/priv-app/SohService/SohService.apk\" \"assets/*\" -d \"$APKTOOL_DIR/system/priv-app/SohService/SohService.apk\""
else
    if [ -f "$WORK_DIR/system/system/priv-app/SohService/SohService.apk" ]; then
        DELETE_FROM_WORK_DIR "system" "system/priv-app/SohService"
    fi
fi

DELETE_FROM_WORK_DIR "system" "system/saiv"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/saiv" 0 0 755 "u:object_r:system_file:s0"
if [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS")" == *"AI_DEWARPING"* ]]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" \
        "system" "system/saiv/image_understanding/db/smartscan_rectifier" 0 0 755 "u:object_r:system_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" \
        "vendor" "saiv/image_understanding/db/smartscan_rectifier" 0 2000 755 "u:object_r:vendor_snap_file:s0"
else
    if [ -d "$WORK_DIR/system/system/saiv/image_understanding/db/smartscan_rectifier" ]; then
        DELETE_FROM_WORK_DIR "system" "system/saiv/image_understanding/db/smartscan_rectifier"
    fi
    if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/smartscan_rectifier" ]; then
        DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/smartscan_rectifier"
    fi
fi

if [[ "$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")" == "None" ]] && \
        [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")" == "V1001" ]]; then
    LOG_STEP_IN "- Adding Pet Cluster V1001 blobs"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/pet_detector" 0 2000 755 "u:object_r:vendor_configs_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/pet_mypetsearch" 0 2000 755 "u:object_r:vendor_configs_file:s0"
    LOG_STEP_OUT
fi



if [[ "$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION")" != "V901" ]] && \
        [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION")" == "V901" ]]; then
    LOG_STEP_IN "- Adding Image Tagger V901 blobs"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_document_detector" 0 2000 755 "u:object_r:vendor_configs_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_document_classifier" 0 2000 755 "u:object_r:vendor_configs_file:s0"
    DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/aig_classifier"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_classifier" 0 2000 755 "u:object_r:vendor_configs_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/image_understanding/db/aig" 0 0 755 "u:object_r:system_file:s0"
    LOG_STEP_OUT
fi

if [[ "$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")" != "SRCB_V5" ]] && \
        [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")" == "SRCB_V5" ]]; then
    LOG_STEP_IN "- Adding Face Cluster V5 blobs"
    DELETE_FROM_WORK_DIR "system" "system/saiv/face/cluster_pb"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/face/cluster_pb" 0 0 755 "u:object_r:system_file:s0"
    LOG_STEP_OUT
fi

if [ -f "$WORK_DIR/system/system/lib64/libSceneDetector_v1.camera.samsung.so" ]; then
    if [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/aic_classifier" ] || \
          [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/aic_detector" ]; then
      DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/aic_classifier"
      ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/image_understanding/db/aic_classifier" 0 0 755 "u:object_r:system_file:s0"
      ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/saiv/image_understanding/db/aic_classifier" 0 2000 755 "u:object_r:vendor_configs_file:s0"
      DELETE_FROM_WORK_DIR "vendor" "etc/saiv/image_understanding/db/aic_detector"
      ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/image_understanding/db/aic_detector" 0 0 755 "u:object_r:system_file:s0"
      ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/saiv/image_understanding/db/aic_detector" 0 2000 755 "u:object_r:vendor_configs_file:s0"
    fi
fi

if [ -f "$WORK_DIR/system/system/lib64/libObjectDetector_v1.camera.samsung.so" ] && \
        [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/aic_g_o_detector" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/image_understanding/db/aic_g_o_detector" 0 0 755 "u:object_r:system_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/saiv/image_understanding/db/aic_g_o_detector" 0 2000 755 "u:object_r:vendor_configs_file:s0"
fi

if [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/slens_detector" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/image_understanding/db/slens_detector" 0 0 755 "u:object_r:system_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/saiv/image_understanding/db/slens_detector" 0 2000 755 "u:object_r:vendor_configs_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/image_understanding/db/slens_classifier" 0 0 755 "u:object_r:system_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/saiv/image_understanding/db/slens_classifier" 0 2000 755 "u:object_r:vendor_configs_file:s0"
fi

if [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/hs_segmenter" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/saiv/image_understanding/db/hs_segmenter" 0 2000 755 "u:object_r:vendor_configs_file:s0"
fi

if [ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_ACTION_CLASSIFIER")" ] && \
       [ ! -d "$WORK_DIR/vendor/etc/singletake/dynamic_viewing" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/singletake/dynamic_viewing" 0 2000 755 "u:object_r:vendor_configs_file:s0"
fi

if grep -q "SUPPORT_AI_FILTER.*true" "$WORK_DIR/system/system/cameradata/singletake/service-feature.xml" 2> /dev/null && \
       grep -q "SUPPORT_SMART_CROP.*true" "$WORK_DIR/system/system/cameradata/singletake/service-feature.xml" 2> /dev/null && \
       [ ! -d "$WORK_DIR/vendor/etc/singletake/SmartCrop" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/singletake/SmartCrop" 0 2000 755 "u:object_r:vendor_configs_file:s0"
fi

DELETE_FROM_WORK_DIR "system" "system/saiv/textrecognition"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/textrecognition" 0 0 755 "u:object_r:system_file:s0"

if [ -f "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/usr/share/alsa/alsa.conf" ]; then
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/usr/share/alsa/alsa.conf" 0 0 644 "u:object_r:system_file:s0"
else
    if [ -d "$WORK_DIR/system/system/usr/share/alsa" ]; then
        DELETE_FROM_WORK_DIR "system" "system/usr/share/alsa"
    fi
fi

unset TARGET_FIRMWARE_PATH
unset -f MATCH_TARGET_FEATURES
