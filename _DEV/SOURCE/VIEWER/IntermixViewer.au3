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

FUNCTION:.......... setup($sType)
DESCRIPTION:....... Install Intermix Client on the system.
SYNTAX:............ setup($sType = "/station"[)
PARAMETERS:........ [Optional] $sType = Define setup type, if it is a Server, station and/or quiet, default is "/station")

#ce ====================================================================================================
Func Setup($sType = "")

	;Hide GUI
	GUISetState(@SW_HIDE)

	;Control flags to guide the installation procedure
	Local $bQuiet = False
	Local $bUpdate = False

	;Set the installation Directory
	Local $g_sInstDir = @ProgramFilesDir & "\IntermixSupport\VIEWER\"

	;Check if the Script is running with admin privileges and set flags for cmdline parameters
	If IsAdmin() Then ; If is admin, set the parameter to variables

		If $sType == "/quiet" Then

			$bQuiet = True

		EndIf

	Else ;If not, run it as admin

		_deleteself($g_sWorkingPath, 1)
		DirRemove($g_sWorkingPath & "\", 1)
		ShellExecute(@ScriptFullPath, "/setup " & $sType, @ScriptDir, "runas")
		Exit

	EndIf

	; Disable Main GUI
	_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGUI)

	;If a previous version is already installed
	If $g_iVersion > $g_sInstVersion And $g_sSetupStatus Then

		; Show message about the update
		SplashTextOn($_g_sProgramTitle, $_g_sSplash_Update, 500, 50, -1, -1, 4, "Arial", 11)

		;Call Remove Function for update
		$bUpdate = Remove("/update")

		;Verify the update control flag
		If $bUpdate Then
			Sleep(3000)
		Else
			MsgBox(0, $_g_sProgramTitle, $_g_sMsgBox_UpdateFailed)
			Exit
		EndIf

		;disable de Splash Text
		SplashOff()

	;If is the same version, it is installed and Quiet
	ElseIf $g_iVersion = $g_sInstVersion And $g_iSetupStatus = 1 and $bQuiet Then
		_deleteself($g_sWorkingPath, 5)
		Exit
	EndIf

	;Show message about setup
	SplashTextOn($_g_sProgramTitle, $_g_sSplash_Setup, 500, 50, -1, -1, 4, "Arial", 11)


	;=== INSTALL FILES ======================================================================================
	DirCreate($g_sInstDir)

	FileInstall("files\viewer.ini", $g_sInstDir & "\viewer.ini", 1)
	FileInstall("files\SecureVNCPlugin.dsm", $g_sInstDir & "\SecureVNCPlugin.dsm", 1)
	FileInstall("files\unblock.js", $g_sInstDir & "\unblock.js", 1)
	FileInstall("files\First_Viewer_ClientAuth.pkey", $g_sInstDir & "\First_Viewer_ClientAuth.pkey", 1)

	If @OSVersion = "WIN_XP" or @OSVersion = "WIN_2003" Then
		FileInstall("files\vncviewer_xp.exe", $g_sInstDir & "\VNCViewer.exe", 1)
	Else
		FileInstall("files\vncviewer.exe", $g_sInstDir & "\VNCViewer.exe", 1)
	EndIf
	;========================================================================================================

	ShellExecuteWait($g_sInstDir & "\unblock.js", "", @ScriptDir, "")
	FileCopy(@ScriptDir & "\" & @ScriptName, $g_sInstDir & "\IntermixViewer.exe", 9)

	; Create Start Shortcuts
	DirCreate(@ProgramsCommonDir & "\Intermix Viewer\")
	FileCreateShortcut(@ProgramFilesDir & "\IntermixSupport\VIEWER\IntermixViewer.exe", @ProgramsCommonDir & "\Intermix Viewer\Intermix Viewer.lnk", "")
	FileCreateShortcut(@ProgramFilesDir & "\IntermixSupport\VIEWER\IntermixViewer.exe", @ProgramsCommonDir & "\Intermix Viewer\Uninstall Viewer.lnk", "", "/remove")

	; Create Desktop shortcut
	FileCreateShortcut(@ProgramFilesDir & "\IntermixSupport\VIEWER\IntermixViewer.exe", @DesktopCommonDir & "\INTERMIX VIEWER.lnk", "")

	; Read Registry Key for a possible existing installation
	Global $g_sInstDir = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Directory") ;Should contain the directory path
	Global $g_sInstExe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Program") ;Should contain the FULL path
	Global $g_sInstVersion = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Version"); Should contain a INT number for the version installed

	; Create Program Keys
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Directory", "REG_EXPAND_SZ", @ProgramFilesDir & "\IntermixSupport\VIEWER")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Program", "REG_EXPAND_SZ", @ProgramFilesDir & "\IntermixSupport\VIEWER\IntermixViewer.exe")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Version", "REG_SZ", $g_iVersion)

	;Create Control Panel Keys
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "DisplayIcon", "REG_SZ", '"' & $g_sInstDir & "\IntermixViewer.exe" & '",0')
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "DisplayName", "REG_SZ", $_g_sProgramName)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "DisplayVersion", "REG_SZ", $g_sVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "InstallLocation", "REG_SZ", $g_sInstDir)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "MajorVersion", "REG_DWORD", $g_sMajorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "MinorVersion", "REG_DWORD", $g_sMinorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "NoModify", "REG_DWORD", "0x00000001")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "NoRepair", "REG_DWORD", "0x00000001")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "Publisher", "REG_SZ", "Warp Code Ltda.")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "UninstallString", "REG_SZ", '"' & $g_sInstDir & "\IntermixViewer.exe" & '" /remove')
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "URLInfoAbout", "REG_SZ", "https://www.warpcode.com.br/intermix/")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "VersionMajor", "REG_DWORD", $g_sMajorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "VersionMinor", "REG_DWORD", $g_sMinorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "InstallDate", "REG_SZ", @MDAY & @MON & @YEAR)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "EstimatedSize", "REG_DWORD", "0x0000123D")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer", "sEstimatedSize2", "REG_DWORD", "0x00001233")

	;Verify System Language and Set ultravnc.ini permissions
	If @OSLang == "0416" Then
		RunWait('cacls \viewer.ini /e /g todos:f', $g_sInstDir, @SW_HIDE)
	Else
		RunWait('cacls \viewer.ini /e /g everyone:f', $g_sInstDir, @SW_HIDE)
	EndIf

	;Remove Splash Message
	SplashOff()

	;Asks User to restart the computer
	If $bQuiet Then
		MsgBox(0, $_g_sProgramTitle, $_g_sMsgBox_RestartCountQuiet, 10)
		Shutdown(6)
	Else
		If MsgBox(4, $_g_sProgramTitle, $_g_sMsgBox_NeedReboot) == 6 Then
			Run('shutdown /r /f /t 60 /c "' & $_g_sRestartWarning &'" /d P:4:2')
			Exit
		Else
			Exit
		EndIf
	EndIf
	Exit
EndFunc
;============> End setup() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... remove($sType = "")
DESCRIPTION:....... Remove Intermix Client from system
SYNTAX:............ remove($sType = "/quiet"[)
PARAMETERS:........ [Optional] $sType = Define removal type, if it is a quiet removal or update, default is "")

#ce ====================================================================================================
Func Remove($sType = "")

	;Local Flags
	Local $bQuiet = False
	Local $bUpdate = False
	Local $iResultAskRemove = 0

	;Verify if it is running under admin privileges and set flags
	If IsAdmin() Then
		If $sType == "/quiet" Then
			$bQuiet = True
		ElseIf $sType == "/update" Then
			$bUpdate = True
		EndIf
	Else
		ShellExecute(@ScriptFullPath, "/remove " & $sType, @ScriptDir, "runas")
		Exit
	EndIf

	;If not /quiet nor /update ask user
	If Not $bQuiet And Not $bUpdate Then
		$iResultAskRemove = MsgBox(4, $_g_sProgramTitle, $_g_sMsgBox_RemoveService)
	EndIf

	;If MsgBox returns "yes" or is /quiet or /update remove
	If $iResultAskRemove = 6 Or $bQuiet Or $bUpdate Then

		If Not $bQuiet Or Not $bUpdate Then
			; Show message about the uninstall
			SplashTextOn($_g_sProgramTitle, $_g_sSplash_Removing, 500, 50, -1, -1, 4, "Arial", 11)
		EndIf

		; Disable Main GUI
		_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGUI)

		; Remove shortcuts
		Local $ini_dir = @ProgramsCommonDir & "\Intermix Viewer\"
		Local $shortcut = @DesktopCommonDir & "\INTERMIX VIEWER.lnk"
		DirRemove($ini_dir, 1)
		FileDelete($shortcut)

		; Remove registry entries
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer")
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Intermix Viewer")

		;delete install directory
		If $bUpdate Then
			DirRemove($g_sInstDir & "\", 1)
		Else
			_deleteself(@ProgramFilesDir & "\IntermixSupport\VIEWER\", 5)
		EndIf

		If Not $bQuiet Or Not $bUpdate Then
			;Remove Splash Message
			SplashOff()
		EndIf

		;Asks User to restart the computer
		If $bQuiet Then
			MsgBox(0, $_g_sProgramTitle, $_g_sMsgBox_RestartCountQuiet, 10)
			Shutdown(6)
		ElseIf $bUpdate Then
			Return True
		Else
			If MsgBox(4, $_g_sProgramTitle, $_g_sMsgBox_NeedReboot) == 6 Then
				Run('shutdown /r /f /t 60 /c "' & $_g_sRestartWarning &'" /d P:4:2')
				Exit
			Else
				Exit
			EndIf
		EndIf
	Else

		Exit

	EndIf
EndFunc   ;==>remove
;============> End remove() ==============================================================



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