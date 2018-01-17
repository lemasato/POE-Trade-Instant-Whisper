UpdateCheck(force=false, prompt=false, preRelease=false) {
	global PROGRAM, SPACEBAR_WAIT
	iniFile := PROGRAM.INI_FILE

	; autoupdate := INI.Get(iniFile, "SETTINGS", "Auto_Update")
	lastUpdateCheck := INI.Get(iniFile, "PROGRAM", "Last_Update_Check")
	if (force) ; Fake the last update check, so it's higher than 35mins
		lastUpdateCheck := 1994042612310000

	timeDif := A_Now
	timeDif -= lastUpdateCheck, Minutes

	if !(timeDif > 35) ; Hasn't been longer than 35mins since last check, cancel to avoid spamming GitHub API
		Return

	if FileExist(PROGRAM.UPDATER_FILENAME)
		FileDelete,% PROGRAM.UPDATER_FILENAME

	Ini.Set(iniFile, "PROGRAM", "Last_Update_Check", A_Now)

	if (preRelease)
		releaseInfos := GetLatestPreRelease_Infos(PROGRAM.GITHUB_USER, PROGRAM.GITHUB_REPO)
	else
		releaseInfos := GetLatestRelease_Infos(PROGRAM.GITHUB_USER, PROGRAM.GITHUB_REPO)
	onlineVer := releaseInfos.name
	onlineDownload := releaseInfos.assets.1.browser_download_url

	if (prompt) {
		if (!onlineVer || !onlineDownload) {
			SplashTextOn(PROGRAM.NAME " - Updating Error", "There was an issue when retrieving the latest release from GitHub API"
			.											"`nIf this keeps on happening, please try updating manually."
			.											"`nYou can find the GitHub repository link in the Settings menu.", 1, 1)
		}
		else if (onlineVer && onlineDownload) && (onlineVer != PROGRAM.VERSION) {
			if (autoupdate) {
				FileDownload(PROGRAM.LINK_UPDATER, PROGRAM.UPDATER_FILENAME)
				Run_Updater(onlineDownload)
			}
			Else
				ShowUpdatePrompt(onlineVer, onlineDownload)
			Return
		}
		else if (onlineVer = PROGRAM.VERSION) {
			TrayNotifications.Show(PROGRAM.NAME, "You are up to date! " A_Index)
		}
	}

	Return {Version:onlineVer, Download:onlineDownload}
}

ShowUpdatePrompt(ver, dl) {
	global PROGRAM

	MsgBox, 4100, Update detected (v%ver%),% "Current version:" A_Tab PROGRAM.VERSION
	.										 "`nOnline version: " A_Tab ver
	.										 "`n"
	.										 "`nWould you like to update now?"
	.										 "`nThe entire updating process is automated."
	IfMsgBox, Yes
	{
		success := Download(PROGRAM.LINK_UPDATER, PROGRAM.UPDATER_FILENAME)
		if (success)
			Run_Updater(dl)
	}
}

Run_Updater(downloadLink) {
	global PROGRAM
	iniFile := PROGRAM.Ini_File

	updaterLink 		:= PROGRAM.LINK_UPDATER

	INI.Set(iniFile, "PROGRAM", "LastUpdate", A_Now)
	Run,% PROGRAM.UPDATER_FILENAME 
	. " /Name=""" PROGRAM.NAME  """"
	. " /File_Name=""" A_ScriptDir "\" PROGRAM.NAME ".exe" """"
	. " /Local_Folder=""" PROGRAM.Local_Folder """"
	. " /Ini_File=""" PROGRAM.Ini_File """"
	. " /NewVersion_Link=""" downloadLink """"
	ExitApp
}