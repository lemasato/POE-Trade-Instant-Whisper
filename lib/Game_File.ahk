Get_GameSettings() {
/*		Retrieve some of the game settings from its ini file.
		We make a copy of the file and use that one because 
*/
	global GAME, PROGRAM

	gameFile := GAME.INI_FILE
	gameFileCopy := GAME.INI_FILE_COPY

	if !FileExist(gameFile) {
		AppendtoLogs("File Not Found: """ gameFile """")
		MsgBox(4096, PROGRAM.NAME, "Your production_Config.ini file could not be found!`nThis file contains all of your Path of Exile settings and is necessary for us to retrieve your chat key.`nYou will still be able to use this tool but your chat key will be considered as ENTER.")
	}

	FileRead, fileContent,% gameFile
	if (!fileContent || ErrorLevel) {
		String := "Unable to retrieve content from file: """ gameFile """"
		AppendtoLogs("Unable to read file: """ gameFile """ System Error Code: " A_LastError)
	}

	File := FileOpen(gameFileCopy, "w", "UTF-16")
	File.Write(fileContent)
	if (ErrorLevel) {
		AppendtoLogs("Unable to write in file: """ gameFileCopy """")
		cantWriteCopy := True
	}
	File.Close()

	if (cantWriteCopy && fileContent) {
		fileEncode := A_FileEncoding
		FileEncoding, UTF-16

		FileDelete,% gameFileCopy
		FileAppend,% fileContent,% gameFileCopy
		if (ErrorLevel)
			AppendtoLogs("Unable to write in file: """ gameFileCopy """")

		FileEncoding,% fileEncode
	}

	INI.Remove(gameFileCopy, "LOGIN", "username")

	chatKeySC := INI.Get(gameFileCopy, "ACTION_KEYS", "chat")
	fullscreen := INI.Get(gameFileCopy, "DISPLAY", "fullscreen")
	borderless :=  INI.Get(gameFileCopy, "DISPLAY", "borderless_windowed_fullscreen")
	height := INI.Get(gameFileCopy, "DISPLAY", "resolution_height")
	width:= INI.Get(gameFileCopy, "DISPLAY", "resolution_width")
	
	chatKeyVK := StringToHex(chr(chatKeySC+0))
	chatKeyName := GetKeyName("VK" chatKeyVK)

	AppendToLogs("Retrieved settings from game file."
	. "Chat key: " """" chatKeySC """" . "   VK: " """" chatKeyVK """" . "   SC: " """" chatKeyName """"
	. "Fullscreen: " fullscreen
	. "Borderless: " borderless
	. "Height: " height
	. "Width: " width)

	returnObj := { ChatKey_SC: chatKeySC
				  ,ChatKey_VK:chatKeyVK
				  ,ChatKey_Name: chatKeyName
				  ,Fullscreen: fullscreen
				  ,Borderless: borderless
				  ,Height: height
				  ,Width: width}

	return returnObj
}

Declare_GameSettings(settingsObj) {
	global GAME

	GAME["SETTINGS"] := {}

	; for iniSection, nothing in settingsObj {
		; GAME["SETTINGS"][iniSection] := {}
		; for iniKey, iniValue in settingsObj[iniSection]
			; GAME["SETTINGS"][iniSection][iniKey] := iniValue
	; }

	for iniKey, iniValue in settingsObj
		GAME["SETTINGS"][iniKey] := iniValue
}