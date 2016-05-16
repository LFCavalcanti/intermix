#cs
========================================================

	INTERMIX SUPPORT
	Windows Repeater Setup

	Author: Luiz Fernando Cavalcanti

	Created: 11/05/2016

	Edited: 11/05/2016

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
; Disable the scripts ability to pause.
Break(0)

; Verify if the Script is compiled
;~ If Not @Compiled Then
;~ 	MsgBox(0, "ERRO", "O Script deve ser compilado antes de ser iniciado!", 5)
;~ 	Exit
;~ EndIf
#endregion ### PRE-EXECUTION ###



#region ### INCLUDES ###

#include ".\includes\_language\textVariables.au3"

#endregion ### INCLUDES ###



#region ### VARIABLES ###

;~ Global $Inst_dir = @ProgramFilesDir & "\IntermixRepeater\"

Global $txt_buttonInstall = "SETUP"
Global $txt_buttonUninstall = "REMOVE"
Global $txt_buttonTutorial = "TUTORIAL"
Global $txt_labelTitle = "REPEATER"

Global $str_program_title = "INTERMIX REPEATER - SETUP"

Global $txtDisclaimerMain = "0.1.1 A"

Global $mainGui = ""
Global $GUI_HOVER_REG_MAIN = ""
Global $GUI_CLOSE_BUTTON_MAIN = ""
Global $GUI_MINIMIZE_BUTTON_MAIN = ""

Global $servicename = "repeater_service"
Global $setupStatus = False

#EndRegion ### VARIABLES ###



#region ### REGISTRY VARIABLES ###

; Read Registry Key for a possible existing installation
Global $Inst_dir = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Repeater\", "Directory") ;Should contain the directory path
Global $Inst_exe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Repeater\", "Program") ;Should contain the FULL path
Global $Inst_service = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\repeater_service", "DisplayName")

#endregion ### REGISTRY VARIABLES ###



#Region ### START UP PROCEDURES ###

;~ Sets the MetroUI UDF Theme
_SetTheme("Intermix")

;~ CHECK IF THE SOFTWARE IS INSTALED IN THE SYSTEM
verifySetupStatus()

;~ HANDLE COMMAND LINE PARAMETERS
handlerCmdLineParam()

;~ VERIFY THE INSTALATTION PARAMETERS AND VERSION
handlerInstalledStatus()

;~ Starts de GUI
mainGUI()

#EndRegion ### START UP PROCEDURES ###



#Region ### MAIN LOOP ###
While 1

	If WinActive($mainGui) Then

		_Metro_HoverCheck_Loop($GUI_HOVER_REG_MAIN, $mainGui)

		$MainMsg = GUIGetMsg()

		Switch $MainMsg
		;=========================================Control-Buttons===========================================
			Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON_MAIN
				_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $mainGui)
				Exit
			Case $GUI_MINIMIZE_BUTTON_MAIN
				GUISetState(@SW_MINIMIZE,$mainGui)
		;===================================================================================================
		EndSwitch
	EndIf

WEnd
#EndRegion ### END MAIN LOOP ###



#cs FUNCTION ===========================================================================================

FUNCTION:.......... verifySetupStatus()
DESCRIPTION:....... Verify the register parameters read and test if the aplication is already installed.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func verifySetupStatus()

	If $Inst_version > 0 And $Inst_service == $servicename And FileExists($Inst_exe) Then ;Test VNC Service and program path
		$setupStatus = True
	EndIf

EndFunc
;============> End verifySetupStatus() ================================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... handlerInstalledStatus()
DESCRIPTION:....... Handle the Setup Status, there are diferente situation, for example, when the
					Application is installed but the current instance is not the installed executable.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func handlerInstalledStatus()

	If $Inst_exe == @AutoItExe Then;If the Script is running from the installed path

		$workingpath = $Inst_dir ;set the working path to the installed directory

	Else ; If the Instant Support is Installed but the Script is not Running from the installed directory

		If MsgBox(4, $str_program_title, $str_openinstalled) = 6 Then
			Run($Inst_exe) ; Run the installed exe
			Exit
		EndIf
	EndIf
EndFunc
;============> End handlerInstalledStatus() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... handlerCmdLineParam()
DESCRIPTION:....... Read command line parameters passed and calls the needed functions.
SYNTAX:............ No parameters passed, uses the cmdline from process calling, as follows:
					/setup = Execute all install procedures
					/remove = Execute all uninstall procedures

#ce ====================================================================================================
Func handlerCmdLineParam()

	Switch $cmdline[1]

		Case "/setup"
			setup()

		Case "/remove"
			remove()

		Case Else
			Exit

	EndSwitch

EndFunc
;============> End handlerCmdLineParam() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... setup($type)
DESCRIPTION:....... Instala o Intermix no
SYNTAX:............ vncConnection($connOp = False)
PARAMETERS:........ [Optional] $connOP = Define if it's a retry or reconnect command from GUI, default is False

#ce ====================================================================================================
Func setup()

	;If a previous version is already installed
	If $setupStatus Then

		; Show message about the update
		SplashTextOn($str_program_title, $str_inst_update, 500, 50, -1, -1, 4, "Arial", 11)

		;Call Remove Function for update
		$update = remove()

		;Verify the update control flag
		If $update Then
			Sleep(3000)
		Else
			MsgBox(0, $str_program_title, $str_update_fail)
			Exit
		EndIf

		;disable de Splash Text
		SplashOff()

	EndIf

	;Show message about setup
	SplashTextOn($str_program_title, $str_inst_procedure, 500, 50, -1, -1, 4, "Arial", 11)

	;Install the files
	DirCreate($Inst_dir)

		FileInstall("files\SecureVNCPlugin.dsm", $Inst_dir & "\SecureVNCPlugin.dsm", 1)
	FileInstall("files\ultravnc.ini", $Inst_dir & "\ultravnc.ini", 1)
	FileInstall("files\winvnc.exe", $Inst_dir & "\IntermixVNC.exe", 1)
	FileInstall("files\unblock.js", $Inst_dir & "\unblock.js", 1)
	FileInstall("files\First_Server_ClientAuth.pubkey", $Inst_dir & "\First_Server_ClientAuth.pubkey", 1)

	ShellExecuteWait($Inst_dir & "\unblock.js", "", @ScriptDir, "")
	FileCopy(@ScriptDir & "\" & @ScriptName, $Inst_dir & "\IntermixClient.exe", 9)

	; Configure instantsupport.ini
	IniWrite($Inst_dir & "\intermix.ini", "InstantSupport", "ID", $numId)

	; Create Start Shortcuts
	DirCreate(@ProgramsCommonDir & "\" & $str_program_name)
	FileCreateShortcut(@ProgramFilesDir & "\IntermixSupport\" & $str_company_name & "\IntermixClient.exe", @ProgramsCommonDir & "\" & $str_program_name & "\" & $txtShortcutName & ".lnk", "")
	FileCreateShortcut(@ProgramFilesDir & "\IntermixSupport\" & $str_company_name & "\IntermixClient.exe", @ProgramsCommonDir & "\" & $str_program_name & "\" & $txtRemoveShortcutName & ".lnk", "", "/remove")

	; Create Desktop shortcut
	FileCreateShortcut(@ProgramFilesDir & "\IntermixSupport\" & $str_company_name & "\IntermixClient.exe", @DesktopCommonDir & "\" & $txtShortcutName & ".lnk", "")

	; Create Service Keys
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "DependOnService", "REG_MULTI_SZ", "Tcpip")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "Description", "REG_SZ", "Instant Support Service for " & $str_company_name)
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "DisplayName", "REG_SZ", $servicename)
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "ErrorControl", "REG_DWORD", "0x00000001")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "ImagePath", "REG_EXPAND_SZ", '"' & @ProgramFilesDir & "\IntermixSupport\" & $str_company_name & '\IntermixVNC.exe" -service')
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "ObjectName", "REG_SZ", "LocalSystem")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "Type", "REG_DWORD", "0x00000010")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "WOW64", "REG_DWORD", "0x00000001")

	;Write Start Flag of the service for "On Demand" in case it is a Workstation
	If $serverSetup Then
		RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "Start", "REG_DWORD", "0x00000002")
	Else
		RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "Start", "REG_DWORD", "0x00000003")
	EndIf

	; Create Program Keys
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "SupportTeam", "REG_SZ", $str_company_name)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Directory", "REG_EXPAND_SZ", @ProgramFilesDir & "\IntermixSupport\" & $str_company_name)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Program", "REG_EXPAND_SZ", @ProgramFilesDir & "\IntermixSupport\" & $str_company_name & "\IntermixClient.exe")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Version", "REG_SZ", $version)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Type", "REG_SZ", $Inst_type_setup)

	;Create Control Panel Keys
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "DisplayIcon", "REG_SZ", '"' & $Inst_dir & "\IntermixClient.exe" & '",0')
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "DisplayName", "REG_SZ", $str_program_name)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "DisplayVersion", "REG_SZ", $str_version)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "InstallLocation", "REG_SZ", $Inst_dir)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "MajorVersion", "REG_DWORD", $str_MajorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "MinorVersion", "REG_DWORD", $str_MinorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "NoModify", "REG_DWORD", "0x00000001")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "NoRepair", "REG_DWORD", "0x00000001")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "Publisher", "REG_SZ", "Warp Code Ltda.")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "UninstallString", "REG_SZ", '"' & $Inst_dir & "\IntermixClient.exe" & '" /remove')
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "URLInfoAbout", "REG_SZ", "https://www.warpcode.com.br/intermix/")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "VersionMajor", "REG_DWORD", $str_MajorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "VersionMinor", "REG_DWORD", $str_MinorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "InstallDate", "REG_SZ", @MDAY & @MON & @YEAR)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "EstimatedSize", "REG_DWORD", "0x0000123D")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name, "sEstimatedSize2", "REG_DWORD", "0x00001233")




	; If server type, write ID and repeater index to register
	If $serverSetup Then
		RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "ID", "REG_SZ", $numId)
		RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Repeater", "REG_SZ", $repeaterIndex)
	EndIf

	;Verify System Language and Set ultravnc.ini permissions
	If @OSLang == "0416" Then
		RunWait('cacls ultravnc.ini /e /g todos:f', $Inst_dir, @SW_HIDE)
	Else
		RunWait('cacls ultravnc.ini /e /g everyone:f', $Inst_dir, @SW_HIDE)
	EndIf

	;Start VNC as Service
	$result = RunWait(@ComSpec & " /c " & 'net start ' & $servicename, "", @SW_HIDE)
	If @error Then
		MsgBox(0, "ERRO", $str_error_servicestart & @CRLF & @CRLF & $str_error_servicestart_error & $result)
		MsgBox(0, "ERRO", $str_error_servicestart_end)
		remove($type)
	EndIf

	;If not a server install, then stop the service
	If Not $serverSetup Then
		RunWait(@ComSpec & " /c " & 'net stop ' & $servicename, "", @SW_HIDE)
	EndIf

	;Modify Service Permissions to allow all users to stop and start it
	RunWait(@ComSpec & " /c " & "sc sdset " & $servicename & " D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)(A;;RPWP;;;WD)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)", "", @SW_HIDE)

	;Modify the Local GPO do allow VNC to generate Keyboard Inputs such as Ctrl+Alt+Del
	RunWait(@ComSpec & " /c " & "reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v SoftwareSASGeneration /t REG_DWORD /d 1 /f", "", @SW_HIDE)

	;Remove Splash Message
	SplashOff()

	;Asks User to restart the computer
	If $quiet Then
		MsgBox(0, $str_program_title, $str_remove_countrestart, 10)
		Shutdown(6)
	ElseIf $serverSetup Then
		MsgBox(0, $str_program_title, $str_inst_servcomplete)
	Else
		If MsgBox(4, $str_program_title, $str_needrestart) == 6 Then
			Shutdown(6)
		EndIf
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
Func remove($type = "")

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
;~ 		WinSetOnTop($str_program_title, "", 0)
		$result = MsgBox(4, $str_program_title, $str_msgbox_removeservice)
	EndIf

	;If MsgBox returns "yes" or is /quiet or /update remove
	If $result = 6 Or $quiet Or $update Then

		; Disable Main GUI
		_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $mainGui)

		; Remove shortcuts
		Local $ini_dir = @ProgramsCommonDir & "\" & $str_program_name
		Local $shortcut = @DesktopCommonDir & "\" & $txtShortcutName & ".lnk"
		DirRemove($ini_dir, 1)
		FileDelete($shortcut)

		; Stop service
		RunWait(@ComSpec & " /c " & 'net stop ' & $servicename, "", @SW_HIDE)
		RunWait($workingpath & "\IntermixVNC.exe -kill")

		; Remove registry entries
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name)
		RegDelete("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename)
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $str_program_name)


		;delete install directory
		If $update Then
			DirRemove($Inst_dir & "\", 1)
		Else
			_deleteself(@ProgramFilesDir & "\IntermixSupport\" & $str_company_name, 15)
		EndIf

		;Asks User to restart the computer
		If $quiet Then
			MsgBox(0, $str_program_title, $str_remove_countrestart, 10)
			Shutdown(6)
		ElseIf $update Then
			Return True
		Else
			If MsgBox(4, $str_program_title, $str_needrestart) == 6 Then
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
Func mainGUI()

	$mainGui = _Metro_CreateGUI($str_program_title, 310, 390, -1, -1, 1, 1)

	$GUI_HOVER_REG_MAIN = $mainGui[1]

	$GUI_CLOSE_BUTTON_MAIN = $mainGui[2]
	$GUI_MINIMIZE_BUTTON_MAIN = $mainGui[5]

	$mainGui = $mainGui[0]

	$logoIntermixMain = GUICtrlCreatePic("", 15, 39, 217, 48)
	_Resource_SetToCtrlID($logoIntermixMain, "IMG_LOGOINTERMIX")

	$barRepeaterMain = GUICtrlCreatePic("", 0, 107, 310, 50)
	_Resource_SetToCtrlID($barRepeaterMain, "IMG_BARREPEATER")

	$lbMainTitle = GUICtrlCreateLabel($txt_labelTitle, 85, 117, 150, 45)
	GUICtrlSetFont(-1, 20, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$btInstall = _Metro_CreateButton($GUI_HOVER_REG_MAIN, $txt_buttonInstall, 90, 177, 130, 40)

	$btUninstall = _Metro_CreateButton($GUI_HOVER_REG_MAIN, $txt_buttonUninstall, 90, 237, 130, 40)

	$btTutorial = _Metro_CreateButton($GUI_HOVER_REG_MAIN, $txt_buttonTutorial, 90, 327, 130, 40)

	GUISetState(@SW_SHOW, $mainGui)

EndFunc
;============> End mainGUI() ================================================================================