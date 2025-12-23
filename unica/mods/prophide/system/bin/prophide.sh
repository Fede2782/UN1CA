#!/system/bin/sh
# https://android.googlesource.com/platform/external/avb/+/88b13e12a0ebe3c5195dbb5f48ba00ec896d1517

rezetprop -n ro.boot.flash.locked "1"
rezetprop -n ro.boot.vbmeta.avb_version "1.3"
rezetprop -n ro.boot.vbmeta.device_state "locked"
rezetprop -n ro.boot.vbmeta.digest "$(dd if=/dev/block/by-name/vbmeta bs=1 count=VB_SIZE 2> /dev/null | sha256sum -b)"
rezetprop -n ro.boot.vbmeta.hash_alg "sha256"
rezetprop -n ro.boot.vbmeta.invalidate_on_error "yes"
rezetprop -n ro.boot.vbmeta.public_key_digest "$(dd if=/dev/block/by-name/vbmeta bs=1 skip=PK_OFFSET count=PK_SIZE 2> /dev/null | sha256sum -b)"
rezetprop -n ro.boot.vbmeta.size "VB_SIZE"
rezetprop -n ro.boot.warranty_bit "0"
rezetprop -n ro.boot.verifiedbootstate "green"
rezetprop -n ro.boot.veritymode "enforcing"
rezetprop -n ro.vendor.boot.warranty_bit "0"
rezetprop -n ro.vendor.build.security_patch "$(getprop ro.build.version.security_patch)"
rezetprop -n sys.oem_unlock_allowed "0"

DEVICE="$(getprop ro.product.vendor.device)"

if [ "$DEVICE" == "a34x" ]; then
    BOOT_EM_MODEL="$(getprop ro.boot.em.model)"

    rezetprop -n  "ro.product.manufacturer_for_attestation" "samsung"
    rezetprop -n "ro.product.brand_for_attestation" "samsung"
    rezetprop -n "ro.product.device_for_attestation" "a34x"
    rezetprop -n "ro.product.model_for_attestation" "$BOOT_EM_MODEL"
    rezetprop -n "ro.product.name_for_attestation" "a34xxx"

    if [ "$BOOT_EM_MODEL" == "SM-A346E" ]; then
        rezetprop -n "ro.product.name_for_attestation" "a34xdxx"
    fi

    if [ "$BOOT_EM_MODEL" == "SM-A346M" ]; then
        rezetprop -n "ro.product.name_for_attestation" "a34xub"
    fi

    if [ "$BOOT_EM_MODEL" == "SM-A346N" ]; then
        rezetprop -n "ro.product.name_for_attestation" "a34xks"
    fi

    if [ "$BOOT_EM_MODEL" == "SM-A3460" ]; then
        rezetprop -n "ro.product.name_for_attestation" "a34xzh"
    fi
fi

