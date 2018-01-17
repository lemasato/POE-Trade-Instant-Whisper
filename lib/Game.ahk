Activate_GameWindow(_PID="") {
	titleMatchMode := A_TitleMatchMode
	SetTitleMatchMode, RegEx ; RegEx = Fix some case where specifying only the pid does not work
	if (_PID) { ; By using PID
		WinActivate,[a-zA-Z0-9_] ahk_pid %_PID%
		WinWaitActive,[a-zA-Z0-9_] ahk_pid %_PID%, ,5
		if (ErrorLevel) {
			ShowToolTip("Failed to enable POE window (PID: " _PID ")`nCanceling", 2500)
			SetTitleMatchMode, %titleMatchMode%
			Return 1
		}
	}
	else { ; By using group
		WinActivate,[a-zA-Z0-9_] ahk_group POEGameGroup
		WinWaitActive,[a-zA-Z0-9_] ahk_group POEGameGroup, ,5
		if (ErrorLevel) {
			ShowToolTip("Failed to enable POE window`nCanceling", 2500)
			SetTitleMatchMode, %titleMatchMode%
			Return 1
		}
	}
	SetTitleMatchMode, %titleMatchMode%
}

Send_InGameMessage(msg) {
	global PROGRAM, GAME
	chatKeyVK := GAME.SETTINGS.ChatKey_VK

	WinGet, activePID, PID, A
	isPIDElevated := GAME["PID"][activePID]["Is_Elevated"]
	hasPIDBeenWarned := GAME["PID"][activePID]["Has_Been_Warned"]
	if (isPIDElevated = "") {
		WinGet, activePName, ProcessName, A
		gameProcessInfos := Get_ProcessInfos(activePName, activePID)
		tokenElevated := gameProcessInfos[1]["TokenIsElevated"]
		isPIDElevated := (tokenElevated != "")?(tokenElevated):(gameProcessInfos)

		if !(GAME["PID"])  ; Create sub arr if not existent
			GAME["PID"] := {}
		if !(GAME["PID"][activePID])
			GAME["PID"][activePID] := {}

		GAME["PID"][activePID]["Is_Elevated"] := isPIDElevated
	}
	if (isPIDElevated && !A_IsAdmin) && !(hasPIDBeenWarned) { ; Show msgbox only once per PID
		GAME["PID"][activePID]["Has_Been_Warned"] := True
		MsgBox(4096, PROGRAM.NAME, activePName " (PID " activePID ") is running elevated (" isPIDElevated ") while we is not. We will be still attempt to send send the message to the game window."
			. "`nIf no message is sent, please restart this program with elevated rights."
			. "`nThis warning will not appear anymore for this session.")
		Activate_GameWindow(activePID) ; Reactivate the game window
	}

	SendEvent,{sc035}{BackSpace}
	SendEvent,{VK%chatKeyVK%}
	Clip(msg)
	SendEvent,{Enter}
}

Is_TradingWhisper(str) {
	firstChar := SubStr(str, 1, 1)

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
	if InStr(str, "`n") || (firstChar != "@")  {
		Return 0
	}

	; Check if trading whisper
	Loop % allRegexes.MaxIndex() { ; compare whisper with regex
		if RegExMatch(str, "S)" allRegexes[A_Index]) { ; Trading whisper detected
			isTradingWhisper := True
		}
		if (isTradingWhisper)
			Break
	}

	Return isTradingWhisper
}

Get_WhisperHistory() {
	global WHISPER_HISTORY
	Return WHISPER_HISTORY
}

IsIn_WhisperHistory(str) {
	global WHISPER_HISTORY

	for histID, histContent in WHISPER_HISTORY {
		if (str = histContent) { ; whisper is in history
			isInHistory := True
			Break
		}
	}
	Return isInHistory
}

AddTo_WhisperHistory(newStr) {
	global PROGRAM
	global WHISPER_HISTORY
	maxHistory := PROGRAM.SETTINGS.WHISPERS_MAX_HISTORY

	if !(WHISPER_HISTORY)
		WHISPER_HISTORY := []

	if (WHISPER_HISTORY.MaxIndex() >= maxHistory) { ; Re-organize previous whispers array
		Loop % WHISPER_HISTORY.MaxIndex() {
			if (A_Index < maxHistory)
				WHISPER_HISTORY[A_Index] := WHISPER_HISTORY[A_Index+1]
			else
				WHISPER_HISTORY.RemoveAt(A_Index)
		}
	}

	WHISPER_HISTORY.Push(newStr) ; Add whisper to array
}