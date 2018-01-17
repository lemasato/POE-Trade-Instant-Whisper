ShellMessage_Enable() {
	ShellMessage_State(True)
}

ShellMessage_Disable() {
	ShellMessage_State(False)
}

ShellMessage_State(state) {
	Gui, ShellMsg:Destroy
	Gui, ShellMsg:New, +LastFound 

	Hwnd := WinExist()
	DllCall( "RegisterShellHookWindow", UInt,Hwnd )
	MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
	OnMessage( MsgNum, "ShellMessage", state)
}

ShellMessage(wParam,lParam) {
/*			Triggered upon activating a window
*/
	global LAST_GAME_PID
	gameProcesses := "PathOfExile.exe,PathOfExile_x64.exe,PathOfExileSteam.exe,PathOfExile_x64Steam.exe"

	if ( wParam=4 or wParam=32772 ) { ; 4=HSHELL_WINDOWACTIVATED | 32772=HSHELL_RUDEAPPACTIVATED
		WinGet, winPName, ProcessName, ahk_id %lParam%
		if winPName in %gameProcesses%
		{
			WinGet, winPID, PID, ahk_id %lParam%
			LAST_GAME_PID := winPID
		}
	}
}
