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
 *			Is used to correctly position the Trades GUI while in Overlay mode
*/
	global POEGameList
	
	if ( wParam=4 || wParam=32772 || wParam=5 ) { ; 4=HSHELL_WINDOWACTIVATED | 32772=HSHELL_RUDEAPPACTIVATED | 5=HSHELL_GETMINRECT 
		WinGet, winPName, ProcessName, ahk_id %lParam%
		if IsIn(winPName, POEGameList)
			WinGet, LASTACTIVATED_GAMEPID, PID, ahk_id %lParam%
	}
	return
}
