# Forcefully enable Advanced Battery Information
# SM-A346B is known to support this feature so enable it

# https://cs.android.com/android/platform/superproject/+/android-latest-release:packages/apps/Settings/src/com/android/settings/core/BasePreferenceController.java
# 0x0 = SUPPORTED
# 0x3 = UNSUPPORTED ON DEVICE

# Always enable BatteryRegulatoryPreferenceController on SM-A346B
# Normally this checks for auth support or if target is SM-A236B
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes4/com/samsung/android/settings/deviceinfo/batteryinfo/BatteryRegulatoryPreferenceController.smali" "replace" \
     "getAvailabilityStatus()I" \
     "SM-A236B" "SM-A346B"

SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes4/com/samsung/android/settings/deviceinfo/batteryinfo/BatteryRegulatoryPreferenceController.smali" "replace" \
     "getAvailabilityStatus()I" \
     "ro.product.model" "ro.boot.em.model"

SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes4/com/samsung/android/settings/deviceinfo/batteryinfo/SecBatteryInfoFragment.smali" "replace" \
    "onCreateOptionsMenu(Landroid/view/Menu;Landroid/view/MenuInflater;)V" \
    "ro.product.model" "ro.boot.em.model"

SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes4/com/samsung/android/settings/deviceinfo/batteryinfo/SecBatteryInfoFragment.smali" "replace" \
    "onCreateOptionsMenu(Landroid/view/Menu;Landroid/view/MenuInflater;)V" \
    "SM-A236B" "SM-A346B"
