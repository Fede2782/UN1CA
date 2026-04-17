# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# UN1CA configuration file for MediaTek devices (mssi)

# Inherit source firmware configuration from essi
source "$SRC_DIR/unica/configs/essi.sh" || return 1

# Galaxy A32 4G (One UI 5.1)
SOURCE_EXTRA_FIRMWARES=()
SOURCE_SUPER_GROUP_NAME="main"
