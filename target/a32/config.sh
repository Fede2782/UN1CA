#
# Copyright (C) 2025 Salvo Giangreco
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Device configuration file for Galaxy A32 4G (a32)
TARGET_NAME="Galaxy A32 4G"
TARGET_CODENAME="a32"
TARGET_ASSERT_MODEL=("SM-A325F")
TARGET_FIRMWARE="SM-A325F/PHE/352049243861557"
TARGET_EXTRA_FIRMWARE=()
TARGET_PLATFORM_SDK_VERSION=31
TARGET_PRODUCT_SHIPPING_API_LEVEL=30
TARGET_BOARD_API_LEVEL=31

# Partitions
TARGET_BOOT_PARTITION_SIZE="33554432"

# Dynamic partitions
TARGET_SUPER_PARTITION_SIZE="7839154176"
TARGET_SUPER_GROUP_NAME="main"
TARGET_MAIN_SIZE="8539602944"

# OS
TARGET_OS_SINGLE_SYSTEM_IMAGE="mssi"
TARGET_OS_BUILD_SYSTEM_EXT_PARTITION=false
TARGET_OS_BOOT_DEVICE_PATH="/dev/block/by-name"