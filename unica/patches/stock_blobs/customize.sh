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
if [[ "$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")" != "SRCB_V5" ]] && \
        [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION")" == "SRCB_V5" ]]; then
    LOG_STEP_IN "- Adding Face Cluster V5 blobs"
    if [ -d "$WORK_DIR/system/system/saiv/face/cluster_pb" ]; then
        DELETE_FROM_WORK_DIR "system" "system/saiv/face/cluster_pb"
    fi
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/face/cluster_pb" 0 0 755 "u:object_r:system_file:s0"
    LOG_STEP_OUT
fi
if [[ "$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION")" != "V901" ]] && \
        [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION")" == "V901" ]]; then
    LOG_STEP_IN "- Adding Image Tagger V901 blobs"
    if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/aig_document_detector" ]; then
        DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/aig_document_detector"
    fi
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_document_detector" 0 2000 755 "u:object_r:vendor_snap_file:s0"
    if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/aig_document_classifier" ]; then
        DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/aig_document_classifier"
    fi
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_document_classifier" 0 2000 755 "u:object_r:vendor_snap_file:s0"
    if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/aig_classifier" ]; then
        DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/aig_classifier"
    fi
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_classifier" 0 2000 755 "u:object_r:vendor_snap_file:s0"
    if [ -d "$WORK_DIR/system/system/saiv/image_understanding/db/aig" ]; then
        DELETE_FROM_WORK_DIR "system" "system/saiv/image_understanding/db/aig"
    fi
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/image_understanding/db/aig" 0 0 755 "u:object_r:system_file:s0"
    LOG_STEP_OUT
fi
if [[ "$(GET_FLOATING_FEATURE_CONFIG "$FW_DIR/$TARGET_FIRMWARE_PATH/system/system/etc/floating_feature.xml" "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")" != "V1001" ]] && \
        [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_GALLERY_CONFIG_PET_CLUSTER_VERSION")" == "V1001" ]]; then
    LOG_STEP_IN "- Adding Pet Cluster V1001 blobs"
    if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/pet_detector" ]; then
        DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/pet_detector"
    fi
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/pet_detector" 0 2000 755 "u:object_r:vendor_snap_file:s0"
    if [ -d "$WORK_DIR/vendor/saiv/image_understanding/db/pet_mypetsearch" ]; then
        DELETE_FROM_WORK_DIR "vendor" "saiv/image_understanding/db/pet_mypetsearch"
    fi
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/pet_mypetsearch" 0 2000 755 "u:object_r:vendor_snap_file:s0"
    LOG_STEP_OUT
fi
if [ -f "$WORK_DIR/system/system/priv-app/BixbyVisionFramework3.5/BixbyVisionFramework3.5.apk" ]; then
    if [ ! -f "$WORK_DIR/vendor/etc/saiv/image_understanding/db/slens_classifier" ]; then
        ADD_TO_WORK_DIR "gts11xx" "vendor" "etc/saiv/image_understanding/db/slens_classifier/slens_classifier_cnn.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
        ADD_TO_WORK_DIR "gts11xx" "system" "system/saiv/image_understanding/db/slens_classifier/slens_classifier_cnn.sni" 0 0 644 "u:object_r:system_file:s0"
    fi
    if [ ! -f "$WORK_DIR/vendor/etc/saiv/image_understanding/db/slens_detector" ]; then
        ADD_TO_WORK_DIR "gts11xx" "vendor" "etc/saiv/image_understanding/db/slens_detector/slens_detector_cnn.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
        ADD_TO_WORK_DIR "gts11xx" "system" "system/saiv/image_understanding/db/slens_detector/slens_detector_cnn.sni" 0 0 644 "u:object_r:system_file:s0"
    fi
fi
if [ -f "$WORK_DIR/system/system/priv-app/PhotoEditor_AIFull/PhotoEditor_AIFull.apk" ] && \
        [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/hs_segmenter" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/saiv/image_understanding/db/hs_segmenter/hs_segmenter.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "etc/saiv/image_understanding/db/hs_segmenter/hs_segmenter.info" 0 0 644 "u:object_r:vendor_configs_file:s0"
fi
if [ -f "$WORK_DIR/system/system/lib64/libSmartScan.camera.samsung.so" ] && \
        [ ! -d "$WORK_DIR/vendor/etc/saiv/image_understanding/db/SS_segmenter" ]; then
    ADD_TO_WORK_DIR "a34xxx" "vendor" "etc/saiv/image_understanding/db/SS_segmenter/SS_segmenter_cnn.tflite" 0 0 644 "u:object_r:vendor_configs_file:s0"
    ADD_TO_WORK_DIR "a34xxx" "vendor" "etc/saiv/image_understanding/db/SS_segmenter/SS_segmenter_cnn.info" 0 0 644 "u:object_r:vendor_configs_file:s0"
fi
if [ -f "$WORK_DIR/system/system/lib64/libsmart_cropping.camera.samsung.so" ] && \
        [ ! -d "$WORK_DIR/system/system/saiv/smartcropping_2.0" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/smartcropping_2.0/db/smartcrop_saliency_deploy.prototxt" 0 0 644 "u:object_r:system_file:s0"
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "system" "system/saiv/smartcropping_2.0/db/smartcrop_saliency_train" 0 0 644 "u:object_r:system_file:s0"
fi
if [ -f "$WORK_DIR/system/system/lib64/libImageCropper.camera.samsung.so" ] && \
        [ ! -d "$WORK_DIR/vendor/saiv/image_understanding/db/sce_detector" ]; then
    ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/sce_detector/sce_detector_cnn.tflite" 0 0 644 "u:object_r:vendor_snap_file:s0"
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
