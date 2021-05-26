#Include VA.ahk
; required library.
#Persistent
#SingleInstance, Force
#NoEnv
#KeyHistory 0
#UseHook
;#NoTrayIcon
ListLines Off
SetBatchLines, -1
SendMode Input
OnExit("cleanup_before_exit")

; ****** USER ADJUSTABLE PARAMETERS ****** ;

global HMD_Bus := "2"
;global VRActivePid := "vrwebhelper.exe" ; DEPRECATED
global busGain = 0.0
global gainCurve = 4.0
global gainOffset = 1.0
global Update_Period_ms := 100
global VMR_DLL_DRIVE := "C:"
global VMR_DLL_DIRPATH := "Program Files (x86)\VB\Voicemeeter"

; ****** END USER ADJUSTABLE PARAMETERS ****** ;

global VMR_DLL_FILENAME_32 := "VoicemeeterRemote.dll"
global VMR_DLL_FILENAME_64 := "VoicemeeterRemote64.dll"
global VMR_FUNCTIONS := {}
global VMR_DLL_FULL_PATH := VMR_DLL_DRIVE . "\" . VMR_DLL_DIRPATH . "\"
if (A_Is64bitOS) {
    VMR_DLL_FULL_PATH .= VMR_DLL_FILENAME_64
} else {
    VMR_DLL_FULL_PATH .= VMR_DLL_FILENAME_32
}

;global Volume := GetVolumeObject(VRActivePid) ; DEPRECATED
;if !(Volume)
;    die("No application volume interface")

global VMR_MODULE := DllCall("LoadLibrary", "Str", VMR_DLL_FULL_PATH, "Ptr")

add_vmr_function("Login")
add_vmr_function("Logout")
add_vmr_function("RunVoicemeeter")
add_vmr_function("SetParameterFloat")
add_vmr_function("GetParameterFloat")
add_vmr_function("IsParametersDirty")

login_result := DllCall(VMR_FUNCTIONS["Login"], "Int")
if (ErrorLevel || login_result < 0)
    die("VoiceMeeterRemote login failed")

SetTimer, updatelabel, %Update_Period_ms%
updatelabel:
    UpdateFunc()
return
;
;
; functions
;
;
UpdateFunc(vol_obj := 0) {
    static last := 1.0
    ;VA_ISimpleAudioVolume_GetMasterVolume(vol_obj, gainbuffer) ; DEPRECATED
    gainbuffer := VA_GetMasterVolume() / 100.0
    busGain := gainOffset + -60.0 * exp(-1.0 * gainCurve * gainbuffer)
    if (busGain != last){
        adjustVolLvl()
        last := busGain
    }
return
}
cleanup_before_exit(exit_reason, exit_code) {
    DllCall(VMR_FUNCTIONS["Logout"], "Int")
return 0
}
die(die_string:="UNSPECIFIED FATAL ERROR", exit_status:=254) {
    MsgBox 16, FATAL ERROR, %die_string%
ExitApp exit_status
}
adjustVolLvl() {
    if (busGain > 0.0){
        busGain = 0.0
    } else if (busGain < -60.0) {
        busGain = -60.0
    }
    DllCall(VMR_FUNCTIONS["SetParameterFloat"], "AStr", "Bus[" . HMD_Bus . "].Gain", "Float", busGain, "Int")
}
add_vmr_function(func_name) {
    VMR_FUNCTIONS[func_name] := DllCall("GetProcAddress", "Ptr", VMR_MODULE, "AStr", "VBVMR_" . func_name, "Ptr")
}
