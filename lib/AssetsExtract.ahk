AssetsExtract() {
	; _TO_BE_ADDED_
	global PROGRAM
	static 0 ; Bypass warning "local same as global" for var 0

	if (A_IsCompiled) {
		FileInstall_Cmds()
		Return
	}

;	File location
	installFile := A_ScriptDir "\FileInstall_Cmds.ahk"
	FileDelete,% installFile

;	Pass PROGRAM to file
	appendToFile .= ""
	.		"if (!A_IsCompiled && A_ScriptName = ""FileInstall_Cmds.ahk"") {"
	. "`n"	"	#Include %A_ScriptDir%/lib/Logs.ahk"
	. "`n"	"	#Include %A_ScriptDir%/lib/WindowsSettings.ahk"
	. "`n"	"	#Include %A_ScriptDir%/lib/third-party/Get_ResourceSize.ahk"
	. "`n"
	. "`n"	"	if (!PROGRAM)"
	. "`n"	"		PROGRAM := {}"
	. "`n"
	. "`n"	"	Loop, %0% {"
	. "`n"	"		paramAE := `%A_Index`%"
	. "`n"	"		if RegExMatch(paramAE, ""O)/(.*)=(.*)"", foundAE)"
	. "`n"	"			PROGRAM[foundAE.1] := foundAE.2"
	. "`n"	"	}"
	. "`n"
	. "`n"	"	FileInstall_Cmds()"
	. "`n"	"}"
	. "`n"	"; --------------------------------"
	. "`n"
	. "`n"


	appendToFile .= ""
	. 		"FileInstall_Cmds() {"
	. "`n"	"global PROGRAM"
	. "`n"
	. "`n"
	. "`n"	"if !(PROGRAM.MAIN_FOLDER) {"
	. "`n" 	"	Msgbox You cannot run this file manually!"
	. "`n"	"ExitApp"
	. "`n"	"}"
	. "`n"
	. "`n"

;	- - - - LINK SHORTCUTS
	filePath := "GitHub.url"
	appendToFile .= FileInstall("""" filePath """", "PROGRAM.MAIN_FOLDER """ "\" "GitHub.url" """", 2)

;	- - - - RESOURCES
	allowedFiles := "changelog.txt,icon.ico,changelog_beta.txt"
	Loop, Files,% A_ScriptDir "\resources\*"
	{
		RegExMatch(A_LoopFileFullPath, "O)\\resources\\(.*)", path)
		filePath := "resources\" path.1

		if (IsIn(A_LoopFileName, allowedFiles))
			appendToFile .= FileInstall("""" filePath """", "PROGRAM.MAIN_FOLDER """ "\" A_LoopFileName """", 2)
	}

	; - - - - 
	appendToFile .= ""
	. "`n"	
	. "`n"	"if (errorLog)"
	. "`n"	"	MsgBox, 4096, POE Trade Instant Whisper,% ""One or multiple files failed to be extracted. Please check the logs file for details."""
	. "`n"	"	.	PROGRAM.LOGS_FILE "
	. "`n"
	. "`n"	"}"

;	ADD TO FILE
	FileAppend,% appendToFile "`n",% installFile
	Sleep 10

/*	No longer required. Was only ran if the script is uncompiled. But assets are now being loaded from the AHK folder itself, instead of being extracted into the "main folder"
	; https://autohotkey.com/board/topic/6717-how-to-find-autohotkey-directory/
	cl := DllCall( "GetCommandLine", "str" )
	StringMid, path_AHk, cl, 2, InStr( cl, """", true, 2 )-2

	installFile_run_cmd := % """" path_AHk """" " /r " """" installFile """"
	.		" /MAIN_FOLDER=" 			"""" PROGRAM.MAIN_FOLDER """"
	.		" /SFX_FOLDER=" 			"""" PROGRAM.SFX_FOLDER """"
	.		" /LOGS_FOLDER=" 			"""" PROGRAM.LOGS_FOLDER """"
	.		" /SKINS_FOLDER=" 			"""" PROGRAM.SKINS_FOLDER """"
	.		" /FONTS_FOLDER=" 			"""" PROGRAM.FONTS_FOLDER """"
	.		" /IMAGES_FOLDER=" 			"""" PROGRAM.IMAGES_FOLDER """"
	.		" /DATA_FOLDER=" 			"""" PROGRAM.DATA_FOLDER """"
	.		" /ICONS_FOLDER=" 			"""" PROGRAM.ICONS_FOLDER """"
	. 		" /TEMP_FOLDER="			"""" PROGRAM.TEMP_FOLDER """"
	. 		" /TRANSLATIONS_FOLDER="	"""" PROGRAM.TRANSLATIONS_FOLDER """"
	. 		" /CURRENCY_IMGS_FOLDER="	"""" PROGRAM.CURRENCY_IMGS_FOLDER """"
	. 		" /CHEATSHEETS_FOLDER="		"""" PROGRAM.CHEATSHEETS_FOLDER """"
	.		" /LOGS_FILE="				"""" PROGRAM.LOGS_FILE """"

	RunWait,% installFile_run_cmd,% A_ScriptDir
	*/
}