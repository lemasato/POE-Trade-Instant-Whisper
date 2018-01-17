Set_LocalSettings() {
	global PROGRAM
	iniFile := PROGRAM.INI_FILE

	;_TO_BE_ADDED_

	if !FileExist(iniFile)
		FileAppend, ,% iniFile

	sect := "PROGRAM"
	keysAndValues := {	Version:PROGRAM.VERSION
						,Last_Update_Check:"1994042612310000"
						,FileName:A_ScriptName
						,PID:PROGRAM.PID}

	for iniKey, iniValue in keysAndValues {
		curValue := INI.Get(iniFile, sect, iniKey)

		if (iniKey = "Last_Update_Check") { ; Make sure value is time format
			EnvAdd, curValue, 1, Seconds
			if !(curValue) || (curValue = 1)
				curValue := "ERROR"
		}
		if IsIn(iniKey, "FileName,PID") ; These values are instance specific
			curValue := "ERROR"

		if (curValue = "ERROR" || curValue = "") {
			INI.Set(iniFile, sect, iniKey, iniValue)
		}
	}
}

Get_LocalSettings() {
	global PROGRAM
	iniFile := PROGRAM.INI_FILE
	settingsObj := {}

	Loop, Parse,% INI.Get(iniFile), "`n"
	{
		settingsObj[A_LoopField] := {}

		arr := INI.Get(iniFile, A_LoopField,,1)
		for key, value in arr {
			settingsObj[A_LoopField][key] := value
		}
	}

	; PROGRAM.OS := {}
	; PROGRAM.OS.RESOLUTION_DPI := Get_DpiFactor()

	return settingsObj
}

Update_LocalSettings() {
	global ProgramValues

	;_TO_BE_ADDED_

	; Delete ExternalOverlay folder from 0.1 version. Is is now called NSO Overlay
	; if InStr(FileExist(ProgramValues.Resources_Folder "\ExternalOverlay"), "D") 
	; 	FileRemoveDir,% ProgramValues.Resources_Folder "\ExternalOverlay", 1

	; ; Rename External_Overlay ini entries to NSO_Overlay
	; INI.Rename(ProgramValues.Ini_File, "External_Overlay", , "NSO_Overlay")
	; sects := INI.Get(ProgramValues.Profiles_File)

	; Loop, Parse,% sects, "`n"
	; {
	; 	nsoValue := INI.Get(ProgramValues.Profiles_File, A_LoopField, "Use_NSO_Overlay")
	; 	if (nsoValue=1 || nsoValue=0)
	; 		INI.Remove(ProgramValues.Profiles_File, A_LoopField, "Use_External_Overlay")
	; 	else
	; 		INI.Rename(ProgramValues.Profiles_File, A_LoopField, "Use_External_Overlay", A_LoopField, "Use_NSO_Overlay")
	; }
}

Declare_LocalSettings(settingsObj) {
	global PROGRAM

	if !(PROGRAM.SETTINGS)
		PROGRAM.SETTINGS := {}

	for iniSection, nothing in settingsObj {
		PROGRAM["SETTINGS"][iniSection] := {}
		for iniKey, iniValue in settingsObj[iniSection]
			PROGRAM["SETTINGS"][iniSection][iniKey] := iniValue
	}
}