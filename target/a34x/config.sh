#
# Copyright (C) 2024 Fede2782
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

# Device configuration file for Galaxy A34 5G (a34x)
TARGET_NAME="Galaxy A34 5G"
TARGET_CODENAME="a34x"
TARGET_FIRMWARE="SM-A346B/EUX/351648447351835"
TARGET_EXTRA_FIRMWARES=()
TARGET_API_LEVEL=34
TARGET_VNDK_VERSION=31
TARGET_SINGLE_SYSTEM_IMAGE="essi" #TODO: use a proper image
TARGET_OS_FILE_SYSTEM="erofs"
TARGET_INSTALL_METHOD="odin"
TARGET_KEEP_ORIGINAL_SIGN=true
TARGET_SUPER_PARTITION_SIZE=11744051200
TARGET_SUPER_GROUP_SIZE=11739856896
TARGET_HAS_SYSTEM_EXT=true

# SEC Product Feature
TARGET_HAS_KNOX_DUALDAR=true #TODO
TARGET_HAS_KNOX_SDP=false
TARGET_HAS_HW_MDNIE=false
TARGET_HAS_MASS_CAMERA_APP=true
TARGET_HAS_OPTICAL_FP_SENSOR=true
TARGET_IS_ESIM_SUPPORTED=false
