# ahk-svrvmr

## AutoHotkey SteamVR Voicemeeter-Remote (SVRVMR)

## by bradynp

---

### Dependencies

* AutoHotkey (latest version preferred)
* Vista Audio Library (included, but not my own work)

### Performance

The script makes an infrequent DLL call to get the volume level set in the SteamVR Dashboard.\
While adjusting the volume, it makes additional DLL calls to Voicemeeter.\
The script is to be launched *after* VR has completely loaded, and the Voicemeeter Audio Engine must be running.

### Adjustable Parameters

| Name               | Default Value                        | Type    | Range        | Description                                                    |
| :----------------- | :----------------------------------- | :------ | :----------- | :------------------------------------------------------------- |
| *HMD_Bus*          | "2"                                  | Integer | 0 to 7       | determines which Voicemeeter bus to use (output used by HMD)   |
| *VRActivePid*      | "vrserver.exe"                       | PID     |              | the process name whose mixer will be monitored                 |
| *busGain*          | 0.0                                  | Float   | -60.0 to 0.0 | output bus gain on startup (might be overridden)               |
| *gainCurve*        | 4.0                                  | Float   | ~3 to ~5     | *See the follwing equation:*                                   |
| *gainOffset*       | 1.0                                  | Float   | >= 0.0       | $Gain = Gain_{offset} - 60e ^ {-Curve * Input}$                |
| *Update_Period_ms* | 500                                  | Integer | >= 1         | dashboard volume slider check period                           |
| *VMR_DLL_DRIVE*    | "C:"                                 | String  |              | adjust only if you have a nonstandard voicemeeter installation |
| *VMR_DLL_DIRPATH*  | "Program Files (x86)\VB\Voicemeeter" | String  |              | adjust only if you have a nonstandard voicemeeter installation |

---

### Errors & Solutions

"No application volume interface":\
make sure SteamVR is running before the script starts

"VoiceMeeterRemote login failed":\
make sure Voicemeeter is running before the script starts
