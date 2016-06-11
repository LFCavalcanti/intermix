#cs
========================================================

	INTERMIX SUPPORT
	CLIENT

	Author: Luiz Fernando Cavalcanti

	Created: 11/05/2015

	Edited: 31/05/2016

	Description:
	Script for the client, that users run to allow
	IT technicians to access and fix problems.

========================================================
#ce

#Region ### WRAPPER DIRECTIVES ###

#AutoIt3Wrapper_Icon=img\icon.ico
#AutoIt3Wrapper_Res_Fileversion=0.1.2
#AutoIt3Wrapper_Res_Productversion=0.1.2
#AutoIt3Wrapper_Res_Field=ProductName|Intermix Client
#AutoIt3Wrapper_Res_LegalCopyright=GPL3
#AutoIt3Wrapper_Res_Language=1046
#AutoIt3Wrapper_Res_Description=Remote Support tool for IT Pros

#AutoIt3Wrapper_Outfile=..\..\_TEST\IntermixClient.exe

;============================ GUI ELEMENTS =======================================;
#AutoIt3Wrapper_Res_File_Add=img\iconStartUp.png, RT_RCDATA, IMG_STARTICON, 0
#AutoIt3Wrapper_Res_File_Add=img\logoIntermix.png, RT_RCDATA, IMG_LOGOINTERMIX, 0
#AutoIt3Wrapper_Res_File_Add=img\logoCompany.png, RT_RCDATA, IMG_LOGOCOMPANY, 0
#AutoIt3Wrapper_Res_File_Add=img\mainGUIBar.png, RT_RCDATA, IMG_MAINBAR, 0
#AutoIt3Wrapper_Res_File_Add=img\configIcon.png, RT_RCDATA, IMG_MAINCONFIGICON, 0
#AutoIt3Wrapper_Res_File_Add=img\configHover.png, RT_RCDATA, IMG_MAINCONFIGHOVER, 0
#AutoIt3Wrapper_Res_File_Add=img\configClick.png, RT_RCDATA, IMG_MAINCONFIGCLICK, 0
#AutoIt3Wrapper_Res_File_Add=img\configBar1.png, RT_RCDATA, IMG_MAINCONFIGBAR1, 0
#AutoIt3Wrapper_Res_File_Add=img\configBar2.png, RT_RCDATA, IMG_MAINCONFIGBAR2, 0
#AutoIt3Wrapper_Res_File_Add=img\statusOk.png, RT_RCDATA, IMG_STATUSOK, 0
#AutoIt3Wrapper_Res_File_Add=img\statusHover.png, RT_RCDATA, IMG_STATUSHOVER, 0
#AutoIt3Wrapper_Res_File_Add=img\statusClick.png, RT_RCDATA, IMG_STATUSCLICK, 0
#AutoIt3Wrapper_Res_File_Add=img\statusConn.png, RT_RCDATA, IMG_STATUSCONN, 0
#AutoIt3Wrapper_Res_File_Add=img\statusError.png, RT_RCDATA, IMG_STATUSERROR, 0

#EndRegion ### WRAPPER DIRECTIVES ###

#region ### PRE-EXECUTION ###
; Disable the scripts ability to pause.
Break(0)

; Verify if the Script is compiled
;~ If Not @Compiled Then
;~ 	MsgBox(0, "ERRO", "O Script deve ser compilado antes de ser iniciado!", 5)
;~ 	Exit
;~ EndIf
;~ #endregion ### PRE-EXECUTION ###

#region ### INCLUDES ###

#include <ComboConstants.au3>
#include <Array.au3>
#include ".\includes\ResourcesEx.au3"
#include ".\includes\MetroGUI_UDF.au3"
#include ".\includes\_language\textVariables.au3"
#include ".\includes\_repeater\repeaterData.au3"

#endregion ### INCLUDES ###

#region ### VARIABLES ###

Global $g_iNumId = 0
Global $g_sTxtLabelIdNum = "------"
Global $g_iBarProgress = 0

Global $g_hTrayInstall = ""
Global $g_hTrayInstallServer = ""
Global $g_hTrayExit = ""

Global $g_idProgressStartUp = ""
Global $g_hStartUpGUI = ""
Global $GUI_HOVER_REG_START = ""

Global $g_hMainGUI = ""
Global $GUI_HOVER_REG_MAIN = ""
Global $GUI_CLOSE_BUTTON_MAIN = ""
Global $GUI_MINIMIZE_BUTTON_MAIN = ""
Global $g_idStatusMain = ""
Global $g_idConfigMain = ""
Global $g_idLabelNumID = ""

Global $g_sTxtLabelRepeater = "---------"
Global $g_sNumLabelLatency = "----"

Global $g_hConfigGUI = ""
Global $g_bConfigGUIExist = False
Global $GUI_HOVER_REG_CONFIG = ""
Global $GUI_CLOSE_BUTTON_CONFIG = ""
Global $GUI_MINIMIZE_BUTTON_CONFIG = ""

Global $g_sVersion = "0.1.2 ALPHA"
Global $_g_sLabel_VersionMain = "0.1.2 A"
Global $g_sMajorVersion = "0x00000001"
Global $g_sMinorVersion = "0x00000000"
Global $g_iVersion = 12
Global $g_iSetupStatus = 0
Global $g_sWorkingPath = @AppDataDir & "\Intermix_Temp_Files"
Global $g_CmdParamTwo = ""
Global $g_sServiceName = "IntermixSupport_" & $_g_sCompanyName
Global $g_bConnStatus = False
Global $g_bTmpFiles = False

#endregion ### VARIABLES ###

#region ### REGISTRY VARIABLES ###

; Read Registry Key for a possible existing installation
Global $g_sInstDir = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Directory") ;Should contain the directory path
Global $g_sInstExe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Program") ;Should contain the FULL path
Global $g_sInstType = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Type") ;Should contain the Type(workstation or server)
Global $g_sInstVersion = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Version"); Should contain a INT number for the version installed
Global $g_sInstID = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "ID");Read the current ID, when type is server
Global $g_nRepeaterIndex = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Repeater") ;Read the repeater in use when type is server
Global $g_sInstServiceName = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $g_sServiceName, "DisplayName")

#endregion ### REGISTRY VARIABLES ###

#Region ### START UP ###

;~ CHECK IF THE SOFTWARE IS INSTALED IN THE SYSTEM
VerifySetupStatus()

;~ HANDLE COMMAND LINE PARAMETERS
HandleCmdLine()

; Set MetroUI UDF Theme
_SetTheme("Intermix")

;~ Start the progress bar
StartProgressBar()
Sleep(200)

#EndRegion ### START UP ###

#region ### INICIALIZATION PROCEDURES ###

;Advanced Progressbar
StartProgressBar(1,10)

; IF Installed, check
If $g_iSetupStatus > 0 Then
	;~ VERIFY THE INSTALATTION PARAMETERS AND VERSION
	HandleInstalledStatus()
Else
	;~ Extract files to Temp Directories if not installed.
	ExtractTempFiles()
EndIf

;Advanced Progressbar
StartProgressBar(1,30)


;Test the connection to the Repeater and Generate ID
If $g_iSetupStatus = 2 Then ;If server, just test
	$g_bConnStatus = TestConnection(True, $g_nRepeaterIndex)
Else
	$g_bConnStatus = TestConnection()
EndIf

;Advanced Progressbar
StartProgressBar(1,20)

; Connect the VNC to Repeater
VncConnection()

;Advanced Progressbar
StartProgressBar(1,30)
Sleep(500)
StartProgressBar(2)

; Initialize the GUI
MainGUI()



; Enable the scripts ability to pause. (otherwise tray menu is disabled)
Break(1)

; Create the tray icon. Default tray menu items (Script Paused/Exit) will not be shown.
Opt("TrayMenuMode", 1)
If $g_iSetupStatus < 1 Then
	$g_hTrayInstall = TrayCreateItem($_g_sTray_ButtonInstall)
	$g_hTrayInstallServer = TrayCreateItem($_g_sTray_ButtonInstallServer)
EndIf
$g_hTrayExit = TrayCreateItem($_g_sTray_ButtonExit)

#endregion ### INICIALIZATION PROCEDURES ###

#region ### MAIN LOOP ###
; Main Loop
While 1

	If WinActive($g_hMainGUI) Then

		; Get mouse info
		Local $aMouseInfo = GUIGetCursorInfo($g_hMainGUI)

		_Metro_HoverCheck_Loop($GUI_HOVER_REG_MAIN, $g_hMainGUI)

		Local $hMainMsg = GUIGetMsg()

		;========================== HOVER LOOP FOR CONTROL BUTTONS ==========================
		Switch $hMainMsg
			Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON_MAIN
				CloseSupport()
			Case $GUI_MINIMIZE_BUTTON_MAIN
				GUISetState(@SW_MINIMIZE,$g_hMainGUI)
		EndSwitch
		;====================================================================================

		; =========================HOVER STATUS==============================================
		; Mouse em hover no botão
		If $aMouseInfo[4] = $g_idStatusMain Then
			_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSHOVER")
		ElseIf $g_bConnStatus Then
			_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSOK")
		Else
			_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSERROR")
		EndIf
		; ===================================================================================

		; ==========================HOVER CONFIG=============================================
		; Mouse em hover no botão
		If $aMouseInfo[4] = $g_idConfigMain Then
			_Resource_SetToCtrlID($g_idConfigMain, "IMG_MAINCONFIGHOVER")
		Else
			_Resource_SetToCtrlID($g_idConfigMain, "IMG_MAINCONFIGICON")
		EndIf
		; ===================================================================================

		; ========================== DETECTS MOUSE CLICKS =============================================
		If $aMouseInfo[2] = 1 Then

			;If click on Status Button
			If $aMouseInfo[4] = $g_idStatusMain Then

				_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSCLICK")
				Sleep(50)
				VncConnection(True)

			;If click on config Button
			ElseIf $aMouseInfo[4] = $g_idConfigMain Then

				_Resource_SetToCtrlID($g_idConfigMain, "IMG_MAINCONFIGCLICK")
				Sleep(50)
				If Not $g_bConfigGUIExist Then
					ConfigGUI()
				EndIf

			EndIf

		EndIf

		ContinueLoop

	EndIf

	If $g_bConfigGUIExist And WinActive($g_hConfigGUI) Then

		_Metro_HoverCheck_Loop($GUI_HOVER_REG_CONFIG, $g_hConfigGUI)

		$hConfigMsg = GUIGetMsg()

		Switch $hConfigMsg
		;=========================================Control-Buttons===========================================
			Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON_CONFIG
				_Metro_GUIDelete($GUI_HOVER_REG_CONFIG, $g_hConfigGUI)
				$g_bConfigGUIExist = False
			Case $GUI_MINIMIZE_BUTTON_CONFIG
				GUISetState(@SW_MINIMIZE,$g_hConfigGUI)
		;===================================================================================================
		EndSwitch

		ContinueLoop

	Else

		Sleep(200)

	EndIf

	#Region ### TRAY EVENTS ###
	; Tray events.
	Local $hTrayMsg = TrayGetMsg()

	If $g_iSetupStatus > 0 Then
		Switch $hTrayMsg
			Case $g_hTrayExit
				Closesupport()
		EndSwitch
	Else
		Switch $hTrayMsg
			Case $g_hTrayInstall
				Setup()
			Case $g_hTrayInstallServer
				Setup("/server")
			Case $g_hTrayExit
				CloseSupport()
		EndSwitch
	EndIf
	#EndRegion ### TRAY EVENTS ###

WEnd
#endregion ### MAIN LOOP ###

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
Func VerifySetupStatus()

	If $g_sInstVersion > 0 And $g_sInstServiceName == $g_sServiceName And FileExists($g_sInstExe) Then ;Test VNC Service and program path
		$g_iSetupStatus = 1
		If $g_sInstType == "Server" Then ; If Server type, don't generate an ID
			$g_iSetupStatus = 2
		EndIf
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
		$g_iNumId = $g_sInstID ;Use the installed ID

	Else ; If the Instant Support is Installed but the Script is not Running from the installed directory

		If MsgBox(4, $_g_sProgramTitle, $_g_sMsgBox_OpenInstalled) = 6 Then
			Run($g_sInstExe) ; Run the installed exe
			Exit
		Else
			$g_iSetupStatus = 0 ;Define to the rest of the script, it's running as not installed
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
		$g_sWorkingPath = @AppDataDir & "\Intermix_Temp_Files_" & Random(100000, 999999, 1)
	EndIf

	DirCreate($g_sWorkingPath)

	FileInstall("files\intermix.ini", $g_sWorkingPath & "\intermix.ini", 1)
	FileInstall("files\SecureVNCPlugin.dsm", $g_sWorkingPath & "\SecureVNCPlugin.dsm", 1)
	FileInstall("files\ultravnc.ini", $g_sWorkingPath & "\ultravnc.ini", 1)
	FileInstall("files\unblock.js", $g_sWorkingPath & "\unblock.js", 1)
	FileInstall("files\vnchooks.dll", $g_sWorkingPath & "\vnchooks.dll", 1)
	FileInstall("files\logmessages.dll", $g_sWorkingPath & "\logmessages.dll", 1)
	FileInstall("files\First_Server_ClientAuth.pubkey", $g_sWorkingPath & "\First_Server_ClientAuth.pubkey", 1)

	If @OSVersion = "WIN_XP" or @OSVersion = "WIN_2003" Then
		FileInstall("files\winvnc_xp.exe", $g_sWorkingPath & "\IntermixVNC.exe", 1)
	Else
		FileInstall("files\winvnc.exe", $g_sWorkingPath & "\IntermixVNC.exe", 1)
	EndIf

	ShellExecuteWait($g_sWorkingPath & "\unblock.js", "", @ScriptDir, "")

	FileCopy(@ScriptDir & "\" & @ScriptName, $g_sWorkingPath & "\IntermixClient.exe", 9)

	$g_bTmpFiles = True ; => Control flag if there is temp files for this session

EndFunc
;============> End extractTempFiles()) ==============================================================



#cs FUNCTION ==================================================================================================

FUNCTION:.......... testConnection($testType,$i)
DESCRIPTION:....... Testa a conexão para o Repeater. Return True or False if the tested repeater is available.
SYNTAX:............ testConnection($testType,$g_nRepeaterIndex[0][)
PARAMETERS:........ [Optional]$testType - If True is server, test only the designated, Default False
					[Optional]$iRepeaterIdx - Which Repeater from the list will be testes, for server type. Default 0.

#ce ===========================================================================================================
Func TestConnection($bTestType = False, $iRepeaterIdx = 0)

	Local $iLatency
	Local $nSocket

	;Start TCP service
	TCPStartup()

	;If just checking current connection or server setup
	If $bTestType Then

		$nSocket = TCPConnect(TCPNameToIP($_g_aRepeaterIp[$iRepeaterIdx]), $_g_aRepeaterPort[$iRepeaterIdx])
		$iLatency = Ping($_g_aRepeaterIp[$iRepeaterIdx],1000)

		If $nSocket = -1 Or $iLatency = 0 Or $iLatency > 500 Then
			TCPShutdown()
			$g_sTxtLabelRepeater = "---------"
			$g_sNumLabelLatency = "----"
			Return False
		Else
			TCPShutdown()
			$g_sTxtLabelRepeater = $_g_aRepeaterName[$iRepeaterIdx]
			$g_sNumLabelLatency = $iLatency
			Return True
		EndIf

	Else

		;Test connection with the repeaters in crescent order
		While $iRepeaterIdx <= 3
			$nSocket = TCPConnect(TCPNameToIP($_g_aRepeaterIp[$iRepeaterIdx]), $_g_aRepeaterPort[$iRepeaterIdx])
			$iLatency = Ping($_g_aRepeaterIp[$iRepeaterIdx],1000)
			If $nSocket = -1 Or $iLatency = 0 Or $iLatency > 500 Then
				$iRepeaterIdx+=1
			Else
				TCPShutdown()
				$g_sTxtLabelRepeater = $_g_aRepeaterName[$iRepeaterIdx]
				$g_sNumLabelLatency = $iLatency
				$g_nRepeaterIndex = $iRepeaterIdx
				Return True
			EndIf
		WEnd

	EndIf

	TCPShutdown()
	$g_sTxtLabelRepeater = "---------"
	$g_sNumLabelLatency = "----"
	Return False

EndFunc
;============> End testConnection() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... generateID()
DESCRIPTION:....... Generates an ID number to use on the VNC connection.
SYNTAX:............ No parameters

#ce ====================================================================================================
Func GenerateID()

	Local $nLowerLimit = 200000
	Local $nUpperLimit = 999999
	$g_iNumId = Random($nLowerLimit, $nUpperLimit, 1)
	$g_sTxtLabelIdNum = $g_iNumId

EndFunc
;============> End testConnection() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... vncConnection($bReconnect)
DESCRIPTION:....... Faz a conexão reversa do UltraVNC com o Repeater
SYNTAX:............ vncConnection($bReconnect = False)
PARAMETERS:........ [Optional] $bReconnect = Define if it's a retry or reconnect command from GUI, default is False

#ce ====================================================================================================
Func VncConnection($bReconnect = False)

	If $bReconnect Then ; If reconnect

		;Set icon on GUI
		_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSCONN")

		;Terminate current VNC process
		Local $hPidVNC = Run($g_sWorkingPath & "\IntermixVNC.exe -kill")
		ProcessWaitClose($hPidVNC, 15)

		;Test the connection
		If $g_iSetupStatus = 2 Then ;If server, just test
			$g_bConnStatus = testConnection(True, $g_nRepeaterIndex)
		Else
			$g_bConnStatus = testConnection(False)
			; Since not server, write null ID on GUI
			GUICtrlSetData($g_idLabelNumID, "------")
		EndIf
		Sleep(2000)
	EndIf

	If $g_bConnStatus And $g_iSetupStatus = 2 Then ;==> If Connection OK and Server

		;Stop the service
		RunWait(@ComSpec & " /c " & 'net stop ' & $g_sServiceName, "", @SW_HIDE)

		;Write the current ID to the service config file
		IniWrite($g_sWorkingPath & "\ultravnc.ini", "admin", "service_commandline", "-autoreconnect ID:" & $g_iNumId & " -connect " & $_g_aRepeaterIp[$g_nRepeaterIndex] & ":" & $_g_aRepeaterPort[$g_nRepeaterIndex])

		;Start the service
		RunWait(@ComSpec & " /c " & 'net start ' & $g_sServiceName, "", @SW_HIDE)

		;Set icon on GUI
		_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSOK")

		;Set ID Num on GUI as Installed ID
		GUICtrlSetData($g_idLabelNumID, $g_sInstID)

		Return

	ElseIf $g_bConnStatus And $g_iSetupStatus = 1 Then ;==> If Connection OK and Station

		;Gera um novo ID
		GenerateID()

		;Stop the service
		RunWait(@ComSpec & " /c " & 'net stop ' & $g_sServiceName, "", @SW_HIDE)

		;Write the current ID to the service config file
		IniWrite($g_sWorkingPath & "\ultravnc.ini", "admin", "service_commandline", "-sc_exit -sc_prompt -multi -autoreconnect ID:" & $g_iNumId & " -connect " & $_g_aRepeaterIp[$g_nRepeaterIndex] & ":" & $_g_aRepeaterPort[$g_nRepeaterIndex])

		;Start the service
		RunWait(@ComSpec & " /c " & 'net start ' & $g_sServiceName, "", @SW_HIDE)

		GUICtrlSetData($g_idLabelNumID, $g_iNumId)
		_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSOK")

	ElseIf $g_bConnStatus Then ;==> If Connection OK and not installed

		;Generates new ID
		GenerateID()

		; Start the VNC server and make a reverse connection to the repeater.
		ShellExecute($g_sWorkingPath & "\IntermixVNC.exe", "-sc_exit -sc_prompt -multi -autoreconnect ID:" & $g_iNumId & " -connect " & $_g_aRepeaterIp[$g_nRepeaterIndex] & ":" & $_g_aRepeaterPort[$g_nRepeaterIndex] & " -run")

		; Give some time to the connection
		Sleep(2000)

		GUICtrlSetData($g_idLabelNumID, $g_iNumId)

		Sleep(500)

		_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSOK")



	Else ;==> If Connection Error

		GUICtrlSetData($g_idLabelNumID, "------")
		_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSERROR")

	EndIf



EndFunc
;============> End vncConnection() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... setup($sType)
DESCRIPTION:....... Install Intermix Client on the system.
SYNTAX:............ setup($sType = "/station"[)
PARAMETERS:........ [Optional] $sType = Define setup type, if it is a Server, station and/or quiet, default is "/station")

#ce ====================================================================================================
Func Setup($sType = "/station")

	;Hide GUI
	GUISetState(@SW_HIDE)

	;Control flags to guide the installation procedure
	Local $bQuiet = False
	Local $bServerSetup = False
	Local $bServerSetupData = False
	Local $nKeepConfig = 7
	Local $bUpdate = False
	Local $sTypeSetup = "Workstation"
	Local $iRepIndex = 0
	Local $bServerSetupData = True

	;Set the installation Directory
	Local $g_sInstDir = @ProgramFilesDir & "\IntermixSupport\" & $_g_sCompanyName & "\"

	;Check if the Script is running with admin privileges and set flags for cmdline parameters
	If IsAdmin() Then ; If is admin, set the parameter to variables

		If $sType == "/server" Then

			$bServerSetup = True
			$sTypeSetup = "Server"

		ElseIf $sType == "/quiet" Then

			$bQuiet = True

		EndIf

	Else ;If not, run it as admin

		$pid = Run($g_sWorkingPath & "\IntermixVNC.exe -kill")
		ProcessWaitClose($pid, 15)
		_deleteself($g_sWorkingPath, 1)
		DirRemove($g_sWorkingPath & "\", 1)
		ShellExecute(@ScriptFullPath, "/setup " & $sType, @ScriptDir, "runas")
		Exit

	EndIf

	; Disable Main GUI
	_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGUI)

	; If it is installed and the type is Server, ask if want to keep config
	If $g_iSetupStatus = 2 and Not $bQuiet Then
		$nKeepConfig = MsgBox(BitOR($MB_YESNO,$MB_ICONQUESTION), $_g_sMsgBox_KeepConfigTitle, $_g_sMsgBox_KeepConfig)
	EndIf

	; If select no to keep config or is not installed
	If $nKeepConfig = 7 And $bServerSetup Then
		; Call the Function to retrieve repeater and ID
		$bServerSetupData = SetupServer()
	EndIf

	;If Cancel Button was pressed on the SetupServer()
	If Not $bServerSetupData Then
		_deleteself($g_sWorkingPath, 5)
		Exit
	EndIf

	;If a previous version is already installed
	If $g_iVersion > $g_sInstVersion And $g_iSetupStatus > 0 Then

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

	;If is the same version, it is installed as station and Quiet
	ElseIf $g_iVersion = $g_sInstVersion And $g_iSetupStatus = 1 and $bQuiet Then
		_deleteself($g_sWorkingPath, 5)
		Exit
	Else
		$pid = Run($g_sWorkingPath & "\IntermixVNC.exe -kill")
		ProcessWaitClose($pid, 15)

	EndIf

	;Show message about setup
	SplashTextOn($_g_sProgramTitle, $_g_sSplash_Setup, 500, 50, -1, -1, 4, "Arial", 11)

	;=== INSTALL FILES ======================================================================================
	DirCreate($g_sInstDir)

	FileInstall("files\SecureVNCPlugin.dsm", $g_sInstDir & "\SecureVNCPlugin.dsm", 1)
	FileInstall("files\ultravnc.ini", $g_sInstDir & "\ultravnc.ini", 1)
	FileInstall("files\unblock.js", $g_sInstDir & "\unblock.js", 1)
	FileInstall("files\vnchooks.dll", $g_sInstDir & "\vnchooks.dll", 1)
	FileInstall("files\logmessages.dll", $g_sInstDir & "logmessages.dll", 1)
	FileInstall("files\First_Server_ClientAuth.pubkey", $g_sInstDir & "\First_Server_ClientAuth.pubkey", 1)

	If @OSVersion = "WIN_XP" or @OSVersion = "WIN_2003" Then
		FileInstall("files\winvnc_xp.exe", $g_sInstDir & "\IntermixVNC.exe", 1)
	Else
		FileInstall("files\winvnc.exe", $g_sInstDir & "\IntermixVNC.exe", 1)
	EndIf
	;========================================================================================================

	ShellExecuteWait($g_sInstDir & "\unblock.js", "", @ScriptDir, "")
	FileCopy(@ScriptDir & "\" & @ScriptName, $g_sInstDir & "\IntermixClient.exe", 9)

	; Configure instantsupport.ini
	IniWrite($g_sInstDir & "\intermix.ini", "InstantSupport", "ID", $g_iNumId)

	; Create Start Shortcuts
	DirCreate(@ProgramsCommonDir & "\" & $_g_sProgramName)
	FileCreateShortcut(@ProgramFilesDir & "\IntermixSupport\" & $_g_sCompanyName & "\IntermixClient.exe", @ProgramsCommonDir & "\" & $_g_sProgramName & "\" & $_g_sShortcutName & ".lnk", "")
	FileCreateShortcut(@ProgramFilesDir & "\IntermixSupport\" & $_g_sCompanyName & "\IntermixClient.exe", @ProgramsCommonDir & "\" & $_g_sProgramName & "\" & $_g_sRemoveShortcutName & ".lnk", "", "/remove")

	; Create Desktop shortcut
	FileCreateShortcut(@ProgramFilesDir & "\IntermixSupport\" & $_g_sCompanyName & "\IntermixClient.exe", @DesktopCommonDir & "\" & $_g_sShortcutName & ".lnk", "")

	; CREATE VNC SERVICE AS DEMAND
	RunWait(@ComSpec & " /c " & 'sc create ' & $g_sServiceName & ' binPath= "\"' & $g_sInstDir & '\IntermixVNC.exe\" -service" type= own start= demand tag= no error= normal depend= Tcpip DisplayName= ' & $g_sServiceName & ' obj= LocalSystem', "", @SW_HIDE)
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $g_sServiceName, "Description", "REG_SZ", "Instant Support Service for " & $_g_sCompanyName)
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $g_sServiceName, "WOW64", "REG_DWORD", "0x00000001")

	; Create Program Keys
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "SupportTeam", "REG_SZ", $_g_sCompanyName)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Directory", "REG_EXPAND_SZ", @ProgramFilesDir & "\IntermixSupport\" & $_g_sCompanyName)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Program", "REG_EXPAND_SZ", @ProgramFilesDir & "\IntermixSupport\" & $_g_sCompanyName & "\IntermixClient.exe")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Version", "REG_SZ", $g_iVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Type", "REG_SZ", $sTypeSetup)

	;Create Control Panel Keys
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "DisplayIcon", "REG_SZ", '"' & $g_sInstDir & "\IntermixClient.exe" & '",0')
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "DisplayName", "REG_SZ", $_g_sProgramName)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "DisplayVersion", "REG_SZ", $g_sVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "InstallLocation", "REG_SZ", $g_sInstDir)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "MajorVersion", "REG_DWORD", $g_sMajorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "MinorVersion", "REG_DWORD", $g_sMinorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "NoModify", "REG_DWORD", "0x00000001")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "NoRepair", "REG_DWORD", "0x00000001")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "Publisher", "REG_SZ", "Warp Code Ltda.")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "UninstallString", "REG_SZ", '"' & $g_sInstDir & "\IntermixClient.exe" & '" /remove')
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "URLInfoAbout", "REG_SZ", "https://www.warpcode.com.br/intermix/")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "VersionMajor", "REG_DWORD", $g_sMajorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "VersionMinor", "REG_DWORD", $g_sMinorVersion)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "InstallDate", "REG_SZ", @MDAY & @MON & @YEAR)
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "EstimatedSize", "REG_DWORD", "0x0000123D")
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName, "sEstimatedSize2", "REG_DWORD", "0x00001233")

	;Write the install directory to the UltraVNC Ini file
	IniWrite($g_sInstDir & "\ultravnc.ini", "admin", "path", $g_sInstDir)

	;PROCEDURES IF IT IS A SERVER SETUP ==============================================
	If $bServerSetup Then

		; Write ID and repeater index to register
		RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "ID", "REG_SZ", $g_iNumId)
		RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName, "Repeater", "REG_SZ", $g_nRepeaterIndex)

		;Write the current ID to the service config file
		IniWrite($g_sInstDir & "\ultravnc.ini", "admin", "service_commandline", "-autoreconnect ID:" & $g_iNumId & " -connect " & $_g_aRepeaterIp[$g_nRepeaterIndex] & ":" & $_g_aRepeaterPort[$g_nRepeaterIndex])

		;Start VNC Service
		RunWait(@ComSpec & " /c " & 'net start ' & $g_sServiceName, "", @SW_HIDE)

		Sleep(1000)

		;Stop VNC Service
		RunWait(@ComSpec & " /c " & 'net stop ' & $g_sServiceName, "", @SW_HIDE)

		;Modify Service Permissions to allow all users to stop and start it
		Run(@ComSpec & ' /c ' & 'sc sdset "' & $g_sServiceName & '" D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)(A;;RPWPCR;;;WD) S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)', "", @SW_HIDE)

		;Sets VNC Service as Auto Start
		RunWait(@ComSpec & " /c " & 'sc config ' & $g_sServiceName & ' start= auto', "", @SW_HIDE)

		;Start VNC Service
		RunWait(@ComSpec & " /c " & 'net start ' & $g_sServiceName, "", @SW_HIDE)


	;PROCEDURES IF IT IS A CLIENT SETUP ==============================================
	Else

		;Write the current ID to the service config file
		IniWrite($g_sInstDir & "\ultravnc.ini", "admin", "service_commandline", "-sc_exit -sc_prompt -multi -autoreconnect ID:" & $g_iNumId & " -connect " & $_g_aRepeaterIp[$g_nRepeaterIndex] & ":" & $_g_aRepeaterPort[$g_nRepeaterIndex])

		;Start VNC Service
		RunWait(@ComSpec & " /c " & 'net start ' & $g_sServiceName, "", @SW_HIDE)

		Sleep(1000)

		;Stop VNC Service
		RunWait(@ComSpec & " /c " & 'net stop ' & $g_sServiceName, "", @SW_HIDE)

		;Modify Service Permissions to allow all users to stop and start it
		Run(@ComSpec & ' /c ' & 'sc sdset "' & $g_sServiceName & '" D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)(A;;RPWPCR;;;WD) S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)', "", @SW_HIDE)

	EndIf

	;Verify System Language and Set ultravnc.ini permissions
	If @OSLang == "0416" Then
		RunWait('cacls ultravnc.ini /e /g todos:f', $g_sInstDir, @SW_HIDE)
	Else
		RunWait('cacls ultravnc.ini /e /g everyone:f', $g_sInstDir, @SW_HIDE)
	EndIf

	;Modify the Local GPO do allow VNC to generate Keyboard Inputs such as Ctrl+Alt+Del
	RunWait(@ComSpec & " /c " & "reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v SoftwareSASGeneration /t REG_DWORD /d 1 /f", "", @SW_HIDE)

	;Remove Splash Message
	SplashOff()

	;Asks User to restart the computer
	If $bQuiet Then
		MsgBox(0, $_g_sProgramTitle, $_g_sMsgBox_RestartCountQuiet, 10)
		Shutdown(6)
	ElseIf $bServerSetup Then
		MsgBox(0, $_g_sProgramTitle, $_g_sMsgBox_InstServerComplete)
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
		Local $ini_dir = @ProgramsCommonDir & "\" & $_g_sProgramName
		Local $shortcut = @DesktopCommonDir & "\" & $_g_sShortcutName & ".lnk"
		DirRemove($ini_dir, 1)
		FileDelete($shortcut)

		; Stop service
		RunWait(@ComSpec & " /c " & 'net stop ' & $g_sServiceName, "", @SW_HIDE)
		RunWait($g_sWorkingPath & "\IntermixVNC.exe -kill")

		; Remove registry entries
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $_g_sCompanyName)
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & $_g_sProgramName)

		; Remove VNC Service
		RunWait(@ComSpec & " /c " & 'sc delete ' & $g_sServiceName, "", @SW_HIDE)


		;delete install directory
		If $bUpdate Then
			DirRemove($g_sInstDir & "\", 1)
		Else
			_deleteself(@ProgramFilesDir & "\IntermixSupport\" & $_g_sCompanyName, 5)
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

FUNCTION:.......... closeSupport()
DESCRIPTION:....... FStop services, process and exit aplication
SYNTAX:............ No parameters

#ce ====================================================================================================
Func CloseSupport()

	If $g_iSetupStatus = 2 Then

		Exit

	ElseIf $g_iSetupStatus = 1 Then

		; Disable Main GUI
		_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGUI)

		; Hide GUI
		GUISetState(@SW_HIDE)

		;Show message that the program is closing
		SplashTextOn($_g_sProgramTitle, $_g_sSplash_ClosingSupport, 500, 50, -1, -1, 4, "Arial", 11)

		;Stop the VNC service
		RunWait(@ComSpec & " /c " & 'net stop ' & $g_sServiceName, "", @SW_HIDE)

		Exit

	Else
		If MsgBox(4, $_g_sProgramTitle, $_g_sMsgBox_CloseSupport) = 6 Then
			; Disable Main GUI
			_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $g_hMainGUI)
			SplashTextOn($_g_sProgramTitle, $_g_sSplash_ClosingSupport, 500, 50, -1, -1, 4, "Arial", 11)
			$pid = Run($g_sWorkingPath & "\IntermixVNC.exe -kill")
			ProcessWaitClose($pid, 15)
			_deleteself($g_sWorkingPath, 1)
			DirRemove($g_sWorkingPath & "\", 1)
			Exit
		EndIf

	EndIf
EndFunc
;============> closeSupport() ==============================================================

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
	Local $sAppID = $sDeletePath & "\IntermixClient.exe"
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
				& 'DEL /F /Q "' & $sDeletePath & '\IntermixClient.exe"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\SecureVNCPlugin.dsm"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\ultravnc.ini"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\intermix.ini"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\unblock.js"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\vnchooks.dll"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\logmessages.dll"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\IntermixVNC.exe"' & @CRLF _
				& 'DEL /F /Q "' & $sDeletePath & '\First_Server_ClientAuth.pubkey"' & @CRLF _
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

FUNCTION:.......... startProgressBar($iAction,$iUpdateValue)
DESCRIPTION:....... Draws and handle the Startup progress bar
SYNTAX:............ startProgressBar($iAction = 0[,$iUpdateValue = 0[)
PARAMETERS:........ [Optional] $iAction = Define what to do, default is 0, draw and start the progressbar
					[Optional] $iUpdateValue = Define how much percentage to advance in the progressbar, default is 0
#ce ====================================================================================================
Func StartProgressBar($iAction = 0,$iUpdateValue = 0)

	; Operation 1 - Update ProgressBar
	If($iAction = 1) Then
	  $g_iBarProgress = $g_iBarProgress + $iUpdateValue
	  _Metro_SetProgress($g_idProgressStartUp, $g_iBarProgress)
	  Return
	EndIf

	; Operation 2 - Finish startup screen
	If($iAction = 2) Then
		Sleep(200)
		_Metro_GUIDelete($GUI_HOVER_REG_START, $g_hStartUpGUI)
		Return
	EndIf

	$g_iBarProgress = 0

	$g_hStartUpGUI = _Metro_CreateGUI("INICIANDO...", 500, 95, -1, -1)
	$GUI_HOVER_REG_START = $g_hStartUpGUI[1]
	$g_hStartUpGUI = $g_hStartUpGUI[0]

	$lbStarting = GUICtrlCreateLabel($_g_sLabel_Start, 75, 24, 105, 20)
	GUICtrlSetFont(-1, 12, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$iconStartUp = GUICtrlCreatePic("", 15, 24, 46, 46)
	_Resource_SetToCtrlID($iconStartUp, "IMG_STARTICON")

	$g_idProgressStartUp = _Metro_CreateProgress(75, 50, 395, 20)

	GUISetState(@SW_SHOW,$g_hStartUpGUI)

EndFunc
;============> End startProgressBar() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... MainGUI()
DESCRIPTION:....... Draws the main GUI
SYNTAX:............ No parameters

#ce ====================================================================================================
Func MainGUI()

	$g_hMainGUI = _Metro_CreateGUI($_g_sProgramTitle, 500, 205, -1, -1, 1, 1)
	$GUI_HOVER_REG_MAIN = $g_hMainGUI[1]

	$GUI_CLOSE_BUTTON_MAIN = $g_hMainGUI[2]
	$GUI_MINIMIZE_BUTTON_MAIN = $g_hMainGUI[5]

	$g_hMainGUI = $g_hMainGUI[0]

	$logoIntermixMain = GUICtrlCreatePic("", 15, 24, 217, 48)
	_Resource_SetToCtrlID($logoIntermixMain, "IMG_LOGOINTERMIX")

	$barMain = GUICtrlCreatePic("", 15, 105, 470, 50)
	_Resource_SetToCtrlID($barMain, "IMG_MAINBAR")

	$lbTxtID = GUICtrlCreateLabel($_g_sLabel_ID, 28, 107, 45, 45)
	GUICtrlSetFont(-1, 30, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$g_idLabelNumID = GUICtrlCreateLabel($g_sTxtLabelIdNum, 97, 107, 135, 45)
	GUICtrlSetFont(-1, 28, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$g_idStatusMain = GUICtrlCreatePic("", 247, 105, 57, 50)
	If $g_bConnStatus Then ;==> If Connection OK
		_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSOK")
	Else ;==> If Connection Error
		_Resource_SetToCtrlID($g_idStatusMain, "IMG_STATUSERROR")
	EndIf

	If $g_iSetupStatus = 2 and $g_bConnStatus Then
		GUICtrlSetData($g_idLabelNumID, $g_sInstID)
	EndIf

	$g_idConfigMain = GUICtrlCreatePic("", 428, 105, 57, 50)
	_Resource_SetToCtrlID($g_idConfigMain, "IMG_MAINCONFIGICON")

	$lbDisclaimer = GUICtrlCreateLabel($_g_sLabel_VersionMain, 445, 185, 100, 15)
	GUICtrlSetFont(-1, 8, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUISetState(@SW_SHOW, $g_hMainGUI)

EndFunc
;============> End mainGUI() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... ConfigGUI()
DESCRIPTION:....... Draws the configuration GUI
SYNTAX:............ No parameters

#ce ====================================================================================================
Func ConfigGUI()

	$g_bConfigGUIExist = True
	$g_hConfigGUI = _Metro_CreateGUI($_g_sConfigTitle, 500, 418, -1, -1, 1, 1)
	$GUI_HOVER_REG_CONFIG = $g_hConfigGUI[1]

	$GUI_CLOSE_BUTTON_CONFIG = $g_hConfigGUI[2]
	$GUI_MINIMIZE_BUTTON_CONFIG = $g_hConfigGUI[5]

	$g_hConfigGUI = $g_hConfigGUI[0]

	$logoCompanyConfig = GUICtrlCreatePic("", 15, 29, 260, 58)
	_Resource_SetToCtrlID($logoCompanyConfig, "IMG_LOGOCOMPANY")

	$lbSupportConfig = GUICtrlCreateLabel($_g_sLabel_Support, 330, 38, 165, 35)
	GUICtrlSetFont(-1, 22, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xF4511E)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	;===========================================================================

	$lbStatusConfig = GUICtrlCreateLabel($_g_sLabel_Status, 15, 100, 105, 20)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$barConfig1 = GUICtrlCreatePic("", 15, 122, 478, 50)
	_Resource_SetToCtrlID($barConfig1, "IMG_MAINCONFIGBAR1")

	$lbStatusRepeater = GUICtrlCreateLabel($g_sTxtLabelRepeater, 64, 136, 135, 35)
	GUICtrlSetFont(-1, 18, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbStatusLatency = GUICtrlCreateLabel($g_sNumLabelLatency & "ms", 422, 136, 115, 35)
	GUICtrlSetFont(-1, 16, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	;===========================================================================

	$lbContactConfig = GUICtrlCreateLabel($_g_sLabel_Contact, 15, 185, 105, 20)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$barConfig2 = GUICtrlCreatePic("", 15, 207, 478, 75)
	_Resource_SetToCtrlID($barConfig2, "IMG_MAINCONFIGBAR2")

	$lbContactTelA = GUICtrlCreateLabel($_g_sLabel_TelA, 30, 219, 150, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbContactTelB = GUICtrlCreateLabel($_g_sLabel_TelB, 30, 249, 150, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbContactEmail = GUICtrlCreateLabel($_g_sLabel_Email, 230, 219, 250, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbContactSite = GUICtrlCreateLabel($_g_sLabel_Site, 230, 249, 250, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUISetState(@SW_SHOW,$g_hConfigGUI)
EndFunc
;============> End configGUI() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... SetupServer()
DESCRIPTION:....... Draws the a GUI to ask ID and Repeater to use
SYNTAX:............ No parameters

#ce ====================================================================================================
Func SetupServer()

	; Set MetroUI UDF Theme
	_SetTheme("Intermix")

	Local $sLabel_SetupTitle = "SERVER SETUP"
	Local $sLabel_Repeater = "REPEATER:"
	Local $sLabel_ID = "ID:"

	Local $hSetupGUI = _Metro_CreateGUI($sLabel_SetupTitle, 270, 270, -1, -1, 1, 0)
	Local $GUI_HOVER_REG_SETUP = $hSetupGUI[1]

	$hSetupGUI = $hSetupGUI[0]

	Local $idLabel_SetupTitle = GUICtrlCreateLabel($sLabel_SetupTitle, 15, 25, 250, 20)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xF4511E)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	Local $idLabel_Repeater = GUICtrlCreateLabel($sLabel_Repeater, 15, 70, 150, 15)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	Local $IdCombo_Repeater = GUICtrlCreateCombo("",15, 90, 150, 45,$CBS_DROPDOWNLIST)
	GUICtrlSetFont(-1, 10, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, 0xBEBEBE)

	GUICtrlSetData($IdCombo_Repeater, $_g_aRepeaterName[0] & "|" _
									& $_g_aRepeaterName[1] & "|" _
									& $_g_aRepeaterName[2] & "|" _
									& $_g_aRepeaterName[3] _
									, $_g_aRepeaterName[1])


	Local $idLabel_ID = GUICtrlCreateLabel($sLabel_ID, 15, 130, 150, 15)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	Local $idInput_ID = GUICtrlCreateInput("", 15, 150, 100, 25)
	GUICtrlSetFont(-1, 11, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, 0xBEBEBE)

	Local $idButton_SetupCancel = _Metro_CreateButton($GUI_HOVER_REG_SETUP, "CANCEL", 15, 205, 100, 30)

	Local $idButton_SetupOk = _Metro_CreateButton($GUI_HOVER_REG_SETUP, "OK", 130, 205, 100, 30)

	GUISetState(@SW_SHOW, $hSetupGUI)

	While 1

		If WinActive($hSetupGUI) Then

			_Metro_HoverCheck_Loop($GUI_HOVER_REG_SETUP, $hSetupGUI)

			$MainMsg = GUIGetMsg()

			Switch $MainMsg

				Case $idButton_SetupCancel
					_Metro_GUIDelete($GUI_HOVER_REG_SETUP, $hSetupGUI)
					Return False

				Case $idButton_SetupOk
					Local $nSetupID = GUICtrlRead($idInput_ID)
					Local $sRepeater = GUICtrlRead($IdCombo_Repeater)

					;Checks if ID is valid, if not, delete input and loop
					If $nSetupID < 100000 Or $nSetupID > 199999 Then
						MsgBox(BitOR($MB_OK,$MB_ICONERROR), $_g_sMsgBox_GeneralError, $_g_sMsgBox_InvalidID)
						GUICtrlSetData($idInput_ID, "")
						ContinueLoop
					EndIf

					;Retrieve the index for the arrays containing the repeater info
					Local $iRepeaterIdx = _ArraySearch($_g_aRepeaterName, $sRepeater , 0, 3)

					;Check if the repeater selected have valid information
					If $_g_aRepeaterPort[$iRepeaterIdx] = "" Or $_g_aRepeaterIp[$iRepeaterIdx] = "" Then
						MsgBox(BitOR($MB_OK,$MB_ICONERROR), $_g_sMsgBox_GeneralError, $_g_sMsgBox_InvalidRepeater)
						ContinueLoop
					EndIf

					_Metro_GUIDelete($GUI_HOVER_REG_SETUP, $hSetupGUI)

					$g_nRepeaterIndex = $iRepeaterIdx
					$g_iNumId = $nSetupID

					Return True

			EndSwitch

		Else
			Sleep(200)
		EndIf

	WEnd

EndFunc
;============> End configGUI() =========================================================================