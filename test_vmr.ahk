;#NoTrayIcon
#Persistent
#SingleInstance force
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ; Recommended for catching common errors.
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#UseHook
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.

OnExit("cleanup_before_exit")
SetFormat, Float, 0.3
global A2BusNum := "1"
global volLvlBusA2 = 0.0 ; initial value. maybe set in voicemeeter?
global VMR_FUNCTIONS := {}
global VMR_DLL_DRIVE := "C:"
global VMR_DLL_DIRPATH := "Program Files (x86)\VB\Voicemeeter"
global VMR_DLL_FILENAME_32 := "VoicemeeterRemote.dll"
global VMR_DLL_FILENAME_64 := "VoicemeeterRemote64.dll"
global VMR_DLL_FULL_PATH := VMR_DLL_DRIVE . "\" . VMR_DLL_DIRPATH . "\"
Sleep, 500
if (A_Is64bitOS) {
    VMR_DLL_FULL_PATH .= VMR_DLL_FILENAME_64
} else {
    VMR_DLL_FULL_PATH .= VMR_DLL_FILENAME_32
}

; == START OF EXECUTION ==
; ========================

; Load the VoicemeeterRemote DLL:
; This returns a module handle
global VMR_MODULE := DllCall("LoadLibrary", "Str", VMR_DLL_FULL_PATH, "Ptr")
if (ErrorLevel || VMR_MODULE == 0)
    die("Attempt to load VoiceMeeter Remote DLL failed.")

; Populate VMR_FUNCTIONS
add_vmr_function("Login")
add_vmr_function("Logout")
add_vmr_function("RunVoicemeeter")
add_vmr_function("SetParameterFloat")
add_vmr_function("GetParameterFloat")
add_vmr_function("IsParametersDirty")

; "Login" to Voicemeeter, by calling the function in the DLL named 'VBVMR_Login()'...
login_result := DllCall(VMR_FUNCTIONS["Login"], "Int")
if (ErrorLevel || login_result < 0)
    die("VoiceMeeter Remote login failed.")

; == HOTKEYS ==
; =============

;F3::
;    volLvlBusA2 += 1
;    adjustVolLvl()
;return
;
;F2::
;    volLvlBusA2 -= 1
;    adjustVolLvl()
;return

; == Functions ==
; ===============

;readVolLvl(){
;    DLLCall(VMR_FUNCTIONS["IsParametersDirty"])
;    statusLvlB0 = DllCall(VMR_FUNCTIONS["GetParameterFloat"], "AStr", "Bus[" . "0" . "].Gain", "Ptr", &volLvlB0, "Int")
;    if (statusLvlB0 < 0){
;        MsgBox, Error: %statusLvlB0%
;    } else {
;        SetFormat, Float, 0.3
;        MsgBox, %volLvlB0%
;    }
;}

adjustVolLvl() {
    if (volLvlBusA2 > 0.0){
        volLvlBusA2 = 0.0
    } else if (volLvlBusA2 < -60.0) {
        volLvlBusA2 = -60.0
    }
    DllCall(VMR_FUNCTIONS["SetParameterFloat"], "AStr", "Bus[" . A2BusNum . "].Gain", "Float", volLvlBusA2, "Int")
}

add_vmr_function(func_name) {
    VMR_FUNCTIONS[func_name] := DllCall("GetProcAddress", "Ptr", VMR_MODULE, "AStr", "VBVMR_" . func_name, "Ptr")
    if (ErrorLevel || VMR_FUNCTIONS[func_name] == 0)
        die("Failed to register VMR function " . func_name . ".")
}

cleanup_before_exit(exit_reason, exit_code) {
    DllCall(VMR_FUNCTIONS["Logout"], "Int")
    ; OnExit functions must return 0 to allow the app to exit.
return 0
}

die(die_string:="UNSPECIFIED FATAL ERROR.", exit_status:=254) {
    MsgBox 16, FATAL ERROR, %die_string%
ExitApp exit_status
}

GetAppVolume(PID)
{
    Local MasterVolume := ""

    IMMDeviceEnumerator := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
    DllCall(NumGet(NumGet(IMMDeviceEnumerator+0)+4*A_PtrSize), "UPtr", IMMDeviceEnumerator, "UInt", 0, "UInt", 1, "UPtrP", IMMDevice, "UInt")
    ObjRelease(IMMDeviceEnumerator)

    VarSetCapacity(GUID, 16)
    DllCall("Ole32.dll\CLSIDFromString", "Str", "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}", "UPtr", &GUID)
    DllCall(NumGet(NumGet(IMMDevice+0)+3*A_PtrSize), "UPtr", IMMDevice, "UPtr", &GUID, "UInt", 23, "UPtr", 0, "UPtrP", IAudioSessionManager2, "UInt")
    ObjRelease(IMMDevice)

    DllCall(NumGet(NumGet(IAudioSessionManager2+0)+5*A_PtrSize), "UPtr", IAudioSessionManager2, "UPtrP", IAudioSessionEnumerator, "UInt")
    ObjRelease(IAudioSessionManager2)

    DllCall(NumGet(NumGet(IAudioSessionEnumerator+0)+3*A_PtrSize), "UPtr", IAudioSessionEnumerator, "UIntP", SessionCount, "UInt")
    Loop % SessionCount
    {
        DllCall(NumGet(NumGet(IAudioSessionEnumerator+0)+4*A_PtrSize), "UPtr", IAudioSessionEnumerator, "Int", A_Index-1, "UPtrP", IAudioSessionControl, "UInt")
        IAudioSessionControl2 := ComObjQuery(IAudioSessionControl, "{BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D}")
        ObjRelease(IAudioSessionControl)

        DllCall(NumGet(NumGet(IAudioSessionControl2+0)+14*A_PtrSize), "UPtr", IAudioSessionControl2, "UIntP", currentProcessId, "UInt")
        If (PID == currentProcessId)
        {
            ISimpleAudioVolume := ComObjQuery(IAudioSessionControl2, "{87CE5498-68D6-44E5-9215-6DA47EF883D8}")
            DllCall(NumGet(NumGet(ISimpleAudioVolume+0)+4*A_PtrSize), "UPtr", ISimpleAudioVolume, "FloatP", MasterVolume, "UInt")
            ObjRelease(ISimpleAudioVolume)
        }
        ObjRelease(IAudioSessionControl2)
    }
    ObjRelease(IAudioSessionEnumerator)

Return Round(MasterVolume * 100)
}
