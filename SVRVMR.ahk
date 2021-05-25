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
; Populate VMR_FUNCTIONS
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
    ;ObjRelease(Volume) ; DEPRECATED
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
; extensions of VA_, required for application specific control, ALL DEPRECATED
;GetVolumeObject(Param = 0)
;{
;    static IID_IASM2 := "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}"
;    , IID_IASC2 := "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
;    , IID_ISAV := "{87CE5498-68D6-44E5-9215-6DA47EF883D8}"
;
;    if Param is not Integer
;    {
;        Process, Exist, %Param%
;        Param := ErrorLevel
;    }
;    DAE := VA_GetDevice()
;    VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)
;    VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
;    VA_IAudioSessionEnumerator_GetCount(IASE, Count)
;    Loop, % Count
;    {
;        VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)
;        IASC2 := ComObjQuery(IASC, IID_IASC2)
;        ObjRelease(IASC)
;        VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)
;        if (SPID == Param)
;        {
;            ISAV := ComObjQuery(IASC2, IID_ISAV)
;            ObjRelease(IASC2)
;            break
;        }
;        ObjRelease(IASC2)
;    }
;    ObjRelease(IASE)
;    ObjRelease(IASM2)
;    ObjRelease(DAE)
;return ISAV
;}
;VA_ISimpleAudioVolume_SetMasterVolume(this, ByRef fLevel, GuidEventContext="") {
;return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "float", fLevel, "ptr", VA_GUID(GuidEventContext))
;}
;VA_ISimpleAudioVolume_GetMasterVolume(this, ByRef fLevel) {
;return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "float*", fLevel)
;}
;VA_ISimpleAudioVolume_SetMute(this, ByRef Muted, GuidEventContext="") {
;return DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "int", Muted, "ptr", VA_GUID(GuidEventContext))
;}
;VA_ISimpleAudioVolume_GetMute(this, ByRef Muted) {
;return DllCall(NumGet(NumGet(this+0)+6*A_PtrSize), "ptr", this, "int*", Muted)
;}
