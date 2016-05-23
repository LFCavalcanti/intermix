#cs
========================================================

	INTERMIX SUPPORT
	Windows Repeater Setup

	Author: Luiz Fernando Cavalcanti

	Created: 11/05/2016

	Edited: 18/05/2016

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
#AutoIt3Wrapper_Res_Productversion=0.1.1
#AutoIt3Wrapper_Res_Field=ProductName|Intermix Repeater
#AutoIt3Wrapper_Res_LegalCopyright=GPL3
#AutoIt3Wrapper_Res_Description=Automated setup for the UltraVNC Repeater

#AutoIt3Wrapper_Outfile=..\..\..\_TEST\RepeaterWinSetup.exe

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

#include ".\includes\ResourcesEx.au3"
#include ".\includes\MetroGUI_UDF.au3"

#endregion ### INCLUDES ###



#region ### VARIABLES ###

Global $g_CmdParamTwo = ""

Global $g_sButton_Install = "SETUP"
Global $g_sButton_Uninstall = "REMOVE"
Global $g_sButton_Tutorial = "TUTORIAL"
Global $g_sLabel_Title = "REPEATER"

Global $g_sProgramTitle = "INTERMIX REPEATER - SETUP"
Global $g_sProgramName = "INTERMIX REPEATER"

Global $g_sDisclaimerVersion = "0.1.1 A"

Global $g_hMainGui = ""
Global $g_idButtonInstall = ""
Global $g_idButtonUninstall = ""
Global $g_idButtonTutorial = ""

Global $g_bShowButtonInstall = True
Global $g_bShowButtonUninstall = False

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

			Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON_MAIN
				_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGui)
				Exit

			Case $GUI_MINIMIZE_BUTTON_MAIN
				GUISetState(@SW_MINIMIZE,$g_hMainGui)

			Case $g_idButtonTutorial
				ShellExecute("https://github.com/LFCavalcanti/intermix/wiki")

		EndSwitch

		;===================================================================================================

		If $g_bShowButtonInstall And $MainMsg = $g_idButtonInstall Then
			_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGui)
			Setup()
		EndIf

		If $g_bShowButtonUninstall And $MainMsg = $g_idButtonUninstall Then
			_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGui)
			Remove()
		EndIf

		Sleep(50)
		ContinueLoop

	Else
		Sleep(200)
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

	If $g_sInstExe == @AutoItExe and $g_bSetupStatus Then;If the Script is running from the installed path

		$g_sWorkingPath = $g_sInstDir ;set the working path to the installed directory
		$g_bShowButtonInstall = False ;Hides Install Button
		$g_bShowButtonUninstall = True ;Show Uninstall Button

	ElseIf $g_bSetupStatus Then ; If the Instant Support is Installed but the Script is not Running from the installed directory

		If MsgBox(4, $g_sProgramTitle, "The Repeater is already installed in this system. Open the installed version?") = 6 Then
			Run($g_sInstExe) ; Run the installed exe
			Exit
		Else
			$g_bShowButtonUninstall = True ;Show Uninstall Button
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

	; Verify if a second parameter is present and read it.
	If $cmdline[0] > 1 Then
		$g_CmdParamTwo = $cmdline[2]
	EndIf

	; Read and call the needed funtion
	If $cmdline[0] > 0 Then
		Switch $cmdline[1]

			Case "/setup"
				Setup()

			Case "/remove"
				Remove($g_CmdParamTwo)

			Case Else
				Exit

		EndSwitch
	EndIf

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
		Local $bUpdate = Remove("/update")

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

		$g_sInstDir = @ProgramFilesDir & "\IntermixSupport\REPEATER"

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
	FileCreateShortcut($g_sInstDir & "\REPEATER.exe", @DesktopCommonDir & "\UltraVNC Repeater.lnk", "")

	$hUrlWrite = FileOpen(@DesktopCommonDir & '\Tutorial Repeater.url', 33); unicode write
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

	;~ Waits for the Repeater Service MsgBox
	WinWait( "repeater_service" )
	ControlClick("repeater_service", "OK", "[CLASS:Button; INSTANCE:1]", "primary" )

	;~ Refresh Desktop
	WinActivate("Program Manager")
	Send("{F5}")

	;~ Wait half a second before removing the Splash and MsgBoxes
	Sleep(500)

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

	If $bOpenTutorial Then
		ShellExecute("https://github.com/LFCavalcanti/intermix/wiki")
	EndIf

	If $bOpenRepeater Then
		Run($g_sInstDir & "\REPEATER.exe", $g_sInstDir)
		Local $hRepeater = WinWait("UltraVNC_Repeater")
		WinSetState($hRepeater, "UltraVNC_Repeater", @SW_RESTORE)
		WinActivate($hRepeater)
	EndIf

	Exit

EndFunc
;============> End setup() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... remove($sType = "")
DESCRIPTION:....... Remove ou instala o Intermix
SYNTAX:............ remove($sType = "/update"[)
PARAMETERS:........ [Optional] $sType = Define removal type, if it is a quiet removal or update, default is "")

#ce ====================================================================================================
Func Remove($sType = "")

	;Local Flags
	Local $bUpdate = False
	Local $nResult = ""

	;Verify if it is running under admin privileges and set flags
	If IsAdmin() Then
		If $sType == "/update" Then
			$bUpdate = True
		EndIf
	Else
		ShellExecute(@ScriptFullPath, "/remove " & $sType, @ScriptDir, "runas")
		Exit
	EndIf

	;If not update ask user
	If Not $bUpdate Then
		$nResult = MsgBox(4, $g_sProgramTitle, "Do you want to remove the service and uninstall?")
	EndIf

	;If MsgBox returns "yes" or is update
	If $nResult = 6 Or $bUpdate Then

		; Disable Main GUI
		_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGui)

		; Remove shortcuts
		Local $sStartDir = @ProgramsCommonDir & "\Intermix Repeater"
		Local $sShortcutRepeater = @DesktopCommonDir & "\UltraVNC Repeater.lnk"
		Local $sShortcutTutorial = @DesktopCommonDir & "\Tutorial Repeater.url"
		DirRemove($sStartDir, 1)
		FileDelete($sShortcutRepeater)
		FileDelete($sShortcutTutorial)

		;~ Refresh Desktop
		WinActivate("Program Manager")
		Send("{F5}")

		; Stop Repeater service
		RunWait(@ComSpec & " /c " & 'net stop ' & $g_sServiceName, "", @SW_HIDE)

		;~ Removes the UltraVNC service from the system
		ShellExecute($g_sInstDir & "\REPEATER.exe", "-uninstall", $g_sInstDir)

		;~ Waits for the Repeater Service MsgBox
		WinWait("repeater_service")
		ControlClick("repeater_service", "OK", "[CLASS:Button; INSTANCE:1]", "primary" )

		;~ If the process is still running, kill it
		Local $hPID = ProcessExists("REPEATER.exe")
		ProcessClose($hPID)

		; Remove registry entries
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\Repeater")
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $g_sProgramName)

		;delete install directory
		If $bUpdate Then
			DirRemove($g_sInstDir & "\", 1)
		Else
			_deleteself(@ProgramFilesDir & "\IntermixSupport\REPEATER", 15)
		EndIf

		;Asks User to restart the computer
		If $bUpdate Then
			Return True
		Else
			If MsgBox(4, $g_sProgramTitle, "You need to restart the system to complete the uninstall process." & @CRLF & @CRLF & "Restart now?") == 6 Then
				Run('shutdown /r /f /t 60 /c "Repeater Setup - Your system will restart in 60 seconds..." /d P:4:2')
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

	$idLabelMainTitle = GUICtrlCreateLabel($g_sLabel_Title, 85, 117, 150, 45)
	GUICtrlSetFont(-1, 20, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	If $g_bShowButtonInstall Then
		$g_idButtonInstall = _Metro_CreateButton($GUI_HOVER_REG_MAIN, $g_sButton_Install, 90, 177, 130, 40)
	EndIf

	If $g_bShowButtonUninstall Then
		$g_idButtonUninstall = _Metro_CreateButton($GUI_HOVER_REG_MAIN, $g_sButton_Uninstall, 90, 237, 130, 40)
	EndIf

	$g_idButtonTutorial = _Metro_CreateButton($GUI_HOVER_REG_MAIN, $g_sButton_Tutorial, 90, 327, 130, 40)

	GUISetState(@SW_SHOW, $g_hMainGui)

EndFunc
;============> End mainGUI() ================================================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... Func _deleteself($path, $idelay = 5)
DESCRIPTION:....... FStop services, process and exit aplication
SYNTAX:............ Func _deleteself($path, $idelay = 5[)
PARAMETERS:........ $path - path where files where extracted
					[Optional] $idelay - Time delay to execute operation, Default is 5.

#ce ====================================================================================================
Func _deleteself($path, $idelay = 5)

	Local $sDelay = ''
	Local $iInternalDelay = 2
	Local $sAppID = $path & "\RepeaterWinSetup.exe"
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
				& 'DEL /F /Q "' & $path & '\RepeaterWinSetup.exe"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\comment.txt"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\connections.txt"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\passwd.txt"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\unblock.js"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\REPEATER.exe"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\server_access.txt"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\settings.txt"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\viewer_access.txt"' & @CRLF _
				& 'RD /S /Q "' & $path & '"' & @CRLF _
				& 'IF EXIST "' & $path & '" GOTO DELETE' & @CRLF _
				& 'GOTO END' & @CRLF _
				& @CRLF _
				& ':END' & @CRLF _
				& 'DEL "' & @TempDir & '\scratch.bat"'
	FileWrite(@TempDir & "\scratch.bat", $scmdfile)
	Return Run(@TempDir & "\scratch.bat", @TempDir, @SW_HIDE)
EndFunc
;============> _deleteself() ==============================================================