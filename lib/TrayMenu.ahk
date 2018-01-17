Create_TrayMenu() {
	global PROGRAM

	Try Menu,Tray,DeleteAll
	Menu,Tray,NoStandard

	if ( !A_IsCompiled && FileExist(A_ScriptDir "\resources\icon.ico") )
		Menu, Tray, Icon, %A_ScriptDir%\resources\icon.ico
	Menu,Tray,Tip,% PROGRAM.NAME
	Menu,Tray,NoStandard
	Menu,Tray,Add,Reload,Reload
	Menu,Tray,Add,Close,Exit

	Menu,Tray,Tip,% PROGRAM.NAME
	Menu,Tray,Add,Reload,Reload
	Menu,Tray,Add,Close,Exit

	Menu,Tray,Icon
	if (A_IconHidden) {
		Menu,Tray,NoIcon
		Menu,Tray,Icon
	}
}

Reload_Label:
	Reload
Return

ExitApp_Label:
	ExitApp
Return