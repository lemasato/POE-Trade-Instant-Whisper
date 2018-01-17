Get_CmdLineParameters() {
	global 0
	
	Loop, %0% {
		param := ""
		param := RegExReplace(%A_Index%, "(.*)=(.*)", "$1=""$2""") ; Add quotes to parameters. In case any contain a space

		if (param)
			params .= A_Space . param
	}

	return params
}

Handle_CmdLineParameters() {
	global 0, PROGRAM, GAME, RUNTIME_PARAMETERS

	programName := PROGRAM.NAME

	Loop, %0% {
		param := ""
		param := RegExReplace(%A_Index%, "(.*)=(.*)", "$1=""$2""") ; Add quotes to parameters. In case any contain a space

		if (param = "/NoReplace") {
			PROGRAM.RUNTIME_PARAMETERS["NoReplace"] := True
		}
		else if RegExMatch(param, "O)/GamePath=(.*)", found) {
			if FileExist(found.1) {
				RUNTIME_PARAMETERS.Insert("GamePath", found.1)
			}
			else {
				MsgBox, 4096,% programName,% "The /GamePath parameter was detected but the specified file does not exist:"
				. "`n" found.1
				. "`n`nIf you need help about Command Line Parameters, please check the WIKI here:`n" PROGRAM.LINK_GITHUB "/wiki"
			}
		}
		else if RegExMatch(param, "O)/PrefsFile=(.*)", found) {
			path := PROGRAM.MAIN_FOLDER "/" found.1
			PROGRAM.INI_FILE := path
		}
		else if RegExMatch(param, "O)/GameINI=(.*)", found) {
			if FileExist(found.1) {
				GAME.INI_FILE := found.1
			}
			else {
				MsgBox, 4096,% programName,% "The /GameINI parameter was detected but the specified file does not exist:"
				. "`n" found.1
				. "`n`nIf you need help about Command Line Parameters, please check the WIKI here`n: " PROGRAM.LINK_GITHUB "/wiki"
			}
		}
		else if RegExMatch(param, "O)/MyDocuments=(.*)", found) {
			RUNTIME_PARAMETERS["MyDocuments"] := found.1
		}
		else if (param="/NoAdmin" || param="/SkipAdmin") {
			RUNTIME_PARAMETERS["SkipAdmin"] := True
		}
		else if (RegExMatch(param, "O)/Screen_DPI=(.*)", found) || RegExMatch(param, "O)/ResolutionDPI=(.*)", found)) {
			MsgBox(4096, , "The following parameter is no longer supported: " param)
		; 	PROGRAM.SETTING["RESOLUTION_DPI"] := found.1
		}
	}
}