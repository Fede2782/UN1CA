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

# UN1CA configuration file for MediaTek devices (mssi)

# Inherit source firmware configuration from essi
source "$SRC_DIR/unica/configs/essi.sh" || return 1

# Galaxy A34 5G (One UI 8.0)
SOURCE_FIRMWARE="SM-X736B/EUX/R52Y8065XJM"
SOURCE_EXTRA_FIRMWARES=("SM-A346B/EUX/351648441234565")
SOURCE_SUPER_GROUP_NAME="main"
