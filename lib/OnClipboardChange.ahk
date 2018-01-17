OnClipboardChange_Func(_Type) {
	global PROGRAM, GAME
	global LAST_GAME_PID
	global WAIT_MODIFIER_UP, CANCEL_WHISPER
	global WHISPER_HISTORY
	static isFunctionRunning, previousStr

	maxHistory := PROGRAM.SETTINGS.WHISPERS_MAX_HISTORY
	chatKeyVK := GAME.SETTINGS.CHATKEY_VK
	isModKeyEnabled := PROGRAM.SETTINGS.MODIFIER_KEY_ENABLE
	modKeyVK := PROGRAM.SETTINGS.MODIFIER_KEY_VK

	if (isFunctionRunning || ( (Clipboard && previousStr) && (Clipboard = previousStr) )) {
		Return
	}

	isFunctionRunning := True, clipboardStr := Clipboard
	if !Is_TradingWhisper(clipboardStr) { ; Not a trading whisper, cancel
		GoSub OnClipboardChange_Func_Finished
		Return
	}

	; Check if whisper is in history
	isWhisperInHistory := IsIn_WhisperHistory(clipboardStr)

	if (isModKeyEnabled) { ; Key is enabled. Wait until its up to send whisper
		isModKeyDown := GetKeyState("VK" modKeyVK, "P")
		if !(isModKeyDown) {
			GoSub OnClipboardChange_Func_Finished
			Return
		}
		if (isWhisperInHistory) { ; whisper sent not long ago, cancel
			ShowToolTip("Whisper has been sent within`nthe last " maxHistory " previous whispers`n`nOperation canceled.", 6500)
			GoSub OnClipboardChange_Func_Finished
			Return
		}
		ShowToolTip("Whisper will be sent upon releasing the modifier key.`nPress [ SPACE ] to cancel.")
		WAIT_MODIFIER_UP := True
		KeyWait, VK%modKeyVK%, U
		RemoveToolTip()
		WAIT_MODIFIER_UP := False
	}
	else { ; Key is disabled, just send whisper
		if (isWhisperInHistory) { ; whisper sent not long ago, cancel
			ShowToolTip("Whisper has been sent within`nthe last " maxHistory " previous whispers`n`nOperation canceled.", 6500)
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
	if (LAST_GAME_PID)
		hasError := Activate_GameWindow(LAST_GAME_PID)
	else
		hasError := Activate_GameWindow()
	if (hasError) {
		GoSub OnClipboardChange_Func_Finished
		Return
	}

	; Sending the message
	Send_InGameMessage(clipboardStr)

	; Update WHISPER_HISTORY array
	AddTo_WhisperHistory(clipboardStr)

	previousStr := clipboardStr
	GoSub OnClipboardChange_Func_Finished
	Return

	OnClipboardChange_Func_Finished:
		isFunctionRunning := False
	Return
}
