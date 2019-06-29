if (!A_IsCompiled && A_ScriptName = "FileInstall_Cmds.ahk") {
	#Include %A_ScriptDir%/lib/Logs.ahk
	#Include %A_ScriptDir%/lib/WindowsSettings.ahk
	#Include %A_ScriptDir%/lib/third-party/Get_ResourceSize.ahk

	if (!PROGRAM)
		PROGRAM := {}

	Loop, %0% {
		paramAE := %A_Index%
		if RegExMatch(paramAE, "O)/(.*)=(.*)", foundAE)
			PROGRAM[foundAE.1] := foundAE.2
	}

	FileInstall_Cmds()
}
; --------------------------------

FileInstall_Cmds() {
global PROGRAM


if !(PROGRAM.MAIN_FOLDER) {
	Msgbox You cannot run this file manually!
ExitApp
}

if !InStr(FileExist(PROGRAM.MAIN_FOLDER ""), "D")
	FileCreateDir,% PROGRAM.MAIN_FOLDER ""

if (A_IsCompiled) {
	sourceFileSize := Get_ResourceSize("GitHub.url")
	FileGetSize, destFileSize, % PROGRAM.MAIN_FOLDER "\GitHub.url"
}
else {
	FileGetSize, sourceFileSize, GitHub.url
	FileGetSize, destFileSize, % PROGRAM.MAIN_FOLDER "\GitHub.url"
}
if (sourceFileSize != destFileSize)
	FileInstall, GitHub.url, % PROGRAM.MAIN_FOLDER "\GitHub.url", 1
if (ErrorLevel) {
	AppendToLogs("Failed to extract file!"
	.	"`nSource: GitHub.url"
	.	"`nDest: " PROGRAM.MAIN_FOLDER "\GitHub.url"
	.	"`nFlag: " 2)
	errorLog .= "`n`n""Failed to extract file!"
	.	"`nSource: GitHub.url"
	.	"`nDest: " PROGRAM.MAIN_FOLDER "\GitHub.url"
	.	"`nFlag: " 2
}

; ----------------------------
if !InStr(FileExist(PROGRAM.MAIN_FOLDER ""), "D")
	FileCreateDir,% PROGRAM.MAIN_FOLDER ""

if (A_IsCompiled) {
	sourceFileSize := Get_ResourceSize("resources\changelog.txt")
	FileGetSize, destFileSize, % PROGRAM.MAIN_FOLDER "\changelog.txt"
}
else {
	FileGetSize, sourceFileSize, resources\changelog.txt
	FileGetSize, destFileSize, % PROGRAM.MAIN_FOLDER "\changelog.txt"
}
if (sourceFileSize != destFileSize)
	FileInstall, resources\changelog.txt, % PROGRAM.MAIN_FOLDER "\changelog.txt", 1
if (ErrorLevel) {
	AppendToLogs("Failed to extract file!"
	.	"`nSource: resources\changelog.txt"
	.	"`nDest: " PROGRAM.MAIN_FOLDER "\changelog.txt"
	.	"`nFlag: " 2)
	errorLog .= "`n`n""Failed to extract file!"
	.	"`nSource: resources\changelog.txt"
	.	"`nDest: " PROGRAM.MAIN_FOLDER "\changelog.txt"
	.	"`nFlag: " 2
}

; ----------------------------
if !InStr(FileExist(PROGRAM.MAIN_FOLDER ""), "D")
	FileCreateDir,% PROGRAM.MAIN_FOLDER ""

if (A_IsCompiled) {
	sourceFileSize := Get_ResourceSize("resources\icon.ico")
	FileGetSize, destFileSize, % PROGRAM.MAIN_FOLDER "\icon.ico"
}
else {
	FileGetSize, sourceFileSize, resources\icon.ico
	FileGetSize, destFileSize, % PROGRAM.MAIN_FOLDER "\icon.ico"
}
if (sourceFileSize != destFileSize)
	FileInstall, resources\icon.ico, % PROGRAM.MAIN_FOLDER "\icon.ico", 1
if (ErrorLevel) {
	AppendToLogs("Failed to extract file!"
	.	"`nSource: resources\icon.ico"
	.	"`nDest: " PROGRAM.MAIN_FOLDER "\icon.ico"
	.	"`nFlag: " 2)
	errorLog .= "`n`n""Failed to extract file!"
	.	"`nSource: resources\icon.ico"
	.	"`nDest: " PROGRAM.MAIN_FOLDER "\icon.ico"
	.	"`nFlag: " 2
}

; ----------------------------


if (errorLog)
	MsgBox, 4096, POE Trade Instant Whisper,% "One or multiple files failed to be extracted. Please check the logs file for details."
	.	PROGRAM.LOGS_FILE 

}
