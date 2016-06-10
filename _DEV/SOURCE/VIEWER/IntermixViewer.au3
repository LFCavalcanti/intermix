#cs
========================================================

	INTERMIX SUPPORT
	VIEWER

	Author: Luiz Fernando Cavalcanti

	Created: 11/05/2015

	Edited: 09/06/2016

	Description:
	Script for the client, that users run to allow
	IT technicians to access and fix problems.

========================================================
#ce

#Region ### WRAPPER DIRECTIVES ###

#AutoIt3Wrapper_Icon=img\icon.ico
#AutoIt3Wrapper_Res_Fileversion=0.1.2
#AutoIt3Wrapper_Res_Productversion=0.1.2
#AutoIt3Wrapper_Res_Field=ProductName|Intermix Viewer
#AutoIt3Wrapper_Res_LegalCopyright=GPL3
#AutoIt3Wrapper_Res_Language=1046
#AutoIt3Wrapper_Res_Description=Remote Support tool for IT Pros

#AutoIt3Wrapper_Outfile=..\..\_TEST\IntermixViewer.exe

;============================ GUI ELEMENTS =======================================;
#AutoIt3Wrapper_Res_File_Add=img\logoIntermix.png, RT_RCDATA, IMG_LOGOINTERMIX, 0
#AutoIt3Wrapper_Res_File_Add=img\loginBar.png, RT_RCDATA, IMG_LOGINBAR, 0

#EndRegion ### WRAPPER DIRECTIVES ###

#region ### PRE-EXECUTION ###
; Disable the scripts ability to pause.
;~ Break(0)

; Verify if the Script is compiled
;~ If Not @Compiled Then
;~ 	MsgBox(0, "ERRO", "O Script deve ser compilado antes de ser iniciado!", 5)
;~ 	Exit
;~ EndIf
;~ #endregion ### PRE-EXECUTION ###

#region ### INCLUDES ###

#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <Array.au3>
#include ".\includes\ResourcesEx.au3"
#include ".\includes\MetroGUI_UDF.au3"
#include ".\includes\_language\textVariables.au3"

#endregion ### INCLUDES ###

#region ### VARIABLES ###

Global $g_sVersion = "0.1.2 ALPHA"
Global $_g_sLabel_VersionMain = "0.1.2 A"
Global $g_sMajorVersion = "0x00000001"
Global $g_sMinorVersion = "0x00000002"
Global $g_iVersion = 12
Global $g_bSetupStatus = False
Global $g_sWorkingPath = @AppDataDir & "\Intermix_Viewer_TMP"
Global $g_CmdParamTwo = ""
Global $g_bConnStatus = False
Global $g_bTmpFiles = False

Global $g_iNumId = 0

Global $g_sActiveUser = ""

#endregion ### VARIABLES ###

#region ### REGISTRY VARIABLES ###

; Read Registry Key for a possible existing installation
Global $g_sInstDir = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Directory") ;Should contain the directory path
Global $g_sInstExe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Program") ;Should contain the FULL path
Global $g_sInstVersion = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Version"); Should contain a INT number for the version installed

#endregion ### REGISTRY VARIABLES ###

#Region ### START UP ###

;~ CHECK IF THE SOFTWARE IS INSTALED IN THE SYSTEM
VerifySetupStatus()

;~ HANDLE COMMAND LINE PARAMETERS
HandleCmdLine()

; Set MetroUI UDF Theme
_SetTheme("Intermix")

#EndRegion ### START UP ###

#Region ### LOGIN ###

Login()

#EndRegion ### LOGIN ###



#cs FUNCTION ===========================================================================================

FUNCTION:.......... HandleCmdLine()
DESCRIPTION:....... Read command line parameters passed and calls the needed functions.
SYNTAX:............ No parameters passed, uses the cmdline from process calling, as follows:
					/setup = Execute all install procedures
					/remove = Execute all deinstall procedures
					/quiet = Supress all messages, does upgrade without asking if /setup is used

#ce ====================================================================================================
Func HandleCmdLine()

	; Verify if a second parameter is present and read it.
	If $cmdline[0] > 1 Then
		$g_CmdParamTwo = $cmdline[2]
	EndIf

	;Read and call the needed funtion
	If $cmdline[0] > 0 Then
		Switch $cmdline[1]

			Case "/setup"
;~ 				Setup($g_CmdParamTwo)

			Case "/remove"
;~ 				Remove($g_CmdParamTwo)

			Case Else
				MsgBox(0, $_g_sMsgBox_GeneralError, $_g_sMsgBox_UnknownParameter, 30)
				Exit
		EndSwitch
	EndIf
EndFunc
;============> End HandleCmdLine() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... verifySetupStatus()
DESCRIPTION:....... Verify the register parameters read and test if the aplication is already installed. If detecs server type setup, set ID flag to false.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func verifySetupStatus()

	If $g_sInstVersion > 0 And FileExists($g_sInstExe) Then ;Test VNC Service and program path
		$g_bSetupStatus = True
	EndIf

EndFunc
;============> End verifySetupStatus() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... handlerInstalledStatus()
DESCRIPTION:....... Handle the Setup Status, there are diferente situation, for example, when the
					Application is installed but the current instance is not the installed executable.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func HandleInstalledStatus()

	If $g_sInstExe == @AutoItExe Then;If the Script is running from the installed path

		$g_sWorkingPath = $g_sInstDir ;set the working path to the installed directory

	Else ; If the Instant Support is Installed but the Script is not Running from the installed directory

		If MsgBox(4, $_g_sProgramTitle, $_g_sMsgBox_OpenInstalled) = 6 Then
			Run($g_sInstExe) ; Run the installed exe
			Exit
		Else
			$g_iSetupStatus = False ;Define to the rest of the script, it's running as not installed
			ExtractTempFiles() ;If doesn't run the installed, run the current as portable.
		EndIf
	EndIf

EndFunc
;============> End handlerInstalledStatus() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... extractTempFiles()
DESCRIPTION:....... Extract files to a Temp Directory.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func ExtractTempFiles()
	; Extract files and create the TEMP work directory
	; Check if there is another temp directory created
	If FileExists(@AppDataDir & "\Intermix_Temp_Files") Then
		$g_sWorkingPath = @AppDataDir & "\Intermix_Viewer_TMP_" & Random(100000, 999999, 1)
	EndIf

	DirCreate($g_sWorkingPath)

	FileInstall("files\viewer.ini", $g_sWorkingPath & "\viewer.ini", 1)
	FileInstall("files\SecureVNCPlugin.dsm", $g_sWorkingPath & "\SecureVNCPlugin.dsm", 1)
	FileInstall("files\unblock.js", $g_sWorkingPath & "\unblock.js", 1)
	FileInstall("files\First_Viewer_ClientAuth.pkey", $g_sWorkingPath & "\First_Viewer_ClientAuth.pkey", 1)

	If @OSVersion = "WIN_XP" or @OSVersion = "WIN_2003" Then
		FileInstall("files\vncviewer_xp.exe", $g_sWorkingPath & "\VNCViewer.exe", 1)
	Else
		FileInstall("files\vncviewer.exe", $g_sWorkingPath & "\VNCViewer.exe", 1)
	EndIf

	ShellExecuteWait($g_sWorkingPath & "\unblock.js", "", @ScriptDir, "")

	FileCopy(@ScriptDir & "\" & @ScriptName, $g_sWorkingPath & "\IntermixViewer.exe", 9)

	$g_bTmpFiles = True ; => Control flag if there is temp files for this session

EndFunc
;============> End extractTempFiles()) ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... Login()
DESCRIPTION:....... Draws the a GUI to logon the user
SYNTAX:............ No parameters

#ce ====================================================================================================
Func Login()

	; Set MetroUI UDF Theme
	_SetTheme("Intermix")

	Local $sLabel_LoginTitle = "SERVER SETUP"

	Local $hLoginGUI = _Metro_CreateGUI($sLabel_LoginTitle, 350, 356, -1, -1, 1, 0)
	Local $GUI_HOVER_REG_LOGIN = $hLoginGUI[1]

	$hLoginGUI = $hLoginGUI[0]

	Local $idImg_LogoIntermixLogin = GUICtrlCreatePic("", 15, 24, 215, 48)
	_Resource_SetToCtrlID($idImg_LogoIntermixLogin, "IMG_LOGOINTERMIX")

	Local $idImg_BarLogin = GUICtrlCreatePic("", 0, 87, 350, 50)
	_Resource_SetToCtrlID($idImg_BarLogin, "IMG_LOGINBAR")

	Local $idLabel_User = GUICtrlCreateLabel($_g_sLabel_User, 15, 151, 150, 15)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	Local $idInput_User = GUICtrlCreateInput("", 15, 169, 320, 25)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, 0xBEBEBE)

	Local $idLabel_Password = GUICtrlCreateLabel($_g_sLabel_Password, 15, 204, 150, 15)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	Local $idInput_Password = GUICtrlCreateInput("", 15, 222, 320, 25,$ES_PASSWORD)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, 0xBEBEBE)

	Local $idButton_Cancel = _Metro_CreateButton($GUI_HOVER_REG_LOGIN, "CANCEL", 15, 277, 100, 30)

	Local $idButton_Login = _Metro_CreateButton($GUI_HOVER_REG_LOGIN, "OK", 235, 277, 100, 30)

	GUISetState(@SW_SHOW, $hLoginGUI)

	While 1

		If WinActive($hLoginGUI) Then

			_Metro_HoverCheck_Loop($GUI_HOVER_REG_LOGIN, $hLoginGUI)

			$MainMsg = GUIGetMsg()

			Switch $MainMsg

				Case $idButton_Cancel
					Exit

				Case $idButton_Login
					Exit

			EndSwitch

			Sleep(100)

		Else
			Sleep(200)
		EndIf

	WEnd

EndFunc
;============> End configGUI() =========================================================================