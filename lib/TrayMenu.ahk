TrayMenu() {
	Menu,Tray,DeleteAll
	if ( !A_IsCompiled && FileExist(A_ScriptDir "\resources\icon.ico") )
		Menu, Tray, Icon, %A_ScriptDir%\resources\icon.ico
	Menu,Tray,Tip,POE Trade Instant Whisper
	Menu,Tray,NoStandard
	Menu,Tray,Add,GitHub,Tray_GitHub
	Menu,Tray,Add
	Menu,Tray,Add,% "Reload", Tray_Reload ; Reload
	Menu,Tray,Add,% "Close", Tray_Exit ; Close
	Menu,Tray,Icon
}

Tray_GitHub() {
	global PROGRAM
	Run, % PROGRAM.LINK_GITHUB
}
Tray_Reload() {
	Reload()
}
Tray_Exit() {
	ExitApp
}
