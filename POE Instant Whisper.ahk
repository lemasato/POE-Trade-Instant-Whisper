/*		POETrade/POEApp Instant Whisper       
		Instantly send a poe.trade or poeapp.com whisper upon copy
		https://github.com/lemasato

		HowTo: Hold down the CTRL key, click on "Whisper" from poe.trade.
		Some settings may be changed in the Start_Script() function.
*/

#Warn LocalSameAsGlobal, StdOut
#SingleInstance, Off
#KeyHistory 0
#NoTrayIcon
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
Menu,Tray,Tip,POE Instant Whisper
Menu,Tray,NoStandard
Menu,Tray,Add,Reload,Reload
Menu,Tray,Add,Close,Exit
Menu,Tray,Icon

Start_Script()
Return

~*Space:: ; Cancel auto-whisper
	global WAIT_MODIFIER_UP, CANCEL_WHISPER, SPACEBAR_WAIT

	if (SPACEBAR_WAIT) {
		SplashTextOff()
	}
	else if (WAIT_MODIFIER_UP) {
		CANCEL_WHISPER := True
		ShowToolTip("Instant whisper successfully canceled.", 3000)
	}
Return

Start_Script() {
	global PROGRAM 							:= {} ; Specific to the program's informations
	global GAME								:= {} ; Specific to the game config files
	global RUNTIME_PARAMETERS 				:= {}

	Handle_CmdLineParameters() 		; PROGRAM.RUNTIME_PARAMETERS

	MyDocuments 					:= (PROGRAM.RUNTIME_PARAMETERS.MyDocuments)?(PROGRAM.RUNTIME_PARAMETERS.MyDocuments):(A_MyDocuments)

	; Set global - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	PROGRAM.NAME					:= "POE Instant Whisper"
	PROGRAM.VERSION 				:= "0.1"

	PROGRAM.GITHUB_USER 			:= "lemasato"
	PROGRAM.GITHUB_REPO 			:= "POETrade-Instant-Whisper"
	PROGRAM.GUTHUB_BRANCH			:= "master"

	PROGRAM.MAIN_FOLDER 			:= MyDocuments "\AutoHotkey\lemasato\" PROGRAM.NAME
	PROGRAM.LOGS_FOLDER 			:= PROGRAM.MAIN_FOLDER "\Logs"

	PROGRAM.INI_FILE 				:= PROGRAM.MAIN_FOLDER "\Preferences.ini"
	PROGRAM.LOGS_FILE 				:= PROGRAM.LOGS_FOLDER "\" A_YYYY "-" A_MM "-" A_DD " " A_Hour "h" A_Min "m" A_Sec "s.txt"
	PROGRAM.CHANGELOG_FILE 			:= PROGRAM.LOGS_FOLDER "\changelog.txt"

	PROGRAM.NEW_FILENAME			:= PROGRAM.MAIN_FOLDER "\POE-IW-NewVersion.exe"
	PROGRAM.UPDATER_FILENAME 		:= PROGRAM.MAIN_FOLDER "\POE-IW-Updater.exe"
	PROGRAM.LINK_UPDATER 			:= "https://raw.githubusercontent.com/" PROGRAM.GITHUB_USER "/" PROGRAM.GITHUB_REPO "/" PROGRAM.GUTHUB_BRANCH "/Updater_v2.exe"
	PROGRAM.LINK_CHANGELOG 			:= "https://raw.githubusercontent.com/" PROGRAM.GITHUB_USER "/" PROGRAM.GITHUB_REPO "/" PROGRAM.GUTHUB_BRANCH "/resources/changelog.txt"

	PROGRAM.LINK_REDDIT 			:= "https://redd.it/57oo3h"
	PROGRAM.LINK_GITHUB 			:= "https://github.com/" PROGRAM.GITHUB_USER "/" PROGRAM.GITHUB_REPO

	GAME.MAIN_FOLDER 				:= MyDocuments "\my games\Path of Exile"
	GAME.INI_FILE 					:= GAME.MAIN_FOLDER "\production_Config.ini"
	GAME.INI_FILE_COPY 		 		:= PROGRAM.MAIN_FOLDER "\production_Config.ini"
	GAME.EXECUTABLES 				:= "PathOfExile.exe,PathOfExile_x64.exe,PathOfExileSteam.exe,PathOfExile_x64Steam.exe"

	PROGRAM.SETTINGS := {}
	PROGRAM.SETTINGS.WHISPERS_MAX_HISTORY		:= 10 ; Prevent sending the same whisper multiple times. Also in case something modifies the clipboard.
	PROGRAM.SETTINGS.MODIFIER_KEY_ENABLE 		:= True ; Enable = need to hold down a specific key to send whisper. False = no need to hold down any key.
	PROGRAM.SETTINGS.MODIFIER_KEY_VK 			:= "0x11" ; CTRL - If holding down this key when clicking on poe.trade "Whisper" link, instantly send msg in game.

	PROGRAM.PID 					:= DllCall("GetCurrentProcessId")

	SetWorkingDir,% PROGRAM.MAIN_FOLDER

	; Auto admin reload - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	if (!A_IsAdmin) {
		; GUI_SimpleWarn.Show("", "Reloading to request admin privilieges in 3...`nClick on this window to reload now.", "Green", "White", {CountDown:True, CountDown_Timer:1000, CountDown_Count:3, WaitClose:1, CloseOnClick:True})
		ReloadWithParams("", True, True)
	}

	; Game executables groups - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe"]
	global POEGameList := "PathOfExile.exe,PathOfExile_x64.exe,PathOfExileSteam.exe,PathOfExile_x64Steam.exe"

	for nothing, executable in POEGameArr {
		GroupAdd, POEGameGroup, ahk_exe %executable%
	}

	; Create local directories - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	directories := PROGRAM.MAIN_FOLDER

	Loop, Parse, directories, `n, `r
	{
		if (!InStr(FileExist(A_LoopField), "D")) {
			FileCreateDir, % A_LoopField ; Create directory prior to adding to logs. In case logs folder doesnt exist yet
			errorLvl := ErrorLevel, lastError := A_LastError 
			AppendtoLogs("Local directory non-existent. Creating: """ A_LoopField """")
			if (errorLvl && lastError) {
				AppendtoLogs("Failed to create local directory. System Error Code: " lastError ". Path: """ A_LoopField """")
			}
		}
	}

	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Close_PreviousInstance()
	TrayRefresh()

	; Local settings
	Set_LocalSettings()
	Update_LocalSettings()
	localSettings := Get_LocalSettings()
	Declare_LocalSettings(localSettings)

	; Game settings
	gameSettings := Get_GameSettings()
	Declare_GameSettings(gameSettings)

	; Logs files
	Create_LogsFile()
	Delete_OldLogsFile()

	; UpdateCheck(1,1)

	Create_TrayMenu()
	ShellMessage_Enable()
	OnClipboardChange("OnClipboardChange_Func")
}
return

/*	*		*		*		*		*		*		*		*		*		*		*		*		*
*		*		*		*		*		*		TOOLTIP 		*		*		*		*		*		*
/	*		*		*		*		*		*		*		*		*		*		*		*		*
*/

ShowToolTip(str, removeTimer="") {
	SetTimer, RemoveToolTip, Delete

	ToolTip,
	ToolTip,% str
	if (removeTimer)
		SetTimer, RemoveToolTip, -%removeTimer%
}

RemoveToolTip() {
	ToolTip,
}


#Include %A_ScriptDir%/lib
#Include Class_GUI.ahk
#Include Class_GUI_SimpleWarn.ahk
#Include Class_INI.ahk
#Include CmdLineParameters.ahk
#Include EasyFuncs.ahk
#Include Exit.ahk
#Include Game.ahk
#Include Game_File.ahk
#Include GitHubReleasesAPI.ahk
#Include Local_File.ahk
#Include Logs_File.ahk
#Include OnClipboardChange.ahk
#Include Reload.ahk
#Include ShellMessage.ahk
#Include SplashText.ahk
#Include TrayMenu.ahk
#Include TrayRefresh.ahk
#Include UpdateCheck.ahk

#Include %A_ScriptDir%/lib/third-party/
#Include Clip.ahk
#Include Download.ahk
#Include Get_ProcessInfos.ahk
#Include JSON.ahk
#Include StringtoHex.ahk
