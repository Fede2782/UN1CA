# Set default SIM count to 1
# Before: cbz x0,0x0010340c
# After: cbz x0,0x001031d4
# Move conditional jump when factory.prop is not found from defaulting to 2 to 1
HEX_PATCH "$WORK_DIR/vendor/bin/secril_config_svc" "601300b4" "a00100b4"
