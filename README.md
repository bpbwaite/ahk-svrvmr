# ahk-svrvmr

## AutoHotkey SteamVR Voicemeeter-Remote (SVRVMR)

---

### Dependencies

* AutoHotkey (latest version preferred)
* Vista Audio Library (included, but not my own work)

### Performance

The script makes DLL calls to get the volume level set by the SteamVR Dashboard.\
While adjusting the volume, it makes additional DLL calls to Voicemeeter.\
The Voicemeeter Audio Engine must be running.

### Adjustable Parameters

| Name               | Default Value                        | Type    | Range        | Description                                                    |
| :----------------- | :----------------------------------- | :------ | :----------- | :------------------------------------------------------------- |
| *HMD_Bus*          | "2"                                  | Integer | 0 to 7       | determines which Voicemeeter bus to use (output used by HMD)   |
| *busGain*          | 0.0                                  | Float   | -60.0 to 0.0 | output bus gain on startup (might be overridden)               |
| *gainCurve*        | 4.0                                  | Float   | ~3 to ~5     |                                                                |
| *gainOffset*       | 1.0                                  | Float   | >= 0.0       |                                                                |
| *Update_Period_ms* | 100                                  | Integer | >= 1         | volume slider check period                                     |
| *VMR_DLL_DRIVE*    | "C:"                                 | String  |              | adjust only if you have a nonstandard voicemeeter installation |
| *VMR_DLL_DIRPATH*  | "Program Files (x86)\VB\Voicemeeter" | String  |              | adjust only if you have a nonstandard voicemeeter installation |

---

### Errors & Solutions

"VoiceMeeterRemote login failed":\
make sure Voicemeeter is running before the script starts
