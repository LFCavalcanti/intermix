#cs
========================================================

	INTERMIX SUPPORT
	VIEWER

	Author: Luiz Fernando Cavalcanti

	Created: 11/05/2015

	Edited: 01/08/2016

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
#AutoIt3Wrapper_Res_Description=Intermix Viewer

#AutoIt3Wrapper_Outfile=..\..\_TEST\IntermixViewer.exe

;========================= STRIPPER DIRECTIVES ===================================
;~ #AutoIt3Wrapper_Run_Au3Stripper=y
;~ #Au3Stripper_Parameters=/so /rm /pe

;============================ GUI ELEMENTS =======================================
#AutoIt3Wrapper_Res_File_Add=img\logoIntermix.png, RT_RCDATA, IMG_LOGOINTERMIX, 0
#AutoIt3Wrapper_Res_File_Add=img\loginBar.png, RT_RCDATA, IMG_LOGINBAR, 0

#AutoIt3Wrapper_Res_File_Add=img\connect_c.png, RT_RCDATA, IMG_CONNECT_C, 0
#AutoIt3Wrapper_Res_File_Add=img\connect_h.png, RT_RCDATA, IMG_CONNECT_H, 0
#AutoIt3Wrapper_Res_File_Add=img\connect_s.png, RT_RCDATA, IMG_CONNECT_S, 0
#AutoIt3Wrapper_Res_File_Add=img\connect_r.png, RT_RCDATA, IMG_CONNECT_R, 0

#AutoIt3Wrapper_Res_File_Add=img\exit_c.png, RT_RCDATA, IMG_EXIT_C, 0
#AutoIt3Wrapper_Res_File_Add=img\exit_h.png, RT_RCDATA, IMG_EXIT_H, 0
#AutoIt3Wrapper_Res_File_Add=img\exit_s.png, RT_RCDATA, IMG_EXIT_S, 0

#AutoIt3Wrapper_Res_File_Add=img\list_c.png, RT_RCDATA, IMG_LIST_C, 0
#AutoIt3Wrapper_Res_File_Add=img\list_h.png, RT_RCDATA, IMG_LIST_H, 0
#AutoIt3Wrapper_Res_File_Add=img\list_s.png, RT_RCDATA, IMG_LIST_S, 0

#AutoIt3Wrapper_Res_File_Add=img\select_c.png, RT_RCDATA, IMG_SELECT_C, 0
#AutoIt3Wrapper_Res_File_Add=img\select_h.png, RT_RCDATA, IMG_SELECT_H, 0
#AutoIt3Wrapper_Res_File_Add=img\select_s.png, RT_RCDATA, IMG_SELECT_S, 0

#AutoIt3Wrapper_Res_File_Add=img\erase_c.png, RT_RCDATA, IMG_ERASE_C, 0
#AutoIt3Wrapper_Res_File_Add=img\erase_h.png, RT_RCDATA, IMG_ERASE_H, 0
#AutoIt3Wrapper_Res_File_Add=img\erase_s.png, RT_RCDATA, IMG_ERASE_S, 0

#AutoIt3Wrapper_Res_File_Add=img\id_i.png, RT_RCDATA, IMG_ID_I, 0
#AutoIt3Wrapper_Res_File_Add=img\listview_snip.png, RT_RCDATA, IMG_LIST_SNIP, 0

#AutoIt3Wrapper_Res_File_Add=img\repeater_bar.png, RT_RCDATA, IMG_REPEATER_BAR, 0
#AutoIt3Wrapper_Res_File_Add=img\server_bar.png, RT_RCDATA, IMG_SERVER_BAR, 0
#AutoIt3Wrapper_Res_File_Add=img\client_bar.png, RT_RCDATA, IMG_CLIENT_BAR, 0

#AutoIt3Wrapper_Res_File_Add=img\select_error.png, RT_RCDATA, IMG_SELECT_ERROR, 0
#AutoIt3Wrapper_Res_File_Add=img\select_lock.png, RT_RCDATA, IMG_SELECT_LOCK, 0
#AutoIt3Wrapper_Res_File_Add=img\select_ok.png, RT_RCDATA, IMG_SELECT_OK, 0

#EndRegion ### WRAPPER DIRECTIVES ###


#region ### PRE-EXECUTION ###
; Disable the scripts ability to pause.
;~ Break(0)

; Verify if the Script is compiled
;~ If Not @Compiled Then
;~ 	MsgBox(0, "ERRO", "O Script deve ser compilado antes de ser iniciado!", 5)
;~ 	Exit
;~ EndIf
#endregion ### PRE-EXECUTION ###


#region ### INCLUDES ###

#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <GuiComboBox.au3>
#include <Array.au3>
#include <TrayConstants.au3>
#include <ListViewConstants.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include ".\includes\ResourcesEx.au3"
#include ".\includes\MetroGUI_UDF.au3"
#include ".\includes\_language\textVariables.au3"

#endregion ### INCLUDES ###


#region ### VARIABLES ###

; ======== TEST DATA ARRAYs =============
Global $g_aClientTable [5][3]
Global $g_aRepeaterTable[6][5]
Global $g_aServerTable[6][5]
; =========================================

Global $g_sVersion = "0.1.2 ALPHA"
Global $g_sLabel_VersionMain = "0.1.2 A"
Global $g_sMajorVersion = "0x00000001"
Global $g_sMinorVersion = "0x00000002"
Global $g_iVersion = 12
Global $g_bSetupStatus = False
Global $g_sWorkingPath = @AppDataDir & "\Intermix_Viewer_TMP"
Global $g_CmdParamTwo = ""
Global $g_bConnStatus = False
Global $g_bTmpFiles = False

Global $g_sUserName = "Jhon Doe"

Global $g_iNumId = 0

Global $g_sActiveUser = ""

Global $g_hTrayInstall
Global $g_hTrayExit

Global $g_hMainGUI

Global $g_idButton_Main_WinClose
Global $g_idButton_Main_WinMinimize
Global $g_idButton_Main_Exit

Global $g_idListView_SelectItem

Global $g_idLabel_Main_UserName
Global $g_idInput_Main_IdNumber

Global $g_idLabel_Main_ClientName
Global $g_idLabel_Main_RepeaterName
Global $g_idLabel_Main_ServerName

Global $g_idButton_Main_ClientSelect
Global $g_idButton_Main_RepeaterSelect
Global $g_idButton_Main_ServerSelect
Global $g_idButton_Main_ClearId
Global $g_idButton_Main_Connect

Global $g_bGUIControl_Main_Hover = False
Global $g_bGUIControl_Main_Click = False
Global $g_hGUIControl_Main_IdHover

Global $g_bClient_Blocked = False
Global $g_bClient_Selected = False
Global $g_sClientIdSelected

Global $g_nRepeaterIdSelected
Global $g_bRepeater_Selected = False
Global $g_bRepeater_Error = False

Global $g_nServerIdSelected
Global $g_bServer_Selected = False
Global $g_bServer_Error = False

Global $g_bIdReady = False

Global $g_bDoubleClick

#endregion ### VARIABLES ###


#region ### REGISTRY VARIABLES ###

; Read Registry Key for a possible existing installation
Global $g_sInstDir = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Directory") ;Should contain the directory path
Global $g_sInstExe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Program") ;Should contain the FULL path
Global $g_sInstVersion = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Viewer", "Version"); Should contain a INT number for the version installed

#endregion ### REGISTRY VARIABLES ###


#Region ### START UP ###

;~ TEST DATA TABLES
TestData()

;~ CHECK IF THE SOFTWARE IS INSTALED IN THE SYSTEM
VerifySetupStatus()

;~ HANDLE COMMAND LINE PARAMETERS
HandleCmdLine()

; Set MetroUI UDF Theme
_SetTheme("Intermix")

#EndRegion ### START UP ###


#Region ### LOGIN ###

;~ Login()

#EndRegion ### LOGIN ###


#Region ### START PROCEDURES

;Calls the MainGUI
MainGUI()

; Enable the scripts ability to pause. (otherwise tray menu is disabled)
Break(1)

; Create the tray icon. Default tray menu items (Script Paused/Exit) will not be shown.
Opt("TrayMenuMode", 1)
If Not $g_bSetupStatus Then
	$g_hTrayInstall = TrayCreateItem($_g_sTray_ButtonInstall)
EndIf
$g_hTrayExit = TrayCreateItem($_g_sTray_ButtonExit)

#EndRegion ### START PROCEDURES ###


#Region ### MAIN LOOP ###
; Main Loop
While 1

	If WinActive($g_hMainGUI) Then

		; Get mouse info
		Local $aMouseInfo = GUIGetCursorInfo($g_hMainGUI)

		_Metro_HoverCheck_Loop($g_hMainGUI)

		Local $hMainMsg = GUIGetMsg()

		;========================== CLICK LOOP FOR CONTROL BUTTONS ==========================
		Switch $hMainMsg
			Case $GUI_EVENT_CLOSE, $g_idButton_Main_WinClose
				GUISetState(@SW_MINIMIZE,$g_hMainGUI)
				GUISetState(@SW_HIDE,$g_hMainGUI)
;~ 				CloseSupport()
;~ 				Exit
			Case $g_idButton_Main_WinMinimize
				GUISetState(@SW_MINIMIZE,$g_hMainGUI)
		EndSwitch
		;======================================================================================

		; ========================= HOVER OTHER BUTTONS =======================================
		; Prevent overuse of ListView on Click
		If $g_bGUIControl_Main_Click Then
			Sleep(100)
			$g_bGUIControl_Main_Click = False
			ContinueLoop
		EndIf

		;Prevents a control with cursor hovering from updating to standard icon
		If $aMouseInfo[4] = $g_hGUIControl_Main_IdHover Then
			$g_bGUIControl_Main_Hover = False
		EndIf

		;Returns standard icon when control if cursor is not hovering
		If $g_bGUIControl_Main_Hover Then

			Switch $g_hGUIControl_Main_IdHover

				; CLIENT SELECT
				case $g_idButton_Main_ClientSelect
					If $g_bClient_Blocked Then
						_Resource_SetToCtrlID($g_idButton_Main_ClientSelect, "IMG_SELECT_ERROR")
					ElseIf $g_bClient_Selected Then
						_Resource_SetToCtrlID($g_idButton_Main_ClientSelect, "IMG_SELECT_OK")
					Else
						_Resource_SetToCtrlID($g_idButton_Main_ClientSelect, "IMG_LIST_S")
					EndIf
					$g_bGUIControl_Main_Hover = False

				; REPEATER SELECT
				case $g_idButton_Main_RepeaterSelect
					If $g_bRepeater_Error Then
						_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_ERROR")
					ElseIf $g_bRepeater_Selected Then
						_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_OK")
					ElseIf $g_bClient_Selected Then
						_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_LIST_S")
					Else
						_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_LOCK")
					EndIf
					$g_bGUIControl_Main_Hover = False

				; SERVER SELECT
				case $g_idButton_Main_ServerSelect
					If $g_bServer_Error Then
						_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_SELECT_ERROR")
					ElseIf $g_bServer_Selected Then
						_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_SELECT_OK")
					ElseIf $g_bClient_Selected Then
						_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_LIST_S")
					Else
						_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_SELECT_LOCK")
					EndIf
					$g_bGUIControl_Main_Hover = False

				; CLEAR ID
				case $g_idButton_Main_ClearId
					_Resource_SetToCtrlID($g_idButton_Main_ClearId, "IMG_ERASE_S")
					$g_bGUIControl_Main_Hover = False

				; CONNECT
				case $g_idButton_Main_Connect
					_Resource_SetToCtrlID($g_idButton_Main_Connect, "IMG_CONNECT_S")
					$g_bGUIControl_Main_Hover = False

				; EXIT
				case $g_idButton_Main_Exit
					_Resource_SetToCtrlID($g_idButton_Main_Exit, "IMG_EXIT_S")
					$g_bGUIControl_Main_Hover = False

			EndSwitch

			Sleep(20)

		EndIf

		; Check cursor hovering over controls
		Switch $aMouseInfo[4]

			; CLIENT SELECT
			case $g_idButton_Main_ClientSelect
				_Resource_SetToCtrlID($g_idButton_Main_ClientSelect, "IMG_LIST_H")
				$g_hGUIControl_Main_IdHover = $g_idButton_Main_ClientSelect
				$g_bGUIControl_Main_Hover = True
				Sleep(20)

			; REPEATER SELECT
			case $g_idButton_Main_RepeaterSelect
				If $g_bClient_Selected Then
					_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_LIST_H")
					$g_hGUIControl_Main_IdHover = $g_idButton_Main_RepeaterSelect
					$g_bGUIControl_Main_Hover = True
				EndIf
				Sleep(20)

			; SERVER SELECT
			case $g_idButton_Main_ServerSelect
				If $g_bClient_Selected Then
					_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_LIST_H")
					$g_hGUIControl_Main_IdHover = $g_idButton_Main_ServerSelect
					$g_bGUIControl_Main_Hover = True
				EndIf
				Sleep(20)

			; CLEAR ID
			case $g_idButton_Main_ClearId
				If $g_bClient_Selected Then
					_Resource_SetToCtrlID($g_idButton_Main_ClearId, "IMG_ERASE_H")
					$g_hGUIControl_Main_IdHover = $g_idButton_Main_ClearId
					$g_bGUIControl_Main_Hover = True
				EndIf
				Sleep(20)

			; CONNECT
			case $g_idButton_Main_Connect
				If $g_bClient_Selected And $g_bRepeater_Selected And ($g_bServer_Selected Or $g_bIdReady) Then
					_Resource_SetToCtrlID($g_idButton_Main_Connect, "IMG_CONNECT_H")
					$g_hGUIControl_Main_IdHover = $g_idButton_Main_Connect
					$g_bGUIControl_Main_Hover = True
				EndIf
				Sleep(20)

			; EXIT
			case $g_idButton_Main_Exit
				_Resource_SetToCtrlID($g_idButton_Main_Exit, "IMG_EXIT_H")
				$g_hGUIControl_Main_IdHover = $g_idButton_Main_Exit
				$g_bGUIControl_Main_Hover = True
				Sleep(20)

		EndSwitch
		;======================================================================================


		; ========================== DETECTS MOUSE CLICKS =============================================
		If $aMouseInfo[2] = 1 Then

			Switch $aMouseInfo[4]

				; Clear ID
				Case $g_idButton_Main_ClearId
					If $g_bClient_Selected Then
						_Resource_SetToCtrlID($g_idButton_Main_ClearId, "IMG_ERASE_C")
						Sleep(50)
						GUICtrlSetData($g_idInput_Main_IdNumber, "")
						SelectServer(True)
						_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_LIST_S")
;~ 						GUICtrlSetState($g_idInput_Main_IdNumber, $GUI_ENABLE)
					EndIf

				; Connect
				Case $g_idButton_Main_Connect
					If $g_bClient_Selected And $g_bRepeater_Selected And ($g_bServer_Selected Or $g_bIdReady) Then
						_Resource_SetToCtrlID($g_idButton_Main_Connect, "IMG_CONNECT_C")
						Sleep(50)
					EndIf

				; Select Client
				Case $g_idButton_Main_ClientSelect
					_Resource_SetToCtrlID($g_idButton_Main_ClientSelect, "IMG_SELECT_C")
					Sleep(50)
					SelectClient()

				; Select Repeater
				Case $g_idButton_Main_RepeaterSelect
					If $g_bClient_Selected Then
						_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_C")
						Sleep(50)
						SelectRepeater()
					EndIf

				;Select Server
				Case $g_idButton_Main_ServerSelect
					If $g_bClient_Selected Then
						_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_SELECT_C")
						Sleep(50)
						SelectServer()
					EndIf

				; Exit Button
				Case $g_idButton_Main_Exit
					_Resource_SetToCtrlID($g_idButton_Main_Exit, "IMG_EXIT_C")
					Sleep(50)
					Exit

			EndSwitch

		EndIf

		ContinueLoop

	EndIf

	#Region ### TRAY EVENTS ###
	; Tray events.
	Local $hTrayMsg = TrayGetMsg()

	If $g_bSetupStatus Then
		Switch $hTrayMsg
			Case $g_hTrayExit
;~ 				Closesupport()
				Exit
			Case $TRAY_EVENT_PRIMARYDOUBLE
				GUISetState(@SW_RESTORE,$g_hMainGUI)
				GUISetState(@SW_SHOW,$g_hMainGUI)
		EndSwitch
	Else
		Switch $hTrayMsg
			Case $g_hTrayInstall
				Setup()
			Case $g_hTrayExit
;~ 				Closesupport()
				Exit
			Case $TRAY_EVENT_PRIMARYDOUBLE
				GUISetState(@SW_RESTORE,$g_hMainGUI)
				GUISetState(@SW_SHOW,$g_hMainGUI)
		EndSwitch
	EndIf
	#EndRegion ### TRAY EVENTS ###

	Sleep(50)

WEnd

#EndRegion ### MAIN LOOP ###



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
				Setup($g_CmdParamTwo)

			Case "/remove"
				Remove($g_CmdParamTwo)

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

	If $g_sInstVersion > 0 And FileExists($g_sInstExe) Then ;Test program path
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
	If FileExists(@AppDataDir & "\Intermix_Viewer_TMP") Then
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
;~ 	_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGUI)

	;If a previous version is already installed
	If $g_iVersion > $g_sInstVersion And $g_bSetupStatus Then

		; Show message about the update
		SplashTextOn($_g_sProgramTitle, $_g_sSplash_Update, 500, 50, -1, -1, 4, "Arial", 11)

		;Call Remove Function for update
		$bUpdate = Remove("/update")

		;Verify the update control flag
		If $bUpdate Then
			Sleep(3000)
			;disable de Splash Text
			SplashOff()
		Else
			MsgBox(0, $_g_sProgramTitle, $_g_sMsgBox_UpdateFailed)
			Exit
		EndIf

	;If is the same version, it is installed and Quiet
	ElseIf $g_iVersion = $g_sInstVersion And $g_bSetupStatus = 1 and $bQuiet Then
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
;~ 		_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGUI)

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

FUNCTION:.......... CloseSupport()
DESCRIPTION:....... Stop services, process and exit aplication
SYNTAX:............ No parameters

#ce ====================================================================================================
Func CloseSupport()

	If $g_bSetupStatus Then

		Exit

	Else
		If MsgBox(4, $_g_sProgramTitle, $_g_sMsgBox_CloseSupport) = 6 Then
			; Disable Main GUI
;~ 			_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGUI)
			SplashTextOn($_g_sProgramTitle, $_g_sSplash_ClosingSupport, 500, 50, -1, -1, 4, "Arial", 11)
			_deleteself($g_sWorkingPath, 1)
			DirRemove($g_sWorkingPath & "\", 1)
			Exit
		EndIf

	EndIf

EndFunc
;============> CloseSupport() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... Func _deleteself($sDeletePath, $idelay = 5)
DESCRIPTION:....... FStop services, process and exit aplication
SYNTAX:............ Func _deleteself($sDeletePath, $idelay = 5[)
PARAMETERS:........ $sDeletePath - path where files where extracted
					[Optional] $idelay - Time delay to execute operation, Default is 5.

#ce ====================================================================================================
Func _deleteself($sDeletePath, $idelay = 5)

	Local $sDelay = ''
	Local $iInternalDelay = 2
	Local $sAppID = $sDeletePath & "\IntermixViewer.exe"
	Local $sImageName = 'IMAGENAME'

    $iDelay = Int($iDelay)
    If $iDelay > 0 Then
        $sDelay = 'IF %TIMER% GTR ' & $iDelay & ' GOTO DELETE'
    EndIf

	Local $scmdfile
	FileDelete(@TempDir & "\scratch.bat")
	$scmdfile = 'SET TIMER=0' & @CRLF _
				& ':START' & @CRLF _
				& "PING -n " & $idelay & " 127.0.0.1 > nul" & @CRLF _
				& $sDelay & @CRLF _
				& 'SET /A TIMER+=1' & @CRLF _
				& @CRLF _
				& 'TASKLIST /NH /FI "' & $sImageName & ' EQ ' & $sAppID & '" | FIND /I "' & $sAppID & '" >nul && GOTO START' & @CRLF _
				& 'GOTO DELETE' & @CRLF _
				& @CRLF _
				& ':DELETE' & @CRLF _
				& 'TASKKILL /F /FI "' & $sImageName & ' EQ ' & $sAppID & '"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\IntermixViewer.exe"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\SecureVNCPlugin.dsm"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\viewer.ini"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\unblock.js"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\VNCViewer.exe"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\First_Viewer_ClientAuth.pkey"' & @CRLF _
				& 'RD /S /Q "' & $sDeletePath & '"' & @CRLF _
				& 'IF EXIST "' & $sDeletePath & '" GOTO DELETE' & @CRLF _
				& 'GOTO END' & @CRLF _
				& @CRLF _
				& ':END' & @CRLF _
				& 'DEL "' & @TempDir & '\scratch.bat"'
	FileWrite(@TempDir & "\scratch.bat", $scmdfile)
	Return Run(@TempDir & "\scratch.bat", @TempDir, @SW_HIDE)
EndFunc   ;==>_deleteself
;============> _deleteself() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... Login()
DESCRIPTION:....... Draws the a GUI to logon the user
SYNTAX:............ No parameters

#ce ====================================================================================================
Func Login()

	; Set MetroUI UDF Theme
	_SetTheme("Intermix")

	Local $sLabel_LoginTitle = "SERVER SETUP"

	Local $hLoginGUI = _Metro_CreateGUI($sLabel_LoginTitle, 350, 356, -1, -1, False, True)

	Local $idImg_LogoIntermixLogin = GUICtrlCreatePic("", 15, 24, 215, 48)
	_Resource_SetToCtrlID($idImg_LogoIntermixLogin, "IMG_LOGOINTERMIX")

	Local $idImg_BarLogin = GUICtrlCreatePic("", 0, 87, 350, 50)
	_Resource_SetToCtrlID($idImg_BarLogin, "IMG_LOGINBAR")

	Local $idLabel_User = GUICtrlCreateLabel($_g_sLabel_User, 15, 151, 150, 15)
	GUICtrlSetFont(-1, 12, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	Local $idInput_User = GUICtrlCreateInput("", 15, 169, 320, 25, $ES_CENTER, $WS_EX_WINDOWEDGE)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, 0xBEBEBE)

	Local $idLabel_Password = GUICtrlCreateLabel($_g_sLabel_Password, 15, 204, 150, 15)
	GUICtrlSetFont(-1, 12, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	Local $idInput_Password = GUICtrlCreateInput("", 15, 222, 320, 25,BitOR($ES_PASSWORD, $ES_CENTER), $WS_EX_WINDOWEDGE)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, 0xBEBEBE)

	Local $idButton_Cancel = _Metro_CreateButton("CANCEL", 15, 277, 100, 30)

	Local $idButton_Login = _Metro_CreateButton("LOGIN", 235, 277, 100, 30)

	GUISetState(@SW_SHOW, $hLoginGUI)

	While 1

		If WinActive($hLoginGUI) Then

			_Metro_HoverCheck_Loop($hLoginGUI)

			$MainMsg = GUIGetMsg()

			Switch $MainMsg

				Case $idButton_Cancel
					Exit

				Case $idButton_Login
					_Metro_GUIDelete($hLoginGUI)
					Return

			EndSwitch

			Sleep(100)

		Else
			Sleep(100)
		EndIf

	WEnd

EndFunc
;============> End configGUI() =========================================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... MainGUI()
DESCRIPTION:....... Draws the main GUI
SYNTAX:............ No parameters

#ce ====================================================================================================
Func MainGUI()

	Local $aControlButtons
	Local $logoIntermixMain
	Local $idLabel_ViewerTitle
	Local $idLabel_Version
	Local $idImg_ClientBar
	Local $idImg_RepeaterBar
	Local $idImg_ServerBar
	Local $idImg_IdIcon

	;=== GUI Create ===================================================
	$g_hMainGUI = _Metro_CreateGUI($_g_sProgramTitle, 400, 465, -1, -1, False, True)

	$aControlButtons = _Metro_AddControlButtons(True, False, True, False, False)

	$g_idButton_Main_WinClose = $aControlButtons[0]
	$g_idButton_Main_WinMinimize = $aControlButtons[3]
	;=====================================================================

	;=== Header ========================================================
	$logoIntermixMain = GUICtrlCreatePic("", 15, 24, 217, 48)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($logoIntermixMain, "IMG_LOGOINTERMIX")

	$idLabel_ViewerTitle = GUICtrlCreateLabel("VIEWER", 270, 29, 115, 28)
	GUICtrlSetFont(-1, 22, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	$idLabel_Version = GUICtrlCreateLabel($g_sLabel_VersionMain, 275, 62, 50, 15)
	GUICtrlSetFont(-1, 10, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	;====================================================================

	;=== Exit & Username ================================================
	$g_idButton_Main_Exit = GUICtrlCreatePic("", 10, 83, 46, 40)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($g_idButton_Main_Exit, "IMG_EXIT_S")

	$g_idLabel_Main_UserName = GUICtrlCreateLabel($g_sUserName, 58, 95, 73, 15)
	GUICtrlSetFont(-1, 12, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	;====================================================================

	;=== Client Selection ===============================================
	$idImg_ClientBar = GUICtrlCreatePic("", 15, 143, 324, 40)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($idImg_ClientBar, "IMG_CLIENT_BAR")

	$g_idLabel_Main_ClientName = GUICtrlCreateLabel("", 61, 146, 278, 38, $SS_CENTER, $WS_EX_WINDOWEDGE)
	GUICtrlSetFont(-1, 20, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)


	$g_idButton_Main_ClientSelect = GUICtrlCreatePic("", 339, 143, 46, 40)
	_Resource_SetToCtrlID($g_idButton_Main_ClientSelect, "IMG_LIST_S")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	;=====================================================================

	;=== Repeater Selection ==============================================
	$idImg_RepeaterBar = GUICtrlCreatePic("", 15, 203, 324, 40)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($idImg_RepeaterBar, "IMG_REPEATER_BAR")

	$g_idLabel_Main_RepeaterName = GUICtrlCreateLabel("", 61, 206, 278, 38, $SS_CENTER, $WS_EX_WINDOWEDGE)
	GUICtrlSetFont(-1, 20, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	$g_idButton_Main_RepeaterSelect = GUICtrlCreatePic("", 339, 203, 46, 40)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_LOCK")
	;=====================================================================

	;=== Server Select ===================================================
	$idImg_ServerBar = GUICtrlCreatePic("", 15, 263, 324, 40)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($idImg_ServerBar, "IMG_SERVER_BAR")

	$g_idLabel_Main_ServerName = GUICtrlCreateLabel("", 61, 266, 278, 38, $SS_CENTER, $WS_EX_WINDOWEDGE)
	GUICtrlSetFont(-1, 20, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	$g_idButton_Main_ServerSelect = GUICtrlCreatePic("", 339, 263, 46, 40)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_SELECT_LOCK")
	;=====================================================================


	;=== ID Input ========================================================
	$idImg_IdIcon = GUICtrlCreatePic("", 15, 323, 46, 40)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($idImg_IdIcon, "IMG_ID_I")

	$g_idInput_Main_IdNumber = GUICtrlCreateInput("", 61, 323, 278, 40,BitOR($ES_NUMBER,$ES_CENTER),$WS_EX_WINDOWEDGE)
	GUICtrlSetFont(-1, 24, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, 0xCCCCCC)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetLimit(-1, 6)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	$g_idButton_Main_ClearId = GUICtrlCreatePic("", 339, 323, 46, 40)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($g_idButton_Main_ClearId, "IMG_ERASE_S")
	;=====================================================================

	;=== Connect Button ==================================================
	$g_idButton_Main_Connect = GUICtrlCreatePic("", 249, 403, 136, 40)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	_Resource_SetToCtrlID($g_idButton_Main_Connect, "IMG_CONNECT_S")
	;=====================================================================


	GUISetState(@SW_SHOW, $g_hMainGUI)

EndFunc
;============> End mainGUI() ===========================================================================



#cs FUNCTION ==============================================================================================

FUNCTION:.......... SelectItem()
DESCRIPTION:....... Draws the ListView and returns the value selected.
SYNTAX:............ SelectItem($hGUIHandle, $idButtonControl, $aDataList)
PARAMETERS:........ $hGUIHandle			- The handle of the GUI.
					$idButtonControl	- Handler of the Button control to use.
					$aDataList			- Array containing the data to be searched and/or displayed
RETURN VALUES:..... String				- String containing the value chosen by the user.

#ce =======================================================================================================
Func SelectItem(ByRef $hGUIHandle, ByRef $idButtonControl, ByRef $aDataList)

;~ 	Local $g_idListView_SelectItem
	Local $aCurrentWinPosition[4]
	Local $aCurrentButtonPosition[4]
	Local $idImg_ListSnip
	Local $nIndex = 0
	Local $bSelectControl = False

	;Get position and resize Window
	$aCurrentWinPosition = WinGetPos($hGUIHandle)
	WinMove($hGUIHandle, "", $aCurrentWinPosition[0], $aCurrentWinPosition[1], 680, 465, 30)
	Sleep(30)

	;Get Button position and create the Snip image
	$aCurrentButtonPosition = ControlGetPos("", "", $idButtonControl)
	$idImg_ListSnip = GUICtrlCreatePic("", 385, $aCurrentButtonPosition[1], 15, 40)
	_Resource_SetToCtrlID($idImg_ListSnip, "IMG_LIST_SNIP")

	;Creates the ListView
	$g_idListView_SelectItem = GUICtrlCreateListView("", 400, 35, 265, 415,BitOR($LVS_REPORT,$LVS_NOCOLUMNHEADER,$LVS_SINGLESEL), $WS_EX_WINDOWEDGE)
	GUICtrlSetBkColor(-1, 0xBEBEBE)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetFont(-1, 14, 400,"","Arial",5)

	_ArraySort($aDataList)

	;Add Items to ListView
	_GUICtrlListView_InsertColumn($g_idListView_SelectItem, 0, "Client", 245, 0)
	While $nIndex < UBound($aDataList)
		_GUICtrlListView_AddItem($g_idListView_SelectItem, $aDataList[$nIndex])
		$nIndex += 1
	WEnd
	$nIndex = 0

	;Change the button to the select indication
	_Resource_SetToCtrlID($idButtonControl, "IMG_SELECT_S")

	; Register "Click on ListView function"
	GUIRegisterMsg($WM_NOTIFY, "DoubleClick")

	While 1

		; Normal GUIGetMsg() code

		; Check if mouse has doubleclicked
		If $g_bDoubleClick Then
			ConsoleWrite("DOUBLE CLICK" & @CRLF)
			$g_bDoubleClick = False
			$sSelectItem = _GUICtrlListView_GetItemTextString($g_idListView_SelectItem, -1)
			$bSelectControl = True
		EndIf

		; Get mouse info
		Local $aMouseInfo = GUIGetCursorInfo($g_hMainGUI)

		; Hover effect on button
		If $aMouseInfo[4] = $idButtonControl Then
			_Resource_SetToCtrlID($idButtonControl, "IMG_SELECT_H")
		Else
			_Resource_SetToCtrlID($idButtonControl, "IMG_SELECT_S")
		EndIf

		; Detects mouse click on control button
		If $aMouseInfo[2] = 1 Then

			;If click on Button Control
			If $aMouseInfo[4] = $idButtonControl Then
				_Resource_SetToCtrlID($idButtonControl, "IMG_SELECT_C")
				$sSelectItem = _GUICtrlListView_GetItemTextString($g_idListView_SelectItem, -1)
				$bSelectControl = True
			EndIf

		EndIf

		If $bSelectControl Then

			;Delete GUI Controls
			GUICtrlDelete($g_idListView_SelectItem)
			GUICtrlDelete($idImg_ListSnip)

			;Get position and resize Window
			$aCurrentWinPosition = WinGetPos($hGUIHandle)
			WinMove($hGUIHandle, "", $aCurrentWinPosition[0], $aCurrentWinPosition[1], 400, 465, 30)

			; Deregister "Click on ListView function"
			GUIRegisterMsg($WM_NOTIFY, "")

			;Return the String with the selected item
			Return $sSelectItem

		Else
			Sleep(100)
		EndIf

	WEnd

EndFunc
;============> End SelectItem() ===========================================================================



#cs FUNCTION ==============================================================================================

FUNCTION:.......... SelectClient()
DESCRIPTION:....... Gets Client Data and call menu list to select one
SYNTAX:............ SelectClient()

#ce =======================================================================================================
Func SelectClient()

	Local $nIndex = 0
	Local $aClientNames[1]
	Local $sSelectedClient
	Local $nClientIdx

	ReDim $aClientNames[UBound($aClientNames) + UBound($g_aClientTable) -1]

	While $nIndex < UBound($g_aClientTable)
		$aClientNames[$nIndex] = $g_aClientTable[$nIndex][1]
		$nIndex += 1
	WEnd

	;Call GUI for ListView
	$sSelectedClient = SelectItem($g_hMainGUI, $g_idButton_Main_ClientSelect, $aClientNames)

	; If user press button without selecting item, stop function
	If $sSelectedClient = "" Then
		GUICtrlSetData($g_idLabel_Main_ClientName, "")
		$g_bGUIControl_Main_Click = True
		$g_bClient_Selected = False
		$g_bClient_Blocked = False
		SelectRepeater(False, False, True)
		SelectServer(True)
		_Resource_SetToCtrlID($g_idButton_Main_ClientSelect, "IMG_LIST_S")
		_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_LOCK")
		_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_SELECT_LOCK")
		Return
	EndIf

	$nClientIdx = _ArraySearch($g_aClientTable, $sSelectedClient, 0, 0, 0, 0, 1, 1)

	GUICtrlSetData($g_idLabel_Main_ClientName, $g_aClientTable[$nClientIdx][1])

	If $g_aClientTable[$nClientIdx][2] Then
		$g_bClient_Selected = True
		$g_bClient_Blocked = False
		$g_sClientIdSelected = $g_aClientTable[$nClientIdx][0]
		_Resource_SetToCtrlID($g_idButton_Main_ClientSelect, "IMG_SELECT_OK")
		_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_LIST_S")
		_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_LIST_S")
		SelectRepeater(True)
	Else
		$g_bClient_Selected = False
		$g_bClient_Blocked = True
		SelectRepeater(False, False, True)
		SelectServer(True)
		_Resource_SetToCtrlID($g_idButton_Main_ClientSelect, "IMG_SELECT_ERROR")
		_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_LOCK")
		_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_SELECT_LOCK")
	EndIf

	$g_bGUIControl_Main_Click = True

EndFunc
;============> End SelectClient() ===========================================================================



#cs FUNCTION ==============================================================================================

FUNCTION:.......... SelectRepeater()
DESCRIPTION:....... Gets Client Data and call menu list to select one
SYNTAX:............ SelectRepeater($bClientFastSelect, $bServerFastSelect, $bClearRepeater, $nServerIdRepeater)
PARAMETERS:........	[Optional] $bClientFastSelect 	- Define if the first repeater of the cliente is selected and applied to GUI, Default = False
					[Optional] $bServerFastSelect	- Define if the repeater will be selected as per the selected server, then applied to GUI, Default = False
					[Optional] $bClearRepeater		- Clear the Repeater selecion, Default is False
					[Optional] $nServerIdRepeater	- ID of the Repeater for the server If $bServerFastSelect = True, Default = 0
#ce =======================================================================================================
Func SelectRepeater($bClientFastSelect = False, $bServerFastSelect = False, $bClearRepeater = False, $nServerIdRepeater = 0)

	Local $nIndex = 0
	Local $aRepeaterNames[1]
	Local $sSelectedRepeater
	Local $nRepeaterIdx
	Local $bTestResult = False

	; Clear Repeater Select
	If $bClearRepeater Then
		GUICtrlSetData($g_idLabel_Main_RepeaterName, "")
		_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_LOCK")
		$g_nRepeaterIdSelected = ""
		$g_bRepeater_Selected = False
		$g_bRepeater_Error = False
		GUICtrlSetState($g_idInput_Main_IdNumber, $GUI_DISABLE)
		If $g_bServer_Error or $g_bServer_Selected Then
				SelectServer(True)
		EndIf
		Return
	EndIf

	;Get Array position of Central Repeaters
	Local $aCentralRepeaters = _ArrayFindAll($g_aRepeaterTable, "0", 0, 0, 0, 0, 1)

	;Get Array position of Selected Customer Repeaters
	Local $aClientRepeaters = _ArrayFindAll($g_aRepeaterTable, $g_sClientIdSelected, 0, 0, 0, 0, 1)

	If $bClientFastSelect Then

		;Set the selected Repeater as the first related to the select CLIENT
		$g_nRepeaterIdSelected = $g_aRepeaterTable[$aClientRepeaters[0]][0]

		;Test connection with the first repeater for that client
		$bTestResult = TestConnection($g_aRepeaterTable[$aClientRepeaters[0]][3], $g_aRepeaterTable[$aClientRepeaters[0]][4])

		;Set Repeater name in Label on GUI
		GUICtrlSetData($g_idLabel_Main_RepeaterName, $g_aRepeaterTable[$aClientRepeaters[0]][2])

	ElseIf $bServerFastSelect Then

		;Get the Repeater index from the array
		Local $nServerArrayIdx = _ArraySearch($g_aRepeaterTable, $nServerIdRepeater, 0, 0, 0, 0, 1, 0)

		;Set the selected Repeater as the repeater related to the select SERVER
		$g_nRepeaterIdSelected = $nServerIdRepeater

		; Test connection with the repeater linked with the server
		$bTestResult = TestConnection($g_aRepeaterTable[$nServerArrayIdx][3], $g_aRepeaterTable[$nServerArrayIdx][4])

		;Set Repeater name in Label on GUI
		GUICtrlSetData($g_idLabel_Main_RepeaterName, $g_aRepeaterTable[$nServerArrayIdx][2])

	Else

		ReDim $aRepeaterNames[UBound($aRepeaterNames) + UBound($aClientRepeaters) -1]

		; Get names of Client related Repeaters
		While $nIndex < UBound($aClientRepeaters)
			$aRepeaterNames[$nIndex] = $g_aRepeaterTable[$aClientRepeaters[$nIndex]][2]
			$nIndex += 1
		WEnd
		$nIndex = 0
		_ArraySort($aRepeaterNames)

		; Get names of general repeaters
		While $nIndex < UBound($aCentralRepeaters)
			_ArrayAdd($aRepeaterNames, $g_aRepeaterTable[$aCentralRepeaters[$nIndex]][2])
			$nIndex += 1
		WEnd
		$nIndex = 0

		;Call GUI for ListView
		$sSelectedRepeater = SelectItem($g_hMainGUI, $g_idButton_Main_RepeaterSelect, $aRepeaterNames)

		; If user press button without selecting item, stop function
		If $sSelectedRepeater = "" Then
			GUICtrlSetData($g_idLabel_Main_RepeaterName, "")
			$g_nRepeaterIdSelected = ""
			$g_bGUIControl_Main_Click = True
			$g_bRepeater_Selected = False
			$g_bRepeater_Error = False
			_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_LIST_S")
			GUICtrlSetState($g_idInput_Main_IdNumber, $GUI_DISABLE)
			If $g_bServer_Error or $g_bServer_Selected Then
				SelectServer(True)
			EndIf
			Return

		Else
			;Get the Repeater index from the array
			Local $nRepeaterArrayIdx = _ArraySearch($g_aRepeaterTable, $sSelectedRepeater, 0, 0, 0, 0, 1, 2)

			;Set the selected Repeater as the repeater related to the select SERVER
			$g_nRepeaterIdSelected = $g_aRepeaterTable[$nRepeaterArrayIdx][0]

			; Test connection with the repeater linked with the server
			$bTestResult = TestConnection($g_aRepeaterTable[$nRepeaterArrayIdx][3], $g_aRepeaterTable[$nRepeaterArrayIdx][4])

			;Set Repeater name in Label on GUI
			GUICtrlSetData($g_idLabel_Main_RepeaterName, $sSelectedRepeater)

		EndIf

	EndIf

	If $bTestResult Then

		$g_bRepeater_Selected = True
		$g_bRepeater_Error = False
		_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_OK")

		;For server select actions
		If Not $bServerFastSelect Then
			SelectServer(True)
			_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_LIST_S")
			GUICtrlSetState($g_idInput_Main_IdNumber, $GUI_ENABLE)
		Else
			$g_bServer_Selected = True
			$g_bServer_Error = False
		EndIf

	Else

		$g_bRepeater_Selected = True
		$g_bRepeater_Error = True
		_Resource_SetToCtrlID($g_idButton_Main_RepeaterSelect, "IMG_SELECT_ERROR")

		;For server select actions
		If Not $bServerFastSelect Then
			SelectServer(True)
			_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_LIST_S")
			GUICtrlSetState($g_idInput_Main_IdNumber, $GUI_DISABLE)
		Else
			$g_bServer_Selected = False
			$g_bServer_Error = True
		EndIf
	EndIf

	$g_bGUIControl_Main_Click = True

EndFunc
;============> End SelectRepeater() ===========================================================================



#cs FUNCTION ==============================================================================================

FUNCTION:.......... SelectServer()
DESCRIPTION:....... Gets Servers of that client and call menu list to select one
SYNTAX:............ SelectRepeater($bClearServerSelection = False)
PARAMETERS:........	[Optional] $bClearServerSelection 	- Define if the Server Selection will be cleaned, Default = False
#ce =======================================================================================================
Func SelectServer($bClearServerSelection = False)

	Local $nIndex = 0
	Local $aServerNames[1]
	Local $sSelectedServer
	Local $nServerIdx

	;If clear the servers election
	If $bClearServerSelection Then
		GUICtrlSetData($g_idLabel_Main_ServerName, "")
		GUICtrlSetState($g_idInput_Main_IdNumber, $GUI_ENABLE)
		$g_nServerIdSelected = ""
		$g_bServer_Selected = False
		$g_bServer_Error = False
		Return
	EndIf

	;Search for Server corresponding with the client
	Local $aClientServers = _ArrayFindAll($g_aServerTable, $g_sClientIdSelected, 0, 0, 0, 0, 2)

	ReDim $aServerNames[UBound($aServerNames) + UBound($aClientServers) -1]

	; Get names of Client related Repeaters
	While $nIndex < UBound($aClientServers)
		$aServerNames[$nIndex] = $g_aServerTable[$aClientServers[$nIndex]][3]
		$nIndex += 1
	WEnd
	$nIndex = 0
	_ArraySort($aServerNames)

	;Call GUI for ListView
	$sSelectedServer = SelectItem($g_hMainGUI, $g_idButton_Main_ServerSelect, $aServerNames)

	; If user press button without selecting item, stop function
	If $sSelectedServer = "" Then
		GUICtrlSetData($g_idLabel_Main_ServerName, "")
		$g_nServerIdSelected = ""
		$g_bGUIControl_Main_Click = True
		$g_bServer_Selected = False
		$g_bServer_Error = False
		_Resource_SetToCtrlID($g_idButton_Main_ServerSelect, "IMG_SELECT_LOCK")
		GUICtrlSetState($g_idInput_Main_IdNumber, $GUI_ENABLE)
		Return
	Else

		;Get the Server index from the array
		Local $nServerArrayIdx = _ArraySearch($g_aServerTable, $sSelectedServer, 0, 0, 0, 0, 1, 3)

		;Get the Repeater index of the selected server
		Local $nRepeaterId = $g_aServerTable[$nServerArrayIdx][1]

		;Set the Repeater
		SelectRepeater(False, True, False, $nRepeaterId)

		;Set Server name in Label on GUI
		GUICtrlSetData($g_idLabel_Main_ServerName, $sSelectedServer)

		$g_nServerIdSelected = $g_aServerTable[$nServerArrayIdx][0]
		$g_bGUIControl_Main_Click = True

		GUICtrlSetState($g_idInput_Main_IdNumber, $GUI_DISABLE)

	EndIf

;~ ConsoleWrite(@CRLF & "DEBUG: " & "" & @CRLF)

EndFunc
;============> End SelectServer() ===========================================================================




#cs FUNCTION ==================================================================================================

FUNCTION:.......... TestConnection()
DESCRIPTION:....... Test repeater connection, Return True or False if the tested repeater is available.
SYNTAX:............ TestConnection($sRepeaterAddress, $sRepeaterPort)
PARAMETERS:........ $sRepeaterAddress - IP or Host of the Repeater to test.
					$sRepeaterPort - Port of the repeater to test.

#ce ===========================================================================================================
Func TestConnection($sRepeaterAddress, $sRepeaterPort)

	Local $iLatency
	Local $nSocket

	;Start TCP service
	TCPStartup()

	$nSocket = TCPConnect(TCPNameToIP($sRepeaterAddress), $sRepeaterPort)
	$iLatency = Ping($sRepeaterAddress,1000)

	If $nSocket = -1 Or $iLatency = 0 Or $iLatency > 500 Then
		TCPShutdown()
		Return False
	Else
		TCPShutdown()
		Return True
	EndIf

EndFunc
;============> End TestConnection() ==============================================================



#cs FUNCTION ==================================================================================================

FUNCTION:.......... DoubleClick()
DESCRIPTION:....... Standard function to detect GUI Messaages
SYNTAX:............ DoubleClick($hWnd, $iMsg, $iwParam, $ilParam)
PARAMETERS:........

#ce ===========================================================================================================
Func DoubleClick($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo

	$hWndListView = $g_idListView_SelectItem

	If Not IsHWnd($g_idListView_SelectItem) Then
		$hWndListView = GUICtrlGetHandle($g_idListView_SelectItem)
	EndIf

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")

	If $hWndFrom = $hWndListView And $iCode = $NM_DBLCLK Then
		$tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
		$g_bDoubleClick = True
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc
;============> End DoubleClick() ==============================================================



#cs FUNCTION ==============================================================================================

FUNCTION:.......... TestData()
DESCRIPTION:....... Fill some test data arrays to use while the controller is not finished
SYNTAX:............ TestData()

#ce =======================================================================================================
Func TestData()
; ======== CLIENT TEST ARRAY =============
$g_aClientTable[0][0] = 1 ;ID
$g_aClientTable[0][1] = "SOL" ;Name
$g_aClientTable[0][2] = True ;Active

$g_aClientTable[1][0] = 2
$g_aClientTable[1][1] = "MERCURY"
$g_aClientTable[1][2] = True

$g_aClientTable[2][0] = 3
$g_aClientTable[2][1] = "VENUS"
$g_aClientTable[2][2] = True

$g_aClientTable[3][0] = 4
$g_aClientTable[3][1] = "EARTH"
$g_aClientTable[3][2] = True

$g_aClientTable[4][0] = 5
$g_aClientTable[4][1] = "MARS"
$g_aClientTable[4][2] = False
; =========================================

; ======== REPEATER TEST ARRAY =============
$g_aRepeaterTable[0][0] = 0 ;ID Repeater
$g_aRepeaterTable[0][1] = 0 ;ID Client
$g_aRepeaterTable[0][2] = "CENTRAL" ;Name
$g_aRepeaterTable[0][3] = "central.company.com" ;Host
$g_aRepeaterTable[0][4] = "13001" ;Port

$g_aRepeaterTable[1][0] = 1
$g_aRepeaterTable[1][1] = 1
$g_aRepeaterTable[1][2] = "SOL"
$g_aRepeaterTable[1][3] = "repeater.sol.com.br"
$g_aRepeaterTable[1][4] = "13001"

$g_aRepeaterTable[2][0] = 2
$g_aRepeaterTable[2][1] = 2
$g_aRepeaterTable[2][2] = "MERCURY"
$g_aRepeaterTable[2][3] = "repeater.mercury.com"
$g_aRepeaterTable[2][4] = "13001"

$g_aRepeaterTable[3][0] = 3
$g_aRepeaterTable[3][1] = 3
$g_aRepeaterTable[3][2] = "VENUS"
$g_aRepeaterTable[3][3] = "repeater.venus.com"
$g_aRepeaterTable[3][4] = "13001"

$g_aRepeaterTable[4][0] = 4
$g_aRepeaterTable[4][1] = 4
$g_aRepeaterTable[4][2] = "EARTH"
$g_aRepeaterTable[4][3] = "repeater.earth.com"
$g_aRepeaterTable[4][4] = "13001"

$g_aRepeaterTable[5][0] = 5
$g_aRepeaterTable[5][1] = 5
$g_aRepeaterTable[5][2] = "MARS"
$g_aRepeaterTable[5][3] = "repeater.mars.com"
$g_aRepeaterTable[5][4] = "13001"
; =========================================

; ======== SERVER TEST ARRAY =============
$g_aServerTable[0][0] = 0 ;ID Server
$g_aServerTable[0][1] = 0 ;ID Repeater
$g_aServerTable[0][2] = 1 ;ID Client
$g_aServerTable[0][3] = "SOLSRV01" ;Name
$g_aServerTable[0][4] = "100100" ;Access ID

$g_aServerTable[1][0] = 1
$g_aServerTable[1][1] = 2
$g_aServerTable[1][2] = 2
$g_aServerTable[1][3] = "MERCSRV01"
$g_aServerTable[1][4] = "100101"

$g_aServerTable[2][0] = 2
$g_aServerTable[2][1] = 3
$g_aServerTable[2][2] = 3
$g_aServerTable[2][3] = "VENSRV01"
$g_aServerTable[2][4] = "100102"

$g_aServerTable[3][0] = 3
$g_aServerTable[3][1] = 4
$g_aServerTable[3][2] = 4
$g_aServerTable[3][3] = "ETHSRV01"
$g_aServerTable[3][4] = "100103"

$g_aServerTable[4][0] = 4
$g_aServerTable[4][1] = 5
$g_aServerTable[4][2] = 5
$g_aServerTable[4][3] = "MARSRV01"
$g_aServerTable[4][4] = "100104"

$g_aServerTable[5][0] = 5
$g_aServerTable[5][1] = 1
$g_aServerTable[5][2] = 1
$g_aServerTable[5][3] = "SOLSRV02"
$g_aServerTable[5][4] = "100105"
; =========================================
EndFunc
;============> TestData() ===========================================================================