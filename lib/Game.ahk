Send_GameMessage(actionType, msgString, gamePID="") {
	global PROGRAM, GAME
	global MyDocuments

	Thread, NoTimers

	sendMsgMode := "Clipboard"

;	Retrieve the virtual key id for chat opening
	chatVK := GAME.SETTINGS.ChatKey_VK ? GAME.SETTINGS.ChatKey_VK : "0xD"

	titleMatchMode := A_TitleMatchMode
	SetTitleMatchMode, RegEx ; RegEx = Fix some case where specifying only the pid does not work

	firstChar := SubStr(msgString, 1, 1) ; Get first char, to compare if its a special chat command

	if (gamePID) {
		WinActivate,[a-zA-Z0-9_] ahk_group POEGameGroup ahk_pid %gamePID%
		WinWaitActive,[a-zA-Z0-9_] ahk_group POEGameGroup ahk_pid %gamePID%, ,2
		isToolSameElevation := Is_Tool_Elevation_SameLevel_As_GameInstance(gamePID)
	}
	else {
		WinActivate,[a-zA-Z0-9_] ahk_group POEGameGroup
		WinWaitActive,[a-zA-Z0-9_] ahk_group POEGameGroup, ,2
		WinGet, gamePID, PID, A
		isToolSameElevation := Is_Tool_Elevation_SameLevel_As_GameInstance(gamePID)
	}
	if (ErrorLevel) {
		AppendToLogs(A_ThisFunc "(actionType=" actionType ", msgString=" msgString ", gamePID=" gamePID "): WinWaitActive timed out.")
		TrayNotifications.Show("Game window focus timed out", "Game window failed to be activated within 2 seconds, sending message canceled.")
		return "WINWAITACTIVE_TIMEOUT"
	}

	if (!isToolSameElevation) {
		MsgBox(4096+48+4, PROGRAM.NAME " - " "Reload as admin?", "Cannot interact with the game instance (PID %pid%) because the game is running as admin and the tool is not. To avoid this warning in the future, make sure to start the tool as admin.`nWould you like to automatically reload the tool with admin elevation? All tabs will still be there after reloading.")

		IfMsgBox, Yes
		{
			ReloadWithParams(" /MyDocuments=""" MyDocuments """", getCurrentParams:=True, asAdmin:=True)
		}
		else return
	}

	GoSub, Send_GameMessage_OpenChat
	GoSub, Send_GameMessage_ClearChat

	if (actionType = "WRITE_SEND") {
		if (sendMsgMode = "Clipboard") {
			While (Clipboard != msgString) {
				Set_Clipboard(msgString)

				if (Clipboard = msgString)
					break

				else if (A_Index > 100) {
					err := True
					break
				}
				Sleep 50
			}
			if (!err)
				SendEvent, ^{sc02F}
			else
				TrayNotifications.Show("Failed to send the message", "The clipboard failed to be updated in time. Message won't be sent. Make sure that no program is interfering with the clipboard.")
			; SetTimer, Reset_Clipboard, -700
		}
		else if (sendMsgMode = "SendInput")
			SendInput,%msgString%
		else if (sendMsgMode = "SendEvent")
			SendEvent,%msgString%

		SendEvent,{Enter}
	}
	else if (actionType = "WRITE_DONT_SEND") {
		if (sendMsgMode = "Clipboard") {
			While (Clipboard != msgString) {
				Set_Clipboard(msgString)

				if (Clipboard = msgString)
					break

				else if (A_Index > 100) {
					err := True
					break
				}
				Sleep 50
			}
			if (!err)
				SendEvent, ^{sc02F}
			else
				TrayNotifications.Show("Failed to send the message", "The clipboard failed to be updated in time. Message won't be sent. Make sure that no program is interfering with the clipboard.")
			; SetTimer, Reset_Clipboard, -700
		}
		else if (sendMsgMode = "SendInput")
			SendEvent,%msgString%
		else if (sendMsgMode = "SendEvent")
			SendEvent,%msgString%
	}
	else if (actionType = "WRITE_GO_BACK") {
		foundPos := InStr(msgString, "{X}"), _strLen := StrLen(msgString), leftPresses := _strLen-foundPos+1-3
		msgString := StrReplace(msgString, "{X}", "")

		if (sendMsgMode = "Clipboard") {
			While (Clipboard != msgString) {
				Set_Clipboard(msgString)

				if (Clipboard = msgString)
					break

				else if (A_Index > 100) {
					err := True
					break
				}
				Sleep 50
			}
			if (!err)
				SendEvent, ^{sc02F}
			else
				TrayNotifications.Show("Failed to send the message", "The clipboard failed to be updated in time. Message won't be sent. Make sure that no program is interfering with the clipboard.")
			; SetTimer, Reset_Clipboard, -700
		}
		else if (sendMsgMode = "SendInput")
			SendInput,%msgString%
		else if (sendMsgMode = "SendEvent")
			SendEvent,%msgString%

		if (!err)
			SendInput {Left %leftPresses%}
	}

	SetTitleMatchMode, %titleMatchMode%
	Return

	Send_GameMessage_ClearChat:
		if !IsIn(firstChar, "/,%,&,#,@") { ; Not a command. We send / then remove it to make sure chat is empty
			SendEvent,{Space}/{BackSpace}
		}
	Return

	Send_GameMessage_OpenChat:
		if IsIn(chatVK, "0x1,0x2,0x4,0x5,0x6,0x9C,0x9D,0x9E,0x9F") { ; Mouse buttons
			keyDelay := A_KeyDelay, keyDuration := A_KeyDuration
			SetKeyDelay, 10, 10
			if (gamePID)
				ControlSend, ,{VK%keyVK%}, [a-zA-Z0-9_] ahk_groupe POEGameGroup ahk_pid %gamePID% ; Mouse buttons tend to activate the window under the cursor.
																	  						  	  ; Therefore, we need to send the key to the actual game window.
			else {
				WinGet, activeWinHandle, ID, A
				ControlSend, ,{VK%keyVK%}, [a-zA-Z0-9_] ahk_groupe POEGameGroup ahk_pid %activeWinHandle%
			}
			SetKeyDelay,% keyDelay,% keyDuration
		}
		else
			SendEvent,{VK%chatVK%}
	Return
}

IsTradingWhisper(str) {
	firstChar := SubStr(str, 1, 1)

	; poe.trade regex
	poeTradeRegex := "@.* Hi, I would like to buy your .* listed for .* in .*"
	poeTradeUnpricedRegex := "@.* Hi, I would like to buy your .* in .*"
	currencyPoeTradeRegex := "@.* Hi, I'd like to buy your .* for my .* in .*"
	; poeapp.com regex
	poeAppRegex := "@.* wtb .* listed for .* in .*"
	poeAppUnpricedRegex := "@.* wtb .* in .*"
	poeAppCurrencyRegex := "@.* I'd like to buy your .* for my .* in .*"
	; ggg regex
	RUS_gggRegEx			:= "@.* Здравствуйте, хочу купить у вас .* за (.*) в лиге.*"
	RUS_gggUnpricedRegEx	:= "@.* Здравствуйте, хочу купить у вас .* в лиге.*"
	RUS_gggCurrencyRegEx	:= "@.* Здравствуйте, хочу купить у вас .* за (.*) в лиге.*"

	POR_gggRegEx 			:= "@.* Olá, eu gostaria de comprar o seu item .* listado por .* na.*"
	POR_gggUnpricedRegEx 	:= "@.* Olá, eu gostaria de comprar o seu item .* na.*"
	POR_gggCurrencyRegEx 	:= "@.* Olá, eu gostaria de comprar seu\(s\) .* pelo\(s\) meu\(s\).*"

	THA_gggRegEx			:= "@.* สวัสดี, เราต้องการจะชื้อของคุณ .* ใน ราคา .* ใน.*"
	THA_gggUnpricedRegEx	:= "@.* สวัสดี, เราต้องการจะชื้อของคุณ .* ใน.*"
	THA_gggCurrencyRegEx	:= "@.* สวัสดี เรามีความต้องการจะชื้อ .* ของคุณ ฉันมี .* ใน.*"

	GER_gggRegEx 			:= "@.* Hi, ich möchte '.*' zum angebotenen Preis von .* in der '.*'-Liga kaufen.*"
	GER_gggUnpricedRegEx	:= "@.* Hi, ich möchte '.*' in der '.*'-Liga kaufen.*"
	GER_gggCurrencyRegEx	:= "@.* Hi, ich möchte '.*' zum angebotenen Preis von '(.*)' in der '(.*)'-Liga kaufen(.*)"

	FRE_gggRegEx			:= "@.* Bonjour, je souhaiterais t'acheter .* pour .* dans la ligue.*"
	FRE_gggUnpricedRegEx	:= "@.* Bonjour, je souhaiterais t'acheter .* dans la ligue.*"
	FRE_gggCurrencyRegEx	:= "@.* Bonjour, je voudrais t'acheter .* contre .* dans la ligue.*"

	SPA_gggRegEx			:= "@.* Hola, quisiera comprar tu .* listado por .* en.*"
	SPA_gggUnpricedRegEx 	:= "@.* Hola, quisiera comprar tu .* en.*"
	SPA_gggCurrencyRegEx	:= "@.* Hola, me gustaría comprar tu\(s\) .* por mi .* en.*"

	KOR_gggRexEx			:= "@.* 안녕하세요, .*에 .*\(으\)로 올려놓은 .*을\(를\) 구매하고 싶습니다.*"
	KOR_gggUnpricedRegEx 	:= "@.* 안녕하세요, .*에 올려놓은 .*을\(를\) 구매하고 싶습니다.*"
	KOR_gggCurrencyRegEx	:= "@.* 안녕하세요, .*에 올려놓은.* 을\(를\) 제 .*\(으\)로 구매하고 싶습니다.*"

	allRegexes := []
	allRegexes.Push(poeTradeRegex, poeTradeUnpricedRegex, currencyPoeTradeRegex
		, poeAppRegex, poeAppUnpricedRegex, poeAppCurrencyRegex
		, RUS_gggRegEx, RUS_gggUnpricedRegEx, RUS_gggCurrencyRegEx
		, POR_gggRegEx, POR_gggUnpricedRegEx, POR_gggCurrencyRegEx
		, THA_gggRegEx, THA_gggUnpricedRegEx, THA_gggCurrencyRegEx
		, GER_gggRegEx, GER_gggUnpricedRegEx, GER_gggCurrencyRegEx
		, FRE_gggRegEx, FRE_gggUnpricedRegEx, FRE_gggCurrencyRegEx
		, SPA_gggRegEx, SPA_gggUnpricedRegEx, SPA_gggCurrencyRegEx
		, KOR_gggRegEx, KOR_gggUnpricedRegEx, KOR_gggCurrencyRegEx)

	; Make sure it starts with @ and doesnt contain line break
	if InStr(str, "`n") || (firstChar != "@")  {
		Return False
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

Is_Tool_Elevation_SameLevel_As_GameInstance(gamePID) {
	isElevated := Is_Game_Elevated(gamePID)
	
	isSameLevel := (isElevated = True) && (A_IsAdmin) ? True
		: (isElevated = False) ? True
		: (isElevated = True) ? False
		: False

	return isSameLevel
}

Is_Game_Elevated(gamePID) {
	
	WinGet, pName, ProcessName, ahk_pid %gamePID%
	processInfos := Get_ProcessInfos(pName, gamePID)
	isProcessElevated := (processInfos[1]["TokenIsElevated"])?(True):(processInfos=2)?(True):(False)

	return isProcessElevated
}