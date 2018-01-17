/******************************************************************************************************************
*
*	FGP by kon
*	https://autohotkey.com/boards/viewtopic.php?f=6&t=3806
*	
*	Example Usage:
	#NoEnv
	SetBatchLines, -1
	FileSelectFile, FilePath					; Select a file to use for this example.
	
	PropName := FGP_Name(0)						; Gets a property name based on the property number.
	PropNum  := FGP_Num("Size")					; Gets a property number based on the property name.
	PropVal1 := FGP_Value(FilePath, PropName)	; Gets a file property value by name.
	PropVal2 := FGP_Value(FilePath, PropNum)	; Gets a file property value by number.
	PropList := FGP_List(FilePath)				; Gets all of a file's non-blank properties.
	
	MsgBox, % PropName ":`t" PropVal1			; Display the results.
	. "`n" PropNum ":`t" PropVal2
	. "`n`nList:`n" PropList.CSV
*
*******************************************************************************************************************
*/

/*  FGP_Init()
 *		Gets an object containing all of the property numbers that have corresponding names. 
 *		Used to initialize the other functions.
 *	Returns
 *		An object with the following format:
 *			PropTable.Name["PropName"]	:= PropNum
 *			PropTable.Num[PropNum]		:= "PropName"
 */
FGP_Init() {
	static PropTable
	if (!PropTable) {
		PropTable := {Name: {}, Num: {}}, Gap := 0
		oShell := ComObjCreate("Shell.Application")
		oFolder := oShell.NameSpace(0)
		while (Gap < 11)
			if (PropName := oFolder.GetDetailsOf(0, A_Index - 1)) {
				PropTable.Name[PropName] := A_Index - 1
				PropTable.Num[A_Index - 1] := PropName
				Gap := 0
			}
			else
				Gap++
	}
	return PropTable
}


/*  FGP_Value(FilePath, Property)
 *		Gets a file property value.
 *	Parameters
 *		FilePath	- The full path of a file.
 *		Property	- Either the name or number of a property.
 *	Returns
 *		If succesful the file property value is returned. Otherwise:
 *		0			- The property is blank.
 *		-1			- The property name or number is not valid.
 */
FGP_Value(FilePath, Property) {
	static PropTable := FGP_Init()
	if ((PropNum := PropTable.Name[Property] != "" ? PropTable.Name[Property]
	: PropTable.Num[Property] ? Property : "") != "") {
		SplitPath, FilePath, FileName, DirPath
		oShell := ComObjCreate("Shell.Application")
		oFolder := oShell.NameSpace(DirPath)
		oFolderItem := oFolder.ParseName(FileName)
		if (PropVal := oFolder.GetDetailsOf(oFolderItem, PropNum))
			return PropVal
		return 0
	}
	return -1
}