SKIPUNZIP=1

sed -i "/hal_dsms_default/d" "$WORK_DIR/system_ext/etc/selinux/mapping/31.0.cil"
sed -i "/proactiveness/d" "$WORK_DIR/system_ext/etc/selinux/mapping/31.0.cil"
sed -i "/genfscon.*proactiveness/d" "$WORK_DIR/system_ext/etc/selinux/system_ext_sepolicy.cil"
