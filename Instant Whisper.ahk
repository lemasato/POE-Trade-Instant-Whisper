/*		POETrade/POEApp Instant Whisper       
		Instantly send a poe.trade or poeapp.com whisper upon copy
		https://github.com/lemasato

		HowTo: Hold down the CTRL key, click on "Whisper" from poe.trade.
		Some settings may be changed in the Start_Script() function.
*/

#NoEnv 
#Persistent
#SingleInstance, Force

Start_Script()
Return

~*Space:: ; Cancel auto-whisper
	global WAIT_MODIFIER_UP, CANCEL_WHISPER

	if (WAIT_MODIFIER_UP) {
		CANCEL_WHISPER := True
		ShowToolTip("Instant whisper successfully canceled.", 3000)
	}
Return

Start_Script() {
	global SETTINGS := {}
	SETTINGS.WHISPERS_MAX_HISTORY		:= 10 ; Prevent sending the same whisper multiple times. Also in case something modifies the clipboard.
	SETTINGS.CHAT_KEY_VK 				:= "0xD" ; ENTER - Chat key virutal key code.
	SETTINGS.MODIFIER_KEY_ENABLE 		:= True ; Enable = need to hold down a specific key to send whisper. False = no need to hold down any key.
	SETTINGS.MODIFIER_KEY_VK 			:= "0x11" ; CTRL - If holding down this key when clicking on poe.trade "Whisper" link, instantly send msg in game.

	; POE Game
	global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe"]
	global POEGameList := "PathOfExile.exe,PathOfExile_x64.exe,PathOfExileSteam.exe,PathOfExile_x64Steam.exe"
	for nothing, executable in POEGameArr {
		GroupAdd, POEGameGroup, ahk_exe %executable%
	}

	; --------

	Create_TrayMenu()
	ShellMessage_Enable()
	OnClipboardChange("OnClipboardChange_Func")
}
return

/*	*		*		*		*		*		*		*		*		*		*		*		*		*
*		*		*		*		*		CLIPBOARD MONITOR 		*		*		*		*		*		*
/	*		*		*		*		*		*		*		*		*		*		*		*		*
*/

OnClipboardChange_Func(_Type) {
	global LAST_GAME_PID, SETTINGS
	global WAIT_MODIFIER_UP, CANCEL_WHISPER
	static previousWhispers := []
	static isFunctionRunning, previousStr

	maxPreviousWhispers := SETTINGS.WHISPERS_MAX_HISTORY
	chatKeyVK := SETTINGS.CHAT_KEY_VK
	isModKeyEnabled := SETTINGS.MODIFIER_KEY_ENABLE
	modKeyVK := SETTINGS.MODIFIER_KEY_VK

	if (isFunctionRunning || ( (clipboardStr && previousStr) && (clipboardStr = previousStr) )) {
		Return
	}

	isFunctionRunning := True
	clipboardStr := Clipboard
	clipboardStrFirstChar := SubStr(clipboardStr, 1, 1)

	; poe.trade regex
	poeTradeRegex := "@.* Hi, I would like to buy your .* listed for .* in"
	poeTradeUnpricedRegex := "@.* Hi, I would like to buy your .* in"
	currencyPoeTradeRegex := "@.* Hi, I'd like to buy your .* for my .* in"
	; poeapp.com regex
	poeAppRegex := "@.* wtb .* listed for .* in .*"
	poeAppUnpricedRegex := "@.* wtb .* in"

	allRegexes := []
	allRegexes.Push(poeTradeRegex, poeTradeUnpricedRegex, currencyPoeTradeRegex
		, poeAppRegex, poeAppUnpricedRegex)

	; Make sure it starts with @ and doesnt contain line break
	if InStr(clipboardStr, "`n") || (clipboardStrFirstChar != "@")  {
		GoSub OnClipboardChange_Func_Finished
		Return
	}

	; Check if trading whisper
	Loop % allRegexes.MaxIndex() { ; compare whisper with regex
		if RegExMatch(clipboardStr, "S)" allRegexes[A_Index]) { ; Trading whisper detected
			isTradingWhisper := True
		}
		if (isTradingWhisper)
			Break
	}

	; Not a trading whisper, cancel
	if !(isTradingWhisper) {
		GoSub OnClipboardChange_Func_Finished
		Return
	}

	; Check if whisper is in history
	for whispID, whispContent in previousWhispers {
		if (clipboardStr = whispContent) { ; whisper is in previousWhispers
			isWhisperInHistory := True
		}
	}

	if (isModKeyEnabled) { ; Key is enabled. Wait until its up to send whisper
		isModKeyDown := GetKeyState("VK" modKeyVK, "P")
		if !(isModKeyDown) {
			GoSub OnClipboardChange_Func_Finished
			Return
		}
		if (isWhisperInHistory) { ; whisper sent not long ago, cancel
			ShowToolTip("Whisper has been sent within`nthe last " maxPreviousWhispers " previous whispers`n`nOperation canceled.", 6500)
			GoSub OnClipboardChange_Func_Finished
			Return
		}
		ShowToolTip("Whisper will be sent upon releasing the modifier key.`nPress [ SPACE ] to cancel.")
		WAIT_MODIFIER_UP := True
		KeyWait, VK%modKeyVK%, U
		WAIT_MODIFIER_UP := False
	}
	else { ; Key is disabled, just send whisper
		if (isWhisperInHistory) { ; whisper sent not long ago, cancel
			ShowToolTip("Whisper has been sent within`nthe last " maxPreviousWhispers " previous whispers`n`nOperation canceled.", 6500)
			GoSub OnClipboardChange_Func_Finished
			Return
		}
	}

	if (CANCEL_WHISPER) {
		CANCEL_WHISPER := False
		GoSub OnClipboardChange_Func_Finished
		Return
	}

	; Activating game window
	titleMatchMode := A_TitleMatchMode
	SetTitleMatchMode, RegEx ; RegEx = Fix some case where specifying only the pid does not work
	if (LAST_GAME_PID) { ; By using PID
		WinActivate,[a-zA-Z0-9_] ahk_pid %LAST_GAME_PID%
		WinWaitActive,[a-zA-Z0-9_] ahk_pid %LAST_GAME_PID%, ,5
		if (ErrorLevel) {
			ShowToolTip("Failed to enable POE window (PID: " LAST_GAME_PID ")`nCanceling", 2500)
			GoSub OnClipboardChange_Func_Finished
			Return
		}
	}
	else { ; By using group
		WinActivate,[a-zA-Z0-9_] ahk_group POEGameGroup
		WinWaitActive,[a-zA-Z0-9_] ahk_group POEGameGroup, ,5
		if (ErrorLevel) {
			ShowToolTip("Failed to enable POE window`nCanceling", 2500)
			GoSub OnClipboardChange_Func_Finished
			Return
		}
	}
	SetTitleMatchMode, %titleMatchMode%

	; Sending the message
	SendEvent, {sc035}{BackSpace}
	SendEvent,{VK%chatKeyVK%}
	Clip(Clipboard)
	SendEvent,{Enter}
; 
	; Update the array
	if (previousWhispers.MaxIndex() >= maxPreviousWhispers) { ; Re-organize previous whispers array
		Loop % previousWhispers.MaxIndex() {
			if (A_Index < maxPreviousWhispers)
				previousWhispers[A_Index] := previousWhispers[A_Index+1]
			else
				previousWhispers.RemoveAt(A_Index)
		}
	}
	previousWhispers.Push(clipboardStr) ; Add whisper to array

	previousStr := clipboardStr
	GoSub OnClipboardChange_Func_Finished
	Return

	OnClipboardChange_Func_Finished:
		isFunctionRunning := False
	Return
}

/*	*		*		*		*		*		*		*		*		*		*		*		*		*
*		*		*		*		*		*		TRAY 	*		*		*		*		*		*
/	*		*		*		*		*		*		*		*		*		*		*		*		*
*/

Create_TrayMenu() {
	Try Menu,Tray,DeleteAll
	Menu,Tray,NoStandard
	Menu,Tray,Tip,Instant Whisper - by lemasato
	Menu,Tray,Add,Reload,Reload_Label
	Menu,Tray,Add,Close,ExitApp_Label
}

Reload_Label:
	Reload
Return

ExitApp_Label:
	ExitApp
Return

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

/*	*		*		*		*		*		*		*		*		*		*		*		*		*
*		*		*		*		*		*		SHELLMSG 		*		*		*		*		*		*
/	*		*		*		*		*		*		*		*		*		*		*		*		*
*/

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

ShellMessage(wParam, lParam) {
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

/*	*		*		*		*		*		*		*		*		*		*		*		*		*
*		*		*		*		*		*		*	CLIP 		*		*		*		*		*		*
/	*		*		*		*		*		*		*		*		*		*		*		*		*
*/

Clip(Text="", Reselect="") {
/*		Credits to berban
		https://autohotkey.com/board/topic/70404-clip-send-and-retrieve-text-using-the-clipboard/

		Usage: Call it without any parameters to retrieve the text currently selected.
					Var := Clip() ; will store any selected text in %Var%
			   Or call it with some text in the first parameter to "send" that text via the clipboard and Control+V.
			   		The two are analogous. Clip() is generally preferable for larger amounts of text
					Clip("Some text")
					SendInput {Raw}Some text ; Raw because when using Clip() keyboard combinations like ^s (ctrl+s) will be sent literally. SendInput {Raw} also does this.

		Why use Clip()?
				- Can send and retrieve with one function
				- No delay while sending. Normally you have to wait 400ms or so after sending Control+V before restoring the clipboard's contents, or else sometimes it pastes the backup contents instead.
				  Clip() tasks this to a timer so your script can continue executing.
				- Improves performance by only saving & restoring the clipboard's contents once in the case of rapid clipboard operations.
				- Can reselct pasted text.
*/
	Static BackUpClip, Stored, LastClip
	If (A_ThisLabel = A_ThisFunc) {
		If (Clipboard == LastClip)
			Clipboard := BackUpClip
		BackUpClip := LastClip := Stored := ""
	} Else {
		If !Stored {
			Stored := True
			BackUpClip := ClipboardAll ; ClipboardAll must be on its own line
		} Else
			SetTimer, %A_ThisFunc%, Off
		LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
		If (Text = "") {
			SendInput, ^{sc02e}
			ClipWait, LongCopy ? 0.6 : 0.2, True
		} Else {
			Clipboard := LastClip := Text
			ClipWait, 10
			SendInput, ^{sc02F}
		}
		SetTimer, %A_ThisFunc%, -700
		Sleep 50 ; Short sleep in case Clip() is followed by more keystrokes such as {Enter}
		If (Text = "")
			Return LastClip := Clipboard
		Else If (ReSelect = True) or (Reselect and (StrLen(Text) < 3000)) {
			StringReplace, Text, Text, `r, , All
			SendInput, % "{Shift Down}{Left " StrLen(Text) "}{Shift Up}"
		}
	}
	Return
	Clip:
	Return Clip()
}
