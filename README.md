# ahk-svrvmr

# SteamVR VoiceMeeter-Remote (SVRVMR)

## by bradynp

---

* Performance

the script usually makes a single DLL call twice per second\
when adjusting volume, it makes an additional DLL call\
script is to be launched after VR has completely loaded\
see example\
voicemeeter audio engine may need a reboot

* Adjustable Parameters

global HMD_Bus := "1" ; determines which voicemeeter bus (0-2/4 on banana, 0-4/7 on potato) to use, default: 4
global VRActivePid := "firefox.exe" ; the process name whose mixer will be monitored
global busGain = 0.0 ; device gain on startup
global gainCurve = 4.0
global Update_Period_ms := 500 ; how often to check the dashboard volume slider, default: 500

; only adjust the following if you have a nonstandard voicemeeter installation!!
global VMR_DLL_DRIVE := "C:"
global VMR_DLL_DIRPATH := "Program Files (x86)\VB\Voicemeeter"
global VMR_DLL_FILENAME_32 := "VoicemeeterRemote.dll"
global VMR_DLL_FILENAME_64 := "VoicemeeterRemote64.dll"

* Errors & Solutions

__"No application volume interface"__ -

make sure SteamVR is running before the script starts

__"VoiceMeeterRemote login failed"__ -

make sure Voicemeeter is running before the script starts
