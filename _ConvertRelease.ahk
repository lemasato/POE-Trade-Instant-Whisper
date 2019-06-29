#SingleInstance, Force
#NoEnv

if (!A_IsAdmin) {
	ReloadWithParams("", getCurrentParams:=True, asAdmin:=True)
}

; Basic tray menu
if ( !A_IsCompiled && FileExist(A_ScriptDir "\resources\icon.ico") )
	Menu, Tray, Icon, %A_ScriptDir%\resources\icon.ico
Menu,Tray,Tip,POE Trade Instant Whisper - Converting release
Menu,Tray,NoStandard
Menu,Tray,Add,Close,Tray_Close
Menu,Tray,Icon

; Main file
FileRead, ver,%A_ScriptDir%/resources/version.txt ; Get ver from txt
ver := StrReplace(ver, "`n", "") ; Remove any possible linebreak
ver = %ver% ; Auto trim
ver := RegExReplace(ver, "[a-zA-Z]") ; Remove any possible alpha char
ver := StrReplace(ver, "_", "99.") ; If _ detected (beta), use 99 as ver
StringReplace ver,ver,`.,`.,UseErrorLevel

; Main executable
ToolTip, Compiling POE Trade Instant Whisper.exe
CompileFile(A_ScriptDir "\POE Trade Instant Whisper.ahk", A_ScriptDir "\POE Trade Instant Whisper.exe")
; CompileFile(A_ScriptDir "\POE Trades Companion.ahk", A_ScriptDir "\POE Trades Companion.exe", "POE Trades Companion", ver, "© lemasato.github.io " A_YYYY)

; Updater file 
; ToolTip, Compiling Updater.exe
; CompileFile(A_ScriptDir "\Updater.ahk", A_ScriptDir "\Updater.exe")
; CompileFile(A_ScriptDir "\Updater.ahk", A_ScriptDir "\Updater.exe", "POE Trades Companion: Updater", "1.0", "© lemasato.github.io " A_YYYY)

; Updater file v2
; ToolTip, Updater_v2.exe
; CompileFile(A_ScriptDir "\Updater_v2.ahk", A_ScriptDir "\Updater_v2.exe")
; CompileFile(A_ScriptDir "\Updater_v2.ahk", A_ScriptDir "\Updater_v2.exe", "POE Trades Companion: Updater", "2.1", "© lemasato.github.io " A_YYYY)


; End
SoundPlay, *32
ToolTip, Compile Success
Sleep 1500
ToolTip
ExitApp
Return

; - - - - - - - - - -

Esc::ExitApp

Tray_Close:
ExitApp
Return

CompileFile(source, dest, fileDesc="NONE", fileVer="NONE", fileCopyright="NONE") {
    Run_Ahk2Exe(source, ,A_ScriptDir "\resources\icon.ico")

	if (fileDesc != "NONE" || fileVer != "NONE" || fileCopyright != "NONE") {
		StringReplace fileVer,fileVer,`.,`.,UseErrorLevel
		Loop % 3-ErrorLevel {
			fileVer .= ".0"
		}

		Set_FileInfos(dest, fileVer, fileDesc, fileCopyright)
		destVer := FGP_Value(dest, 167) ; 167 = Ver
		destDesc := FGP_Value(dest, 34) ; 34 = Desc
		destCpyR := FGP_Value(dest, 25) ; 25 = Copyright
		while (destVer != fileVer) {
			ToolTip,% "Attempt #" A_Index+1
			.   "`nFailed to set file infos."
			.   "`nFile: " dest
			.   "`n"
			.   "`nFile Version: " fileVer 
			.   "`nCurrent: " destVer
			.   "`n"
			.   "`nFile Description: " fileDesc 
			.   "`nCurrent: " destDesc
			.   "`n"
			.   "`nCopyright: " fileCopyright
			.   "`nCurrent: " destCpyR
			Set_FileInfos(dest, fileVer, fileDesc, fileCopyright)
			Sleep 500
			destVer := FGP_Value(dest, 167) ; 167 = Ver
		}
		ToolTip,
		fileInfos := ""
	}
}

ReloadWithParams(params, getCurrentParams=False, asAdmin=False) {
	if (getCurrentParams) {
		params .= " " Get_CmdLineParameters()
	}

	if (asAdmin)
		runMode := "RunAs"
	else runMode := ""

	Sleep 10
	DllCall("shell32\ShellExecute" (A_IsUnicode ? "":"A"),uint,0,str,runMode,str,(A_IsCompiled ? A_ScriptFullPath
	: A_AhkPath),str,(A_IsCompiled ? "": """" . A_ScriptFullPath . """" . A_Space) params,str,A_WorkingDir,int,1)
	ExitApp
	Sleep 10000
}

#Include %A_ScriptDir%\lib\
#Include CmdLineParameters.ahk
#Include CompileAhk2Exe.ahk
#Include EasyFuncs.ahk
#Include SetFileInfos.ahk
#Include WindowsSettings.ahk

#Include %A_ScriptDir%\lib\third-party\
#Include FGP.ahk
