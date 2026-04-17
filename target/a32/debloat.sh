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

# Debloat list for Galaxy A32 4G (a32)
# - Add entries inside the specific partition containing that file (<PARTITION>_DEBLOAT+="")
# - DO NOT add the partition name at the start of any entry (eg. "/system/dpolicy_system")
# - DO NOT add a slash at the start of any entry (eg. "/dpolicy_system")

# Overlays
SYSTEM_DEBLOAT+="
system/app/WifiRROverlayAppLls
"
# Product debloat
PRODUCT_DEBLOAT+="
priv-app/AndroidAutoStub
app/BardShell
app/Chrome
app/DuoStub
app/Gmail2
app/GoogleCalendarSyncAdapter
app/Maps
app/YouTube
"

# System/app debloat
SYSTEM_DEBLOAT+="
system/app/ARCore
system/app/BGMProvider
system/app/BixbyWakeup
system/app/CarrierDefaultApp
system/app/ccinfo
system/app/ChromeCustomizations
system/app/EasymodeContactsWidget81
system/app/FactoryAirCommandManager
system/app/FactoryCameraFB
system/app/Fast
system/app/FBAppManager_NS
system/app/FunModeSDK
system/app/GearManagerStub
system/app/KidsHome_Installer
system/app/MAPSAgent
system/app/MdecService
system/app/MoccaMobile
system/app/ParentalCare
system/app/PhotoTable
system/app/PlayAutoInstallConfig
system/app/SamsungCalendar
system/app/SamsungPassAutofill_v1
system/app/SamsungTTS
system/app/SamsungTTSVoice_en_US_f00
system/app/SamsungTTSVoice_ru_RU_f00
system/app/SamsungTTSVoice_vi_VN_f00
system/app/SmartReminder
system/app/SmartSwitchStub
system/app/UnifiedWFC
system/app/UniversalMDMClient
system/app/VideoEditorLite_Dream_N
system/app/VisionIntelligence3.7
system/app/VoiceAccess
system/app/VTCameraSetting
system/app/WifiGuider
system/app/WlanTest
"

# System/priv-app debloat
SYSTEM_DEBLOAT+="
system/priv-app/AppUpdateCenter
system/priv-app/AREmoji
system/priv-app/AuthFramework
system/priv-app/AutoDoodle
system/priv-app/Bixby
system/priv-app/BixbyVisionFramework3.5
system/priv-app/CIDManager
system/priv-app/EarphoneTypeC
system/priv-app/EasySetup
system/priv-app/FBInstaller_NS
system/priv-app/FBServices
system/priv-app/FotaAgent
system/priv-app/GalleryWidget
system/priv-app/GameHome
system/priv-app/GameOptimizingService
system/priv-app/GameTools_Dream
system/priv-app/HashTagService
system/priv-app/LinkToWindowsService
system/priv-app/MemorySaver_O_Refresh
system/priv-app/MultiControl
system/priv-app/OMCAgent5
system/priv-app/OneDrive_Samsung_v3
system/priv-app/SamsungBilling
system/priv-app/SamsungCalendarProvider
system/priv-app/SamsungMessages
system/priv-app/SamsungPass
system/priv-app/SamsungPositioning
system/priv-app/SamsungSmartSuggestions
system/priv-app/SetupIndiaServicesTnC
system/priv-app/SingleTakeService
system/priv-app/SmartThingsKit
system/priv-app/SmartTouchCall
system/priv-app/SOAgent76
system/priv-app/SPPPushClient
system/priv-app/StickerFaceARAvatar
system/priv-app/StoryService
system/priv-app/TalkbackSE
system/priv-app/UltraDataSaving_O
system/priv-app/YourPhone_P1_5
"