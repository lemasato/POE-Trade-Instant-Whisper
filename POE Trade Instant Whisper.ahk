/*
*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
*					POE Trade Instant Whisper																														*
*					Instantly send a poe.trade or poeapp.com whisper when holding CTRL upon copy															*
*																																								*
*					https://github.com/lemasato/POE-Trade-Instant-Whisper/																							*
*																																								*	
*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
*/

; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

; #Warn LocalSameAsGlobal, StdOut
; #ErrorStdOut
#SingleInstance, Off
#KeyHistory 0
#Persistent
#NoEnv

OnExit("Exit")

DetectHiddenWindows, Off
FileEncoding, UTF-8 ; Cyrilic characters
SetWinDelay, 0
ListLines, Off

; Basic tray menu
if ( !A_IsCompiled && FileExist(A_ScriptDir "\resources\icon.ico") )
	Menu, Tray, Icon, %A_ScriptDir%\resources\icon.ico
Menu,Tray,Tip,POE Trade Instant Whisper
Menu,Tray,NoStandard
Menu,Tray,Add,Tool is loading..., DoNothing
Menu,Tray,Disable,Tool is loading...
Menu,Tray,Add,GitHub,Tray_GitHub
Menu,Tray,Add
Menu,Tray,Add,Reload,Tray_Reload
Menu,Tray,Add,Close,Tray_Exit
Menu,Tray,Icon
; Left click
OnMessage(0x404, "AHK_NOTIFYICON") 

Hotkey, IfWinActive
Hotkey, ~*Space, SpaceRoutine

if (!A_IsUnicode) {
	MsgBox(4096+48, "POE Instant Whisper", "This tool does not support ANSI versions of AutoHotKey."
	. "`nPlease download and install AutoHotKey Unicode 32/64 or use the compiled executable."
	. "`nAutoHotKey's official website will open upon closing this box.")
	Run,% "https://www.autohotkey.com/"
	ExitApp
}

; try {
	Start_Script()
; }
; catch e {
; 	MsgBox, 16,, % "Exception thrown!`n`nwhat: " e.what "`nfile: " e.file
;         . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
; }
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
SpaceRoutine() {
	global PROGRAM, AUTOWHISPER_CANCEL, AUTOWHISPER_WAITKEYUP

	if (AUTOWHISPER_WAITKEYUP) {
		AUTOWHISPER_CANCEL := True
		ShowToolTip(PROGRAM.NAME "`nEasy whisper canceled.")
	}
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Start_Script() {

	global DEBUG 							:= {} ; Debug values
	global PROGRAM 							:= {} ; Specific to the program's informations
	global GAME								:= {} ; Specific to the game config files
	global RUNTIME_PARAMETERS 				:= {}

	global MyDocuments

	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Handle_CmdLineParameters() 		; RUNTIME_PARAMETERS
	Load_DebugJSON()

	MyDocuments 					:= (RUNTIME_PARAMETERS.MyDocuments)?(RUNTIME_PARAMETERS.MyDocuments):(A_MyDocuments)

	; Set global - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	PROGRAM.NAME					:= "POE Trade Instant Whisper"
	PROGRAM.VERSION 				:= "0.2"
	PROGRAM.IS_BETA					:= IsContaining(PROGRAM.VERSION, "beta")?"True":"False"

	PROGRAM.GITHUB_USER 			:= "lemasato"
	PROGRAM.GITHUB_REPO 			:= "POE-Trade-Instant-Whisper"
	PROGRAM.GUTHUB_BRANCH			:= "master"

	PROGRAM.MAIN_FOLDER 			:= MyDocuments "\lemasato\" PROGRAM.NAME
	PROGRAM.LOGS_FOLDER 			:= PROGRAM.MAIN_FOLDER "\Logs"
	PROGRAM.TEMP_FOLDER 			:= PROGRAM.MAIN_FOLDER "\Temp"

	prefsFileName 					:= (RUNTIME_PARAMETERS.InstanceName)?(RUNTIME_PARAMETERS.InstanceName "_Preferences.ini"):("Preferences.ini")
	PROGRAM.INI_FILE 				:= PROGRAM.MAIN_FOLDER "\" prefsFileName
	PROGRAM.LOGS_FILE 				:= PROGRAM.LOGS_FOLDER "\" A_YYYY "-" A_MM "-" A_DD " " A_Hour "h" A_Min "m" A_Sec "s.txt"
	PROGRAM.CHANGELOG_FILE 			:= (A_IsCompiled?PROGRAM.MAIN_FOLDER:A_ScriptDir) . (A_IsCompiled?"\changelog.txt":"\resources\changelog.txt")
	PROGRAM.CHANGELOG_FILE_BETA 	:= (A_IsCompiled?PROGRAM.MAIN_FOLDER:A_ScriptDir) . (A_IsCompiled?"\changelog_beta.txt":"\resources\changelog_beta.txt")
	PROGRAM.ICON_FILE 				:= (A_IsCompiled?PROGRAM.MAIN_FOLDER:A_ScriptDir) . (A_IsCompiled?"\icon.ico":"\resources\icon.ico")
	
	PROGRAM.NEW_FILENAME			:= PROGRAM.MAIN_FOLDER "\POE-IW-NewVersion.exe"
	PROGRAM.UPDATER_FILENAME 		:= PROGRAM.MAIN_FOLDER "\POE-IW-Updater.exe"
	PROGRAM.LINK_UPDATER 			:= "https://raw.githubusercontent.com/lemasato/POE-Trade-Instant-Whisper/master/Updater_v2.exe"
	PROGRAM.LINK_CHANGELOG 			:= "https://raw.githubusercontent.com/lemasato/POE-Trade-Instant-Whisper/master/resources/changelog.txt"

	PROGRAM.LINK_REDDIT 			:= "https://www.reddit.com/user/lemasato/submitted/"
	PROGRAM.LINK_GITHUB 			:= "https://github.com/lemasato/POE-Trade-Instant-Whisper"
	PROGRAM.LINK_SUPPORT 			:= "https://www.paypal.me/masato/"
	PROGRAM.LINK_DISCORD 			:= "https://discord.gg/UMxqtfC"

	GAME.MAIN_FOLDER 				:= MyDocuments "\my games\Path of Exile"
	GAME.INI_FILE 					:= GAME.MAIN_FOLDER "\production_Config.ini"
	GAME.INI_FILE_COPY 		 		:= PROGRAM.MAIN_FOLDER "\production_Config.ini"
	GAME.EXECUTABLES 				:= "PathOfExile.exe,PathOfExile_x64.exe,PathOfExileSteam.exe,PathOfExile_x64Steam.exe,PathOfExile_KG.exe,PathOfExile_x64_KG.exe"

	PROGRAM.PID 					:= DllCall("GetCurrentProcessId")

	SetWorkingDir,% PROGRAM.MAIN_FOLDER

	; Auto admin reload - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if (!A_IsAdmin && !RUNTIME_PARAMETERS.SkipAdmin && !DEBUG.SETTINGS.skip_admin) {
		ReloadWithParams(" /MyDocuments=""" MyDocuments """", getCurrentParams:=True, asAdmin:=True)
	}

	; Game executables groups - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]

	global POEGameList := ""
	for nothing, executable in POEGameArr {
		GroupAdd, POEGameGroup, ahk_exe %executable%
		POEGameList .= executable ","
	}
	StringTrimRight, POEGameList, POEGameList, 1

	; Create local directories - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	directories := PROGRAM.MAIN_FOLDER "`n" PROGRAM.LOGS_FOLDER "`n" PROGRAM.TEMP_FOLDER

	Loop, Parse, directories, `n, `r
	{
		if (!InStr(FileExist(A_LoopField), "D")) {
			AppendtoLogs("Local directory non-existent. Creating: """ A_LoopField """")
			FileCreateDir, % A_LoopField
			if (ErrorLevel && A_LastError) {
				AppendtoLogs("Failed to create local directory. System Error Code: " A_LastError ". Path: """ A_LoopField """")
			}
		}
	}

	; Logs files
	Create_LogsFile()
	Delete_OldLogsFile()

	if (!RUNTIME_PARAMETERS.NewInstance)
		Close_PreviousInstance()
	TrayRefresh()

	if !(DEBUG.settings.skip_assets_extracting)
		AssetsExtract()

	; Local settings
	LocalSettings_VerifyEncoding()
	Set_LocalSettings()
	Update_LocalSettings()
	localSettings := Get_LocalSettings()
	Declare_LocalSettings(localSettings)

	; Game settings
	gameSettings := Get_GameSettings()
	Declare_GameSettings(gameSettings)

	; Update checking
	if !(DEBUG.settings.skip_update_check) {
		periodicUpdChk := PROGRAM.SETTINGS.UPDATE.CheckForUpdatePeriodically
		updChkTimer := (periodicUpdChk="OnStartOnly")?(0)
			: (periodicUpdChk="OnStartAndEveryFiveHours")?(18000000)
			: (periodicUpdChk="OnStartAndEveryDay")?(86400000)
			: (0)
		
		if (updChkTimer)
			SetTimer, UpdateCheck, %updChkTimer%

		if (DEBUG.settings.force_update_check)
			UpdateCheck(checkType:="forced")
		else {
			if (A_IsCompiled)
				UpdateCheck(checktype:="on_start")
			else
				UpdateCheck(checkType:="on_start", "box")
		}
	}

	TrayMenu()
	
	ShellMessage_Enable()
	OnClipboardChange("OnClipboardChange_Func")

	trayMsg := "Hold CTRL while copying a whisper to instantly send in to the last activated game window."
	TrayNotifications.Show(PROGRAM.NAME, trayMsg)
}

DoNothing:
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#Include %A_ScriptDir%\lib\

#Include Class_GUI.ahk
#Include Class_GUI_SimpleWarn.ahk

#Include AssetsExtract.ahk
#Include Class_INI.ahk
#Include CmdLineParameters.ahk
#Include Debug.ahk
#Include EasyFuncs.ahk
#Include Exit.ahk
#Include FileInstall.ahk
#Include Game.ahk
#Include Game_File.ahk
#Include GitHubAPI.ahk
#Include Local_File.ahk
#Include Logs.ahk
#Include Misc.ahk
#Include OnClipboardChange.ahk
#Include Reload.ahk
#Include ShellMessage.ahk
#Include ShowToolTip.ahk
#Include TrayMenu.ahk
#Include TrayNotifications.ahk
#Include TrayRefresh.ahk
#Include Updating.ahk
#Include WindowsSettings.ahk

#Include %A_ScriptDir%\lib\third-party\
#Include Download.ahk
#Include Extract2Folder.ahk
#Include JSON.ahk
#Include Get_ProcessInfos.ahk
#Include StringToHex.ahk
#Include WinHttpRequest.ahk


if (A_IsCompiled) {
	#Include %A_ScriptDir%/FileInstall_Cmds.ahk
	Return
}
