#cs
========================================================

	INTERMIX SUPPORT
	Windows Repeater Setup

	Author: Luiz Fernando Cavalcanti

	Created: 11/05/2016

	Edited: 16/05/2016

	Description:
	Script to extract and install the UltraVNC repeater
	into a Windows based system.

========================================================
#ce

#Region ### WRAPPER DIRECTIVES ###

#AutoIt3Wrapper_Res_File_Add=img\logoIntermix.png, RT_RCDATA, IMG_LOGOINTERMIX, 0
#AutoIt3Wrapper_Res_File_Add=img\repeaterBar.png, RT_RCDATA, IMG_BARREPEATER, 0

#AutoIt3Wrapper_Icon=img\icon.ico
#AutoIt3Wrapper_Res_Fileversion=0.1.1
#AutoIt3Wrapper_Res_LegalCopyright=GPL3
#AutoIt3Wrapper_Res_Language=1046
#AutoIt3Wrapper_Res_Description=Automated setup for the UltraVNC Repeater

#AutoIt3Wrapper_Outfile=..\..\_TEST\RepeaterWinSetup.exe

#EndRegion ### WRAPPER DIRECTIVES ###



#region ### PRE-EXECUTION ###
;~ ; Disable the scripts ability to pause.
;~ Break(0)

;~ ; Verify if the Script is compiled
;~ If Not @Compiled Then
;~ 	MsgBox(0, "ERRO", "O Script deve ser compilado antes de ser iniciado!", 5)
;~ 	Exit
;~ EndIf
#endregion ### PRE-EXECUTION ###



#region ### INCLUDES ###

#include ".\includes\_language\TextVariables.au3"
#include ".\includes\ResourcesEx.au3"
#include ".\includes\MetroGUI_UDF.au3"

#endregion ### INCLUDES ###



#region ### VARIABLES ###

Global $g_sButtonInstall = "SETUP"
Global $g_sButtonUninstall = "REMOVE"
Global $g_sButtonTutorial = "TUTORIAL"
Global $g_sLabelTitle = "REPEATER"

Global $g_sProgramTitle = "INTERMIX REPEATER - SETUP"
Global $g_sProgramName = "INTERMIX REPEATER"

Global $g_sDisclaimerVersion = "0.1.1 A"

Global $g_hMainGui = ""
Global $GUI_HOVER_REG_MAIN = ""
Global $GUI_CLOSE_BUTTON_MAIN = ""
Global $GUI_MINIMIZE_BUTTON_MAIN = ""

Global $g_sServiceName = "repeater_service"
Global $g_bSetupStatus = False

Global $g_sWorkingPath = ""

Global $g_iVersion = 11
Global $g_nMajorVersion = "0x00000001"
Global $g_nMinorVersion = "0x00000001"

#EndRegion ### VARIABLES ###



#region ### REGISTRY VARIABLES ###

; Read Registry Key for a possible existing installation
Global $g_sInstDir = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Repeater", "Directory") ;Should contain the directory path
Global $g_sInstExe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Repeater", "Program") ;Should contain the FULL path
Global $g_iInstVersion = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Repeater", "Version")
Global $g_sInstService = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\repeater_service", "DisplayName")

#endregion ### REGISTRY VARIABLES ###



#Region ### START UP PROCEDURES ###

;~ Sets the MetroUI UDF Theme
_SetTheme("Intermix")

;~ CHECK IF THE SOFTWARE IS INSTALED IN THE SYSTEM
VerifySetupStatus()

;~ HANDLE COMMAND LINE PARAMETERS
HandleCmdLineParam()

;~ VERIFY THE INSTALATTION PARAMETERS AND VERSION
HandleInstalledStatus()

;~ Starts de GUI
MainGUI()

#EndRegion ### START UP PROCEDURES ###



#Region ### MAIN LOOP ###
While 1

	If WinActive($g_hMainGui) Then

		_Metro_HoverCheck_Loop($GUI_HOVER_REG_MAIN, $g_hMainGui)

		$MainMsg = GUIGetMsg()

		Switch $MainMsg
		;=========================================Control-Buttons===========================================
			Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON_MAIN
				_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGui)
				Exit

			Case $GUI_MINIMIZE_BUTTON_MAIN
				GUISetState(@SW_MINIMIZE,$g_hMainGui)

			Case $idButtonInstall
				_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGui)
				Setup()

			Case $idButtonUninstall
				_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGui)
				Remove()

			Case $idButtonTutorial
				ShellExecute("https://github.com/LFCavalcanti/intermix/wiki")

		;===================================================================================================
		EndSwitch
	EndIf

WEnd
#EndRegion ### END MAIN LOOP ###



#cs FUNCTION ===========================================================================================

FUNCTION:.......... VerifySetupStatus()
DESCRIPTION:....... Verify the register parameters read and test if the aplication is already installed.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func VerifySetupStatus()

	If $g_iInstVersion > 0 And $g_sInstService == $g_sServiceName And FileExists($g_sInstExe) Then ;Test VNC Service and program path
		$g_bSetupStatus = True
	EndIf

EndFunc
;============> End VerifySetupStatus() ================================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... HandleInstalledStatus()
DESCRIPTION:....... Handle the Setup Status, there are diferente situation, for example, when the
					Application is installed but the current instance is not the installed executable.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func HandleInstalledStatus()

	If $g_sInstExe == @AutoItExe Then;If the Script is running from the installed path

		$g_sWorkingPath = $g_sInstDir ;set the working path to the installed directory

	Else ; If the Instant Support is Installed but the Script is not Running from the installed directory

		If MsgBox(4, $g_sProgramTitle, $str_openinstalled) = 6 Then
			Run($g_sInstExe) ; Run the installed exe
			Exit
		EndIf
	EndIf
EndFunc
;============> End HandleInstalledStatus() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... HandleCmdLineParam()
DESCRIPTION:....... Read command line parameters passed and calls the needed functions.
SYNTAX:............ No parameters passed, uses the cmdline from process calling, as follows:
					/setup = Execute all install procedures
					/remove = Execute all uninstall procedures

#ce ====================================================================================================
Func HandleCmdLineParam()

	Switch $cmdline[1]

		Case "/setup"
			Setup()

		Case "/remove"
			Remove()

		Case Else
			Exit

	EndSwitch

EndFunc
;============> End HandleCmdLineParam() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... Setup()
DESCRIPTION:....... Installs the UltraVNC Repeater and setup it's service
SYNTAX:............ Setup()

#ce ====================================================================================================
Func Setup()

	;Check if the Script is running with admin privileges and set flags for cmdline parameters
	If Not IsAdmin() Then
		ShellExecute(@ScriptFullPath, "/setup", @ScriptDir, "runas")
		Exit
	EndIf

	Local $hUrlWrite = 0
	Local $bOpenRepeater = False
	Local $bOpenTutorial = False

	;If a previous version is already installed
	If $g_bSetupStatus Then

		; Show message about the update
		SplashTextOn($g_sProgramTitle, "The Repeater is already installed on this system, removing previous version...", 500, 50, -1, -1, 4, "Arial", 11)

		;Call Remove Function for update
		Local $bUpdate = Remove()

		;Verify the update control flag
		If $bUpdate Then
			Sleep(3000)
		Else
			MsgBox(0, $g_sProgramTitle, "The update process failed, please remove the Intermix Repeater manually.")
			Exit
		EndIf

		;disable de Splash Text
		SplashOff()

	Else

		$g_sInstDir = @ProgramFilesDir & "\IntermixSupport\REPEATER\"

	EndIf

	;Show message about setup
	SplashTextOn($g_sProgramTitle, "Wait while the Intermix Repeater is installed...", 500, 50, -1, -1, 4, "Arial", 11)

	;Install the files
	DirCreate($g_sInstDir)

	FileInstall("files\passwd.txt", $g_sInstDir & "\passwd.txt", 1)
	FileInstall("files\REPEATER.exe", $g_sInstDir & "\REPEATER.exe", 1)
	FileInstall("files\unblock.js", $g_sInstDir & "\unblock.js", 1)

	ShellExecuteWait($g_sInstDir & "\unblock.js", "", @ScriptDir, "")
	FileCopy(@ScriptDir & "\" & @ScriptName, $g_sInstDir & "\RepeaterWinSetup.exe", 9)

	; === START SHORTCUTS =======================================================================================================================
	DirCreate(@ProgramsCommonDir & "\Intermix Repeater")
	FileCreateShortcut($g_sInstDir & "\REPEATER.exe", @ProgramsCommonDir & "\Intermix Repeater\UltraVNC Repeater.lnk", "")
	FileCreateShortcut($g_sInstDir & "\RepeaterWinSetup.exe", @ProgramsCommonDir & "\Intermix Repeater\Uninstall Repeater.lnk", "", "/remove")

	$hUrlWrite = FileOpen(@ProgramsCommonDir & '\Intermix Repeater\Tutorial Repeater.url', 33); unicode write
	FileWrite($hUrlWrite, _
		'[InternetShortcut]' & @CRLF & _
        'URL=' & "https://github.com/LFCavalcanti/intermix/wiki" & @CRLF & _
        'IconIndex=0' & @CRLF & _
        'IconFile=' & $g_sInstDir & "\RepeaterWinSetup.exe" _
        )
	FileClose($hUrlWrite)
	; =============================================================================================================================================


	; === DESKTOP SHORTCUTS =======================================================================================================================
	FileCreateShortcut($g_sInstDir & "\REPEATER.exe", @DesktopCommonDir & "\Intermix Repeater\UltraVNC Repeater.lnk", "")

	$hUrlWrite = FileOpen(@DesktopCommonDir & '\Intermix Repeater\Tutorial Repeater.url', 33); unicode write
	FileWrite($hUrlWrite, _
		'[InternetShortcut]' & @CRLF & _
        'URL=' & "https://github.com/LFCavalcanti/intermix/wiki" & @CRLF & _
        'IconIndex=0' & @CRLF & _
        'IconFile=' & $g_sInstDir & "\RepeaterWinSetup.exe" _
        )
	FileClose($hUrlWrite)
	; =============================================================================================================================================


	; === PROGRAM KEYS ============================================================================================================================
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Repeater", "Directory", "REG_EXPAND_SZ", $g_sInstDir)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Repeater", "Program", "REG_EXPAND_SZ", $g_sInstDir & "\RepeaterWinSetup.exe")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Repeater", "Version", "REG_SZ", $g_iVersion)
	; =============================================================================================================================================

	; === CONRTOL PANEL UNINSTALL PROFILE =========================================================================================================
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "DisplayIcon", "REG_SZ", '"' & $g_sInstDir & "\RepeaterWinSetup.exe" & '",0')
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "DisplayName", "REG_SZ", $g_sProgramName)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "DisplayVersion", "REG_SZ", $g_sDisclaimerVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "InstallLocation", "REG_SZ", $g_sInstDir)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "MajorVersion", "REG_DWORD", $g_nMajorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "MinorVersion", "REG_DWORD", $g_nMinorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "NoModify", "REG_DWORD", "0x00000001")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "NoRepair", "REG_DWORD", "0x00000001")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "Publisher", "REG_SZ", "Warp Code Ltda.")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "UninstallString", "REG_SZ", '"' & $g_sInstDir & "\RepeaterWinSetup.exe" & '" /remove')
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "URLInfoAbout", "REG_SZ", "https://github.com/LFCavalcanti/intermix")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "VersionMajor", "REG_DWORD", $g_nMajorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "VersionMinor", "REG_DWORD", $g_nMinorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "InstallDate", "REG_SZ", @MDAY & @MON & @YEAR)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "EstimatedSize", "REG_DWORD", "0x0000123D")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName, "sEstimatedSize2", "REG_DWORD", "0x00000FE4")
	; =============================================================================================================================================

	;~ Install the Repeater service
	ShellExecute($g_sInstDir & "\REPEATER.exe", "-install", $g_sInstDir)

	;Remove Splash Message
	SplashOff()

	;~ Ask user if wants to open the Repeater
	If MsgBox(4, $g_sProgramTitle, "Do you wish to open the Repeater configuration?") == 6 Then
		Local $bOpenRepeater = True
	EndIf

	;~ Ask user if wants to open the Tutorial
	If MsgBox(4, $g_sProgramTitle, "Do you wish to open the Tutorial?") == 6 Then
		Local $bOpenTutorial = True
	EndIf

	MsgBox(0, $g_sProgramTitle, "In order for the UltraVNC Repeater Service to start correctly, you must reboot the system." & @CRLF & @CRLF & "Don't forget to do so after the initial configuration!")

	If $bOpenRepeater Then
		Run($g_sInstDir & "\REPEATER.exe", $g_sInstDir)
	EndIf

	If $bOpenTutorial Then
		ShellExecute("https://github.com/LFCavalcanti/intermix/wiki")
	EndIf

	Exit

EndFunc
;============> End setup() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... remove($type = "")
DESCRIPTION:....... Remove ou instala o Intermix
SYNTAX:............ remove($type = "/quiet"[)
PARAMETERS:........ [Optional] $type = Define removal type, if it is a quiet removal or update, default is "")

#ce ====================================================================================================
Func Remove($type = "")

	;Local Flags
	Local $quiet = False
	Local $update = False
	Local $result = ""

	;Verify if it is running under admin privileges and set flags
	If IsAdmin() Then
		If $type == "/quiet" Then
			$quiet = True
		ElseIf $type == "/update" Then
			$update = True
		EndIf
	Else
		ShellExecute(@ScriptFullPath, "/remove " & $type, @ScriptDir, "runas")
		Exit
	EndIf

	;If not /quiet or /update ask user
	If Not $quiet And Not $update Then
;~ 		WinSetOnTop($g_sProgramTitle, "", 0)
		$result = MsgBox(4, $g_sProgramTitle, $str_msgbox_removeservice)
	EndIf

	;If MsgBox returns "yes" or is /quiet or /update remove
	If $result = 6 Or $quiet Or $update Then

		; Disable Main GUI
		_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGui)

		; Remove shortcuts
		Local $ini_dir = @ProgramsCommonDir & "\" & $g_sProgramName
		Local $shortcut = @DesktopCommonDir & "\" & $txtShortcutName & ".lnk"
		DirRemove($ini_dir, 1)
		FileDelete($shortcut)

		; Stop service
		RunWait(@ComSpec & " /c " & 'net stop ' & $g_sServiceName, "", @SW_HIDE)
		RunWait($g_sWorkingPath & "\IntermixVNC.exe -kill")

		; Remove registry entries
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name)
		RegDelete("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $g_sServiceName)
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName)


		;delete install directory
		If $update Then
			DirRemove($g_sInstDir & "\", 1)
		Else
			_deleteself(@ProgramFilesDir & "\IntermixSupport\" & $str_company_name, 15)
		EndIf

		;Asks User to restart the computer
		If $quiet Then
			MsgBox(0, $g_sProgramTitle, $str_remove_countrestart, 10)
			Shutdown(6)
		ElseIf $update Then
			Return True
		Else
			If MsgBox(4, $g_sProgramTitle, $str_needrestart) == 6 Then
				Shutdown(6)
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

FUNCTION:.......... mainGUI()
DESCRIPTION:....... Draws the main GUI
SYNTAX:............ No parameters

#ce ====================================================================================================
Func MainGUI()

	$g_hMainGui = _Metro_CreateGUI($g_sProgramTitle, 310, 390, -1, -1, 1, 1)

	$GUI_HOVER_REG_MAIN = $g_hMainGui[1]

	$GUI_CLOSE_BUTTON_MAIN = $g_hMainGui[2]
	$GUI_MINIMIZE_BUTTON_MAIN = $g_hMainGui[5]

	$g_hMainGui = $g_hMainGui[0]

	$idImgLogoIntermixMain = GUICtrlCreatePic("", 15, 39, 217, 48)
	_Resource_SetToCtrlID($idImgLogoIntermixMain, "IMG_LOGOINTERMIX")

	$idImgBarMain = GUICtrlCreatePic("", 0, 107, 310, 50)
	_Resource_SetToCtrlID($idImgBarMain, "IMG_BARREPEATER")

	$idLabelMainTitle = GUICtrlCreateLabel($g_sLabelTitle, 85, 117, 150, 45)
	GUICtrlSetFont(-1, 20, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$idButtonInstall = _Metro_CreateButton($GUI_HOVER_REG_MAIN, $g_sButtonInstall, 90, 177, 130, 40)

	$idButtonUninstall = _Metro_CreateButton($GUI_HOVER_REG_MAIN, $g_sButtonUninstall, 90, 237, 130, 40)

	$idButtonTutorial = _Metro_CreateButton($GUI_HOVER_REG_MAIN, $g_sButtonTutorial, 90, 327, 130, 40)

	GUISetState(@SW_SHOW, $g_hMainGui)

EndFunc
;============> End mainGUI() ================================================================================