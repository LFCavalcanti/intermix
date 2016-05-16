<<<<<<< HEAD
;#---------------------------------------------------------------------------#
;#                          CHUNK VNC - FORK SCRIPT                          #
;#---------------------------------------------------------------------------#
;#		ORIGINAL AUTHOR: SUPERCOE											 #
;#---------------------------------------------------------------------------#
;#		CURRENT AUTHOR: LUIZ FERNANDO CAVALCANTI DOS SANTOS					 #
;#		SCRIPT VERSION: 0.1.0 alpha											 #
;#		LAST EDITED: 03/05/2016												 #
;#---------------------------------------------------------------------------#

#Region ### WRAPPER DIRECTIVES ###

#AutoIt3Wrapper_Icon=img\icon.ico
#AutoIt3Wrapper_Res_Fileversion=0.1.1
#AutoIt3Wrapper_Res_LegalCopyright=GPL3
#AutoIt3Wrapper_Res_Language=1046
#AutoIt3Wrapper_Res_Description=Remote Support tool for IT Pros

#AutoIt3Wrapper_Outfile=..\..\_TEST\IntermixClient.Exe

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

#include ".\includes\ResourcesEx.au3"
#include ".\includes\MetroGUI_UDF.au3"
#include ".\includes\_language\textVariables.au3"
#include ".\includes\_repeater\repeaterData.au3"

#endregion ### INCLUDES ###

#region ### VARIABLES ###

Global $numId = 0
Global $txtIdNum = "------"
Global $barProgress = 0

Global $trayInstall = ""
Global $trayInstallServer = ""
Global $trayExit = ""

Global $ProgressStartUp = ""
Global $startUpGui = ""
Global $GUI_HOVER_REG_START = ""

Global $mainGui = ""
Global $GUI_HOVER_REG_MAIN = ""
Global $GUI_CLOSE_BUTTON_MAIN = ""
Global $GUI_MINIMIZE_BUTTON_MAIN = ""
Global $statusMain = ""
Global $configMain = ""
Global $lbNumID = ""

Global $txtRepeater = "---------"
Global $numLatency = "----"

Global $configGui = ""
Global $configGuiExist = False
Global $GUI_HOVER_REG_CONFIG = ""
Global $GUI_CLOSE_BUTTON_CONFIG = ""
Global $GUI_MINIMIZE_BUTTON_CONFIG = ""

Global $str_version = "0.1.1 ALPHA"
Global $str_MajorVersion = "0x00000001"
Global $Str_MinorVersion = "0x00000000"
Global $version = 11
Global $Inst_type_setup = ""
Global $setupStatus = 0
Global $Inst_Status = 0
Global $workingpath = @AppDataDir & "\Intermix_Temp_Files"
Global $cmdline_partwo = ""
Global $socket = ""
Global $servicename = "IntermixSupport_" & $str_company_name
Global $connStatus = False
Global $tmpFiles = False

#endregion ### VARIABLES ###

#region ### REGISTRY VARIABLES ###

; Read Registry Key for a possible existing installation
Global $Inst_dir = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Directory") ;Should contain the directory path
Global $Inst_exe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Program") ;Should contain the FULL path
Global $Inst_type = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Type") ;Should contain the Type(workstation or server)
Global $Inst_version = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Version"); Should contain a INT number for the version installed
Global $Inst_ID = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "ID");Read the current ID, when type is server
Global $repeaterIndex = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Repeater") ;Read the repeater in use when type is server
Global $Inst_service = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "DisplayName")

#endregion ### REGISTRY VARIABLES ###

#Region ### START UP ###

;~ HANDLE COMMAND LINE PARAMETERS
handlerCmdLineParam()

; Set MetroUI UDF Theme
_SetTheme("Intermix")

;~ Start the progress bar
startProgressBar()
Sleep(200)

#EndRegion ### START UP ###

#region ### INICIALIZATION PROCEDURES ###

;Advanced Progressbar
startProgressBar(1,10)

;~ CHECK IF THE SOFTWARE IS INSTALED IN THE SYSTEM
verifySetupStatus()

;Advanced Progressbar
startProgressBar(1,10)

; IF Installed, check
If $setupStatus > 0 Then
	;~ VERIFY THE INSTALATTION PARAMETERS AND VERSION
	handlerInstalledStatus()
Else
	;~ Extract files to Temp Directories if not installed.
	extractTempFiles()
EndIf

;Advanced Progressbar
startProgressBar(1,30)


;Test the connection to the Repeater and Generate ID
If $setupStatus = 2 Then ;If server, just test
	$connStatus = testConnection(True, $repeaterIndex)
Else
	$connStatus = testConnection()
	;Generate an ID
;~ 	generateID()
EndIf

;Advanced Progressbar
startProgressBar(1,20)

; Connect the VNC to Repeater
vncConnection()

;Advanced Progressbar
startProgressBar(1,30)
Sleep(500)
startProgressBar(2)

; Initialize the GUI
mainGUI()



; Enable the scripts ability to pause. (otherwise tray menu is disabled)
Break(1)

; Create the tray icon. Default tray menu items (Script Paused/Exit) will not be shown.
Opt("TrayMenuMode", 1)
If $setupStatus < 1 Then
	$trayInstall = TrayCreateItem($str_button_install)
	$trayInstallServer = TrayCreateItem($str_button_installserver)
EndIf
$trayExit = TrayCreateItem($str_button_exit)

#endregion ### INICIALIZATION PROCEDURES ###

#region ### MAIN LOOP ###
; Main Loop
While 1

	If WinActive($mainGui) Then

		; Get mouse info
		Local $mouse = GUIGetCursorInfo($mainGui)

		_Metro_HoverCheck_Loop($GUI_HOVER_REG_MAIN, $mainGui)

		Local $MainMsg = GUIGetMsg()

		;========================== HOVER LOOP FOR CONTROL BUTTONS ==========================
		Switch $MainMsg
			Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON_MAIN
				closeSupport()
			Case $GUI_MINIMIZE_BUTTON_MAIN
				GUISetState(@SW_MINIMIZE,$mainGui)
		EndSwitch
		;====================================================================================

		; =========================HOVER STATUS==============================================
		; Mouse em hover no botão
		If $mouse[4] = $statusMain Then
			_Resource_SetToCtrlID($statusMain, "IMG_STATUSHOVER")
		ElseIf $connStatus Then
			_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")
		Else
			_Resource_SetToCtrlID($statusMain, "IMG_STATUSERROR")
		EndIf
		; ===================================================================================

		; ==========================HOVER CONFIG=============================================
		; Mouse em hover no botão
		If $mouse[4] = $configMain Then
			_Resource_SetToCtrlID($configMain, "IMG_MAINCONFIGHOVER")
		Else
			_Resource_SetToCtrlID($configMain, "IMG_MAINCONFIGICON")
		EndIf
		; ===================================================================================

		; ========================== DETECTS MOUSE CLICKS =============================================
		If $mouse[2] = 1 Then

			;If click on Status Button
			If $mouse[4] = $statusMain Then

				_Resource_SetToCtrlID($statusMain, "IMG_STATUSCLICK")
				Sleep(50)
				vncConnection(True)

			;If click on config Button
			ElseIf $mouse[4] = $configMain Then

				_Resource_SetToCtrlID($configMain, "IMG_MAINCONFIGCLICK")
				Sleep(50)
				If Not $configGuiExist Then
					configGUI()
				EndIf

			EndIf

		EndIf

		ContinueLoop

	EndIf

	If $configGuiExist And WinActive($configGui) Then

		_Metro_HoverCheck_Loop($GUI_HOVER_REG_CONFIG, $configGui)

		$ConfigMsg = GUIGetMsg()

		Switch $ConfigMsg
		;=========================================Control-Buttons===========================================
			Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON_CONFIG
				_Metro_GUIDelete($GUI_HOVER_REG_CONFIG, $configGui)
				$configGuiExist = False
			Case $GUI_MINIMIZE_BUTTON_CONFIG
				GUISetState(@SW_MINIMIZE,$configGui)
		;===================================================================================================
		EndSwitch

		ContinueLoop

	Else

		Sleep(200)

	EndIf

	#Region ### TRAY EVENTS ###
	; Tray events.
	Local $trayMsg = TrayGetMsg()

	If $setupStatus > 0 Then
		Switch $trayMsg
			Case $trayExit
				closesupport()
		EndSwitch
	Else
		Switch $trayMsg
			Case $trayInstall
				setup()
			Case $trayInstallServer
				setup("/server")
			Case $trayExit
				closesupport()
		EndSwitch
	EndIf
	#EndRegion ### TRAY EVENTS ###

WEnd
#endregion ### MAIN LOOP ###

#cs FUNCTION ===========================================================================================

FUNCTION:.......... handlerCmdLineParam()
DESCRIPTION:....... Read command line parameters passed and calls the needed functions.
SYNTAX:............ No parameters passed, uses the cmdline from process calling, as follows:
					/setup = Execute all install procedures
					/remove = Execute all deinstall procedures
					/quiet = Supress all messages, does upgrade without asking if /setup is used

#ce ====================================================================================================
Func handlerCmdLineParam()

	; Verify if a second parameter is present and read it.
	If $cmdline[0] > 1 Then
		$cmdline_partwo = $cmdline[2]
	EndIf

	;Read and call the needed funtion
	If $cmdline[0] > 0 Then
		Switch $cmdline[1]

			Case "/setup"
				setup($cmdline_partwo)

			Case "/remove"
				remove($cmdline_partwo)

			Case Else
				MsgBox(0, $str_msgbox_error, $str_errorunknowncommand, 30)
				Exit
		EndSwitch
	EndIf
EndFunc
;============> End handlerCmdLineParam() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... verifySetupStatus()
DESCRIPTION:....... Verify the register parameters read and test if the aplication is already installed. If detecs server type setup, set ID flag to false.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func verifySetupStatus()

	If $Inst_version > 0 And $Inst_service == $servicename And FileExists($Inst_exe) Then ;Test VNC Service and program path
		$setupStatus = 1
;~ 		ConsoleWrite("SETUP STATUS: " & $setupStatus & @CRLF)
		If $Inst_type == "Server" Then ; If Server type, don't generate an ID
			$setupStatus = 2
;~ 			ConsoleWrite("SETUP STATUS: " & $setupStatus & @CRLF)
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
Func handlerInstalledStatus()

	If $Inst_exe == @AutoItExe Then;If the Script is running from the installed path

		$workingpath = $Inst_dir ;set the working path to the installed directory
		$numId = $Inst_ID ;Use the installed ID

	Else ; If the Instant Support is Installed but the Script is not Running from the installed directory

		If MsgBox(4, $str_program_title, $str_openinstalled) = 6 Then
			Run($Inst_exe) ; Run the installed exe
			Exit

		Else
			$setupStatus = 0 ;Define to the rest of the script, it's running as not installed
			extractTempFiles() ;If doesn't run the installed, run the current as portable.
		EndIf
	EndIf
EndFunc
;============> End handlerInstalledStatus() ==============================================================


#cs FUNCTION ===========================================================================================

FUNCTION:.......... extractTempFiles()
DESCRIPTION:....... Extract files to a Temp Directory.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func extractTempFiles()
	; Extract files and create the TEMP work directory
	; Check if there is another temp directory created
	If FileExists(@AppDataDir & "\Intermix_Temp_Files") Then
		$workingpath = @AppDataDir & "\Intermix_Temp_Files_" & Random(100000, 999999, 1)
	EndIf

	DirCreate($workingpath)

	FileInstall("files\intermix.ini", $workingpath & "\intermix.ini", 1)
	FileInstall("files\SecureVNCPlugin.dsm", $workingpath & "\SecureVNCPlugin.dsm", 1)
	FileInstall("files\ultravnc.ini", $workingpath & "\ultravnc.ini", 1)
	FileInstall("files\winvnc.exe", $workingpath & "\IntermixVNC.exe", 1)
	FileInstall("files\unblock.js", $workingpath & "\unblock.js", 1)
	FileInstall("files\First_Server_ClientAuth.pubkey", $workingpath & "\First_Server_ClientAuth.pubkey", 1)

	ShellExecuteWait($workingpath & "\unblock.js", "", @ScriptDir, "")

	FileCopy(@ScriptDir & "\" & @ScriptName, $workingpath & "\IntermixClient.exe", 9)

	$tmpFiles = True ; => Control flag if there is temp files for this session

EndFunc
;============> End extractTempFiles()) ==============================================================



#cs FUNCTION ==================================================================================================

FUNCTION:.......... testConnection($testType,$i)
DESCRIPTION:....... Testa a conexão para o Repeater. Return True or False if the tested repeater is available.
SYNTAX:............ testConnection($testType,$RepeaterIndex[0][)
PARAMETERS:........ [Optional]$testType - If True is server, test only the designated, Default False
					[Optional]$RepeaterIdx - Which Repeater from the list will be testes, for server type. Default 0.

#ce ===========================================================================================================
Func testConnection($testType = False,$repeaterIdx = 0)

	Local $latency
	Local $socket

	;Start TCP service
	TCPStartup()

	;If just checking current connection or server setup
	If $testType Then

		$socket = TCPConnect(TCPNameToIP($repeaterIp[$RepeaterIdx]), $repeaterPort[$RepeaterIdx])
		$latency = Ping($repeaterIp[$RepeaterIdx],1000)

		If $socket = -1 Or $latency = 0 Or $latency > 500 Then
			TCPShutdown()
			$txtRepeater = "---------"
			$numLatency = "----"
			Return False
		Else
			TCPShutdown()
			$txtRepeater = $repeaterName[$RepeaterIdx]
			$numLatency = $latency
			Return True
		EndIf

	Else

		;Test connection with the repeaters in crescent order
		While $RepeaterIdx <= 3
			$socket = TCPConnect(TCPNameToIP($repeaterIp[$RepeaterIdx]), $repeaterPort[$RepeaterIdx])
			$latency = Ping($repeaterIp[$RepeaterIdx],1000)
			If $socket = -1 Or $latency = 0 Or $latency > 500 Then
				$RepeaterIdx+=1
			Else
				TCPShutdown()
				$txtRepeater = $repeaterName[$RepeaterIdx]
				$numLatency = $latency
				$repeaterIndex = $RepeaterIdx
				Return True
			EndIf
		WEnd

	EndIf

	TCPShutdown()
	$txtRepeater = "---------"
	$numLatency = "----"
	Return False

EndFunc
;============> End testConnection() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... generateID()
DESCRIPTION:....... Generates an ID number to use on the VNC connection.
SYNTAX:............ No parameters

#ce ====================================================================================================
Func generateID()

	$lowerlimit = 200000
	$upperlimit = 999999
	$numId = Random($lowerlimit, $upperlimit, 1)
	$txtIdNum = $numId

EndFunc
;============> End testConnection() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... vncConnection($connOp)
DESCRIPTION:....... Faz a conexão reversa do UltraVNC com o Repeater
SYNTAX:............ vncConnection($connOp = False)
PARAMETERS:........ [Optional] $connOP = Define if it's a retry or reconnect command from GUI, default is False

#ce ====================================================================================================
Func vncConnection($connOp = False)

	If $connOp Then ; If reconnect

		;Set icon on GUI
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSCONN")

		;Terminate current VNC process
		$pid = Run($workingpath & "\IntermixVNC.exe -kill")
		ProcessWaitClose($pid, 15)

		;Test the connection
		If $setupStatus = 2 Then ;If server, just test
			$connStatus = testConnection(True, $repeaterIndex)
		Else
			$connStatus = testConnection(False)
			; Since not server, write null ID on GUI
			GUICtrlSetData($lbNumID, "------")
		EndIf
		Sleep(2000)
	EndIf

	If $connStatus And $setupStatus = 2 Then ;==> If Connection OK and Server

		;Stop the service
		RunWait(@ComSpec & " /c " & 'net stop ' & $servicename, "", @SW_HIDE)

		;Start the service
		RunWait(@ComSpec & " /c " & 'net start ' & $servicename, "", @SW_HIDE)

		;Set icon on GUI
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")

		;Set ID Num on GUI as Installed ID
		GUICtrlSetData($lbNumID, $Inst_ID)

		Return

	ElseIf $connStatus And $setupStatus = 1 Then ;==> If Connection OK and Station

		;Gera um novo ID
		generateID()

		;Stop the service
		RunWait(@ComSpec & " /c " & 'net stop ' & $servicename, "", @SW_HIDE)

		;Write the current ID to the service config file
		IniWrite($workingpath & "\ultravnc.ini", "admin", "service_commandline", "-sc_exit -sc_prompt -multi -autoreconnect ID:" & $numId & " -connect " & $repeaterIp[$repeaterIndex] & ":" & $repeaterPort[$repeaterIndex])

		;Start the service
		RunWait(@ComSpec & " /c " & 'net start ' & $servicename, "", @SW_HIDE)

		GUICtrlSetData($lbNumID, $numId)
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")

	ElseIf $connStatus Then ;==> If Connection OK and not installed

		;Generates new ID
		generateID()

		; Start the VNC server and make a reverse connection to the repeater.
		ShellExecute($workingpath & "\IntermixVNC.exe", "-sc_exit -sc_prompt -multi -autoreconnect ID:" & $numId & " -connect " & $repeaterIp[$repeaterIndex] & ":" & $repeaterPort[$repeaterIndex] & " -run")

		; Give some time to the connection
		Sleep(2000)

		GUICtrlSetData($lbNumID, $numId)

		Sleep(500)

		_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")



	Else ;==> If Connection Error

		GUICtrlSetData($lbNumID, "------")
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSERROR")

	EndIf



EndFunc
;============> End vncConnection() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... setup($type)
DESCRIPTION:....... Instala o Intermix no
SYNTAX:............ vncConnection($connOp = False)
PARAMETERS:........ [Optional] $connOP = Define if it's a retry or reconnect command from GUI, default is False

#ce ====================================================================================================
Func setup($type = "/station")

	;Hide GUI
	GUISetState(@SW_HIDE)

	;Control flags to guide the installation procedure
	Local $quiet = False
	Local $serverSetup = False
	Local $IdInvalid = True
	Local $RepInvalid = True
	Local $update = False
	Local $Inst_type_setup = "Workstation"
	Local $repIndex = 0

	;Set the installation Directory
	Local $Inst_dir = @ProgramFilesDir & "\IntermixSupport\" & $str_company_name & "\"

	;Check if the Script is running with admin privileges and set flags for cmdline parameters
	If IsAdmin() Then ; If is admin, set the parameter to variables
		If $type == "/server" Then
			$serverSetup = True
			$Inst_type_setup = "Server"
		ElseIf $type == "/quiet" Then
			$quiet = True
		EndIf
	Else ;If not, run it as admin
		_deleteself($workingpath, 5)
		ShellExecute(@ScriptFullPath, "/setup " & $type, @ScriptDir, "runas")
		Exit
	EndIf

	; Request and validate the ID
	If $serverSetup Then
		While $IdInvalid
;~ 			WinSetOnTop($str_program_title, "", 0)
			$numId = InputBox($str_msgbox_serviceinstallation, $str_serviceenteranidnumber, $numId,"",200,125)
			If $numId < 200000 And $numId > 100000 Then
				$IdInvalid = False
			Else
				If MsgBox(1, $str_config_title, $str_serviceinvalidid) == 2 Then
					_deleteself($workingpath, 5)
					Exit ; Chamar função para fechar aplicação ou simplesmente interromper e returnar valor
				EndIf
			EndIf
		WEnd
	EndIf

	; If server, request Repeater to be used
	If $serverSetup Then
		While $RepInvalid
			$repIndex = InputBox($askRepIndexTitle,$askRepIndexMsg,"","",200,150)
			If $repIndex >= 0 And $repIndex < 4 Then
				$repeaterIndex = $repIndex
				$RepInvalid = False
;~ 				$repIndex = testConnection(True,"0")
			ElseIf @error = 1 Then
				_deleteself($workingpath, 5)
				Exit
			EndIf
		WEnd
	EndIf

	; Disable Main GUI
	_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $mainGui)

	;If a previous version is already installed
	If $version > $Inst_version And $setupStatus > 0 Then

		; Show message about the update
		SplashTextOn($str_program_title, $str_inst_update, 500, 50, -1, -1, 4, "Arial", 11)

		;Call Remove Function for update
		$update = remove("/update")

		;Verify the update control flag
		If $update Then
			Sleep(3000)
		Else
			MsgBox(0, $str_program_title, $str_update_fail)
			Exit
		EndIf

		;disable de Splash Text
		SplashOff()

	Else
		$pid = Run($workingpath & "\IntermixVNC.exe -kill")
		ProcessWaitClose($pid, 15)

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

FUNCTION:.......... closeSupport()
DESCRIPTION:....... FStop services, process and exit aplication
SYNTAX:............ No parameters

#ce ====================================================================================================
Func closeSupport()
;~ 	WinSetOnTop($str_program_title, "", 0)
	If $setupStatus = 2 Then

		Exit

	ElseIf $setupStatus = 1 Then

		; Disable Main GUI
		_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $mainGui)

		; Hide GUI
		GUISetState(@SW_HIDE)

		;Show message that the program is closing
		SplashTextOn($str_program_title, $str_end_app, 500, 50, -1, -1, 4, "Arial", 11)

		;Stop the VNC service
		RunWait(@ComSpec & " /c " & 'net stop ' & $servicename, "", @SW_HIDE)

		Exit

	Else
		If MsgBox(4, $str_program_title, $str_endsupportsession) = 6 Then
			; Disable Main GUI
			_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $mainGui)
			SplashTextOn($str_program_title, $str_end_app, 500, 50, -1, -1, 4, "Arial", 11)
			$pid = Run($workingpath & "\IntermixVNC.exe -kill")
			ProcessWaitClose($pid, 15)
			_deleteself($workingpath, 5)
			Exit
		EndIf

	EndIf
EndFunc
;============> closeSupport() ==============================================================

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
	Local $sAppID = $path & "\IntermixClient.exe"
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
				& 'DEL /F /Q "' & $path & '\IntermixClient.exe"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\SecureVNCPlugin.dsm"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\ultravnc.ini"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\intermix.ini"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\unblock.js"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\IntermixVNC.exe"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\First_Server_ClientAuth.pubkey"' & @CRLF _
				& 'RD /S /Q "' & $path & '"' & @CRLF _
				& 'IF EXIST "' & $path & '" GOTO DELETE' & @CRLF _
				& 'GOTO END' & @CRLF _
				& @CRLF _
				& ':END' & @CRLF _
				& 'DEL "' & @TempDir & '\scratch.bat"'
	FileWrite(@TempDir & "\scratch.bat", $scmdfile)
	Return Run(@TempDir & "\scratch.bat", @TempDir, @SW_HIDE)
EndFunc   ;==>_deleteself
;============> _deleteself() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... startProgressBar($operation,$value)
DESCRIPTION:....... Draws and handle the Startup progress bar
SYNTAX:............ startProgressBar($operation = 0[,$value = 0[)
PARAMETERS:........ [Optional] $operation = Define what to do, default is 0, draw and start the progressbar
					[Optional] $value = Define how much percentage to advance in the progressbar, default is 0
#ce ====================================================================================================
Func startProgressBar($operation = 0,$value = 0)

	; Operation 1 - Update ProgressBar
	If($operation = 1) Then
	  $barProgress = $barProgress + $value
	  _Metro_SetProgress($ProgressStartUp, $barProgress)
	  Return
	EndIf

	; Operation 2 - Finish startup screen
	If($operation = 2) Then
		Sleep(200)
		_Metro_GUIDelete($GUI_HOVER_REG_START, $startUpGui)
		Return
	EndIf

	$barProgress = 0

	$startUpGui = _Metro_CreateGUI("INICIANDO...", 500, 95, -1, -1)
	$GUI_HOVER_REG_START = $startUpGui[1]
	$startUpGui = $startUpGui[0]

	$lbStarting = GUICtrlCreateLabel($txtStart, 75, 24, 105, 20)
	GUICtrlSetFont(-1, 12, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$iconStartUp = GUICtrlCreatePic("", 15, 24, 46, 46)
	_Resource_SetToCtrlID($iconStartUp, "IMG_STARTICON")

	$ProgressStartUp = _Metro_CreateProgress(75, 50, 395, 20)

	GUISetState(@SW_SHOW,$startUpGui)

EndFunc
;============> End startProgressBar() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... mainGUI()
DESCRIPTION:....... Draws the main GUI
SYNTAX:............ No parameters

#ce ====================================================================================================
Func mainGUI()

	$mainGui = _Metro_CreateGUI($str_program_title, 500, 205, -1, -1, 1, 1)
	$GUI_HOVER_REG_MAIN = $mainGui[1]

	$GUI_CLOSE_BUTTON_MAIN = $mainGui[2]
	$GUI_MINIMIZE_BUTTON_MAIN = $mainGui[5]

	$mainGui = $mainGui[0]

	$logoIntermixMain = GUICtrlCreatePic("", 15, 24, 217, 48)
	_Resource_SetToCtrlID($logoIntermixMain, "IMG_LOGOINTERMIX")

	$barMain = GUICtrlCreatePic("", 15, 105, 470, 50)
	_Resource_SetToCtrlID($barMain, "IMG_MAINBAR")

	$lbTxtID = GUICtrlCreateLabel($txtID, 28, 107, 45, 45)
	GUICtrlSetFont(-1, 30, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbNumID = GUICtrlCreateLabel($txtIdNum, 97, 107, 135, 45)
	GUICtrlSetFont(-1, 28, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$statusMain = GUICtrlCreatePic("", 247, 105, 57, 50)
	If $connStatus Then ;==> If Connection OK
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")
	Else ;==> If Connection Error
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSERROR")
	EndIf

	If $setupStatus = 2 and $connStatus Then
		GUICtrlSetData($lbNumID, $Inst_ID)
	EndIf

	$configMain = GUICtrlCreatePic("", 428, 105, 57, 50)
	_Resource_SetToCtrlID($configMain, "IMG_MAINCONFIGICON")

	$lbDisclaimer = GUICtrlCreateLabel($txtDisclaimerMain, 445, 185, 100, 15)
	GUICtrlSetFont(-1, 8, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUISetState(@SW_SHOW, $mainGui)

EndFunc
;============> End mainGUI() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... configGUI()
DESCRIPTION:....... Draws the configuration GUI
SYNTAX:............ No parameters

#ce ====================================================================================================
Func configGUI()

	$configGuiExist = True
	$configGui = _Metro_CreateGUI($str_config_title, 500, 418, -1, -1, 1, 1)
	$GUI_HOVER_REG_CONFIG = $configGui[1]

	$GUI_CLOSE_BUTTON_CONFIG = $configGui[2]
	$GUI_MINIMIZE_BUTTON_CONFIG = $configGui[5]

	$configGui = $configGui[0]

	$logoCompanyConfig = GUICtrlCreatePic("", 15, 29, 260, 58)
	_Resource_SetToCtrlID($logoCompanyConfig, "IMG_LOGOCOMPANY")

	$lbSupportConfig = GUICtrlCreateLabel($txtSupport, 330, 38, 165, 35)
	GUICtrlSetFont(-1, 22, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xF4511E)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	;===========================================================================

	$lbStatusConfig = GUICtrlCreateLabel($txtStatus, 15, 100, 105, 20)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$barConfig1 = GUICtrlCreatePic("", 15, 122, 478, 50)
	_Resource_SetToCtrlID($barConfig1, "IMG_MAINCONFIGBAR1")

	$lbStatusRepeater = GUICtrlCreateLabel($txtRepeater, 64, 136, 135, 35)
	GUICtrlSetFont(-1, 18, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbStatusLatency = GUICtrlCreateLabel($numLatency & "ms", 422, 136, 115, 35)
	GUICtrlSetFont(-1, 16, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	;===========================================================================

	$lbContactConfig = GUICtrlCreateLabel($txtContact, 15, 185, 105, 20)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$barConfig2 = GUICtrlCreatePic("", 15, 207, 478, 75)
	_Resource_SetToCtrlID($barConfig2, "IMG_MAINCONFIGBAR2")

	$lbContactTelA = GUICtrlCreateLabel($txtTelA, 30, 219, 150, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbContactTelB = GUICtrlCreateLabel($txtTelB, 30, 249, 150, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbContactEmail = GUICtrlCreateLabel($txtEmail, 230, 219, 250, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbContactSite = GUICtrlCreateLabel($txtSite, 230, 249, 250, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUISetState(@SW_SHOW,$configGui)
EndFunc
;============> End configGUI() ==============================================================
=======
;#---------------------------------------------------------------------------#
;#                          CHUNK VNC - FORK SCRIPT                          #
;#---------------------------------------------------------------------------#
;#		ORIGINAL AUTHOR: SUPERCOE											 #
;#---------------------------------------------------------------------------#
;#		CURRENT AUTHOR: LUIZ FERNANDO CAVALCANTI DOS SANTOS					 #
;#		SCRIPT VERSION: 0.1.0 alpha											 #
;#		LAST EDITED: 03/05/2016												 #
;#---------------------------------------------------------------------------#

#Region ### WRAPPER DIRECTIVES ###

#AutoIt3Wrapper_Icon=img\icon.ico
#AutoIt3Wrapper_Res_Fileversion=0.1.1
#AutoIt3Wrapper_Res_LegalCopyright=GPL3
#AutoIt3Wrapper_Res_Language=1046
#AutoIt3Wrapper_Res_Description=Remote Support tool for IT Pros

#AutoIt3Wrapper_Outfile=..\..\_TEST\IntermixClient.Exe

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

#include ".\includes\ResourcesEx.au3"
#include ".\includes\MetroGUI_UDF.au3"
#include ".\includes\_language\textVariables.au3"
#include ".\includes\_repeater\repeaterData.au3"

#endregion ### INCLUDES ###

#region ### VARIABLES ###

Global $numId = 0
Global $txtIdNum = "------"
Global $barProgress = 0

Global $trayInstall = ""
Global $trayInstallServer = ""
Global $trayExit = ""

Global $ProgressStartUp = ""
Global $startUpGui = ""
Global $GUI_HOVER_REG_START = ""

Global $mainGui = ""
Global $GUI_HOVER_REG_MAIN = ""
Global $GUI_CLOSE_BUTTON_MAIN = ""
Global $GUI_MINIMIZE_BUTTON_MAIN = ""
Global $statusMain = ""
Global $configMain = ""
Global $lbNumID = ""

Global $txtRepeater = "---------"
Global $numLatency = "----"

Global $configGui = ""
Global $configGuiExist = False
Global $GUI_HOVER_REG_CONFIG = ""
Global $GUI_CLOSE_BUTTON_CONFIG = ""
Global $GUI_MINIMIZE_BUTTON_CONFIG = ""

Global $str_version = "0.1.1 ALPHA"
Global $str_MajorVersion = "0x00000001"
Global $Str_MinorVersion = "0x00000000"
Global $version = 11
Global $Inst_type_setup = ""
Global $setupStatus = 0
Global $Inst_Status = 0
Global $workingpath = @AppDataDir & "\Intermix_Temp_Files"
Global $cmdline_partwo = ""
Global $socket = ""
Global $servicename = "IntermixSupport_" & $str_company_name
Global $connStatus = False
Global $tmpFiles = False

#endregion ### VARIABLES ###

#region ### REGISTRY VARIABLES ###

; Read Registry Key for a possible existing installation
Global $Inst_dir = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Directory") ;Should contain the directory path
Global $Inst_exe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Program") ;Should contain the FULL path
Global $Inst_type = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Type") ;Should contain the Type(workstation or server)
Global $Inst_version = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Version"); Should contain a INT number for the version installed
Global $Inst_ID = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "ID");Read the current ID, when type is server
Global $repeaterIndex = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Intermix_Support\" & $str_company_name, "Repeater") ;Read the repeater in use when type is server
Global $Inst_service = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\" & $servicename, "DisplayName")

#endregion ### REGISTRY VARIABLES ###

#Region ### START UP ###

;~ HANDLE COMMAND LINE PARAMETERS
handlerCmdLineParam()

; Set MetroUI UDF Theme
_SetTheme("Intermix")

;~ Start the progress bar
startProgressBar()
Sleep(200)

#EndRegion ### START UP ###

#region ### INICIALIZATION PROCEDURES ###

;Advanced Progressbar
startProgressBar(1,10)

;~ CHECK IF THE SOFTWARE IS INSTALED IN THE SYSTEM
verifySetupStatus()

;Advanced Progressbar
startProgressBar(1,10)

; IF Installed, check
If $setupStatus > 0 Then
	;~ VERIFY THE INSTALATTION PARAMETERS AND VERSION
	handlerInstalledStatus()
Else
	;~ Extract files to Temp Directories if not installed.
	extractTempFiles()
EndIf

;Advanced Progressbar
startProgressBar(1,30)


;Test the connection to the Repeater and Generate ID
If $setupStatus = 2 Then ;If server, just test
	$connStatus = testConnection(True, $repeaterIndex)
Else
	$connStatus = testConnection()
	;Generate an ID
;~ 	generateID()
EndIf

;Advanced Progressbar
startProgressBar(1,20)

; Connect the VNC to Repeater
vncConnection()

;Advanced Progressbar
startProgressBar(1,30)
Sleep(500)
startProgressBar(2)

; Initialize the GUI
mainGUI()



; Enable the scripts ability to pause. (otherwise tray menu is disabled)
Break(1)

; Create the tray icon. Default tray menu items (Script Paused/Exit) will not be shown.
Opt("TrayMenuMode", 1)
If $setupStatus < 1 Then
	$trayInstall = TrayCreateItem($str_button_install)
	$trayInstallServer = TrayCreateItem($str_button_installserver)
EndIf
$trayExit = TrayCreateItem($str_button_exit)

#endregion ### INICIALIZATION PROCEDURES ###

#region ### MAIN LOOP ###
; Main Loop
While 1

	If WinActive($mainGui) Then

		; Get mouse info
		Local $mouse = GUIGetCursorInfo($mainGui)

		_Metro_HoverCheck_Loop($GUI_HOVER_REG_MAIN, $mainGui)

		Local $MainMsg = GUIGetMsg()

		;========================== HOVER LOOP FOR CONTROL BUTTONS ==========================
		Switch $MainMsg
			Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON_MAIN
				closeSupport()
			Case $GUI_MINIMIZE_BUTTON_MAIN
				GUISetState(@SW_MINIMIZE,$mainGui)
		EndSwitch
		;====================================================================================

		; =========================HOVER STATUS==============================================
		; Mouse em hover no botão
		If $mouse[4] = $statusMain Then
			_Resource_SetToCtrlID($statusMain, "IMG_STATUSHOVER")
		ElseIf $connStatus Then
			_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")
		Else
			_Resource_SetToCtrlID($statusMain, "IMG_STATUSERROR")
		EndIf
		; ===================================================================================

		; ==========================HOVER CONFIG=============================================
		; Mouse em hover no botão
		If $mouse[4] = $configMain Then
			_Resource_SetToCtrlID($configMain, "IMG_MAINCONFIGHOVER")
		Else
			_Resource_SetToCtrlID($configMain, "IMG_MAINCONFIGICON")
		EndIf
		; ===================================================================================

		; ========================== DETECTS MOUSE CLICKS =============================================
		If $mouse[2] = 1 Then

			;If click on Status Button
			If $mouse[4] = $statusMain Then

				_Resource_SetToCtrlID($statusMain, "IMG_STATUSCLICK")
				Sleep(50)
				vncConnection(True)

			;If click on config Button
			ElseIf $mouse[4] = $configMain Then

				_Resource_SetToCtrlID($configMain, "IMG_MAINCONFIGCLICK")
				Sleep(50)
				If Not $configGuiExist Then
					configGUI()
				EndIf

			EndIf

		EndIf

		ContinueLoop

	EndIf

	If $configGuiExist And WinActive($configGui) Then

		_Metro_HoverCheck_Loop($GUI_HOVER_REG_CONFIG, $configGui)

		$ConfigMsg = GUIGetMsg()

		Switch $ConfigMsg
		;=========================================Control-Buttons===========================================
			Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON_CONFIG
				_Metro_GUIDelete($GUI_HOVER_REG_CONFIG, $configGui)
				$configGuiExist = False
			Case $GUI_MINIMIZE_BUTTON_CONFIG
				GUISetState(@SW_MINIMIZE,$configGui)
		;===================================================================================================
		EndSwitch

		ContinueLoop

	Else

		Sleep(200)

	EndIf

	#Region ### TRAY EVENTS ###
	; Tray events.
	Local $trayMsg = TrayGetMsg()

	If $setupStatus > 0 Then
		Switch $trayMsg
			Case $trayExit
				closesupport()
		EndSwitch
	Else
		Switch $trayMsg
			Case $trayInstall
				setup()
			Case $trayInstallServer
				setup("/server")
			Case $trayExit
				closesupport()
		EndSwitch
	EndIf
	#EndRegion ### TRAY EVENTS ###

WEnd
#endregion ### MAIN LOOP ###

#cs FUNCTION ===========================================================================================

FUNCTION:.......... handlerCmdLineParam()
DESCRIPTION:....... Read command line parameters passed and calls the needed functions.
SYNTAX:............ No parameters passed, uses the cmdline from process calling, as follows:
					/setup = Execute all install procedures
					/remove = Execute all deinstall procedures
					/quiet = Supress all messages, does upgrade without asking if /setup is used

#ce ====================================================================================================
Func handlerCmdLineParam()

	; Verify if a second parameter is present and read it.
	If $cmdline[0] > 1 Then
		$cmdline_partwo = $cmdline[2]
	EndIf

	;Read and call the needed funtion
	If $cmdline[0] > 0 Then
		Switch $cmdline[1]

			Case "/setup"
				setup($cmdline_partwo)

			Case "/remove"
				remove($cmdline_partwo)

			Case Else
				MsgBox(0, $str_msgbox_error, $str_errorunknowncommand, 30)
				Exit
		EndSwitch
	EndIf
EndFunc
;============> End handlerCmdLineParam() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... verifySetupStatus()
DESCRIPTION:....... Verify the register parameters read and test if the aplication is already installed. If detecs server type setup, set ID flag to false.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func verifySetupStatus()

	If $Inst_version > 0 And $Inst_service == $servicename And FileExists($Inst_exe) Then ;Test VNC Service and program path
		$setupStatus = 1
;~ 		ConsoleWrite("SETUP STATUS: " & $setupStatus & @CRLF)
		If $Inst_type == "Server" Then ; If Server type, don't generate an ID
			$setupStatus = 2
;~ 			ConsoleWrite("SETUP STATUS: " & $setupStatus & @CRLF)
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
Func handlerInstalledStatus()

	If $Inst_exe == @AutoItExe Then;If the Script is running from the installed path

		$workingpath = $Inst_dir ;set the working path to the installed directory
		$numId = $Inst_ID ;Use the installed ID

	Else ; If the Instant Support is Installed but the Script is not Running from the installed directory

		If MsgBox(4, $str_program_title, $str_openinstalled) = 6 Then
			Run($Inst_exe) ; Run the installed exe
			Exit

		Else
			$setupStatus = 0 ;Define to the rest of the script, it's running as not installed
			extractTempFiles() ;If doesn't run the installed, run the current as portable.
		EndIf
	EndIf
EndFunc
;============> End handlerInstalledStatus() ==============================================================


#cs FUNCTION ===========================================================================================

FUNCTION:.......... extractTempFiles()
DESCRIPTION:....... Extract files to a Temp Directory.
SYNTAX:............ No parameter

#ce ====================================================================================================
Func extractTempFiles()
	; Extract files and create the TEMP work directory
	; Check if there is another temp directory created
	If FileExists(@AppDataDir & "\Intermix_Temp_Files") Then
		$workingpath = @AppDataDir & "\Intermix_Temp_Files_" & Random(100000, 999999, 1)
	EndIf

	DirCreate($workingpath)

	FileInstall("files\intermix.ini", $workingpath & "\intermix.ini", 1)
	FileInstall("files\SecureVNCPlugin.dsm", $workingpath & "\SecureVNCPlugin.dsm", 1)
	FileInstall("files\ultravnc.ini", $workingpath & "\ultravnc.ini", 1)
	FileInstall("files\winvnc.exe", $workingpath & "\IntermixVNC.exe", 1)
	FileInstall("files\unblock.js", $workingpath & "\unblock.js", 1)
	FileInstall("files\First_Server_ClientAuth.pubkey", $workingpath & "\First_Server_ClientAuth.pubkey", 1)

	ShellExecuteWait($workingpath & "\unblock.js", "", @ScriptDir, "")

	FileCopy(@ScriptDir & "\" & @ScriptName, $workingpath & "\IntermixClient.exe", 9)

	$tmpFiles = True ; => Control flag if there is temp files for this session

EndFunc
;============> End extractTempFiles()) ==============================================================



#cs FUNCTION ==================================================================================================

FUNCTION:.......... testConnection($testType,$i)
DESCRIPTION:....... Testa a conexão para o Repeater. Return True or False if the tested repeater is available.
SYNTAX:............ testConnection($testType,$RepeaterIndex[0][)
PARAMETERS:........ [Optional]$testType - If True is server, test only the designated, Default False
					[Optional]$RepeaterIdx - Which Repeater from the list will be testes, for server type. Default 0.

#ce ===========================================================================================================
Func testConnection($testType = False,$repeaterIdx = 0)

	Local $latency
	Local $socket

	;Start TCP service
	TCPStartup()

	;If just checking current connection or server setup
	If $testType Then

		$socket = TCPConnect(TCPNameToIP($repeaterIp[$RepeaterIdx]), $repeaterPort[$RepeaterIdx])
		$latency = Ping($repeaterIp[$RepeaterIdx],1000)

		If $socket = -1 Or $latency = 0 Or $latency > 500 Then
			TCPShutdown()
			$txtRepeater = "---------"
			$numLatency = "----"
			Return False
		Else
			TCPShutdown()
			$txtRepeater = $repeaterName[$RepeaterIdx]
			$numLatency = $latency
			Return True
		EndIf

	Else

		;Test connection with the repeaters in crescent order
		While $RepeaterIdx <= 3
			$socket = TCPConnect(TCPNameToIP($repeaterIp[$RepeaterIdx]), $repeaterPort[$RepeaterIdx])
			$latency = Ping($repeaterIp[$RepeaterIdx],1000)
			If $socket = -1 Or $latency = 0 Or $latency > 500 Then
				$RepeaterIdx+=1
			Else
				TCPShutdown()
				$txtRepeater = $repeaterName[$RepeaterIdx]
				$numLatency = $latency
				$repeaterIndex = $RepeaterIdx
				Return True
			EndIf
		WEnd

	EndIf

	TCPShutdown()
	$txtRepeater = "---------"
	$numLatency = "----"
	Return False

EndFunc
;============> End testConnection() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... generateID()
DESCRIPTION:....... Generates an ID number to use on the VNC connection.
SYNTAX:............ No parameters

#ce ====================================================================================================
Func generateID()

	$lowerlimit = 200000
	$upperlimit = 999999
	$numId = Random($lowerlimit, $upperlimit, 1)
	$txtIdNum = $numId

EndFunc
;============> End testConnection() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... vncConnection($connOp)
DESCRIPTION:....... Faz a conexão reversa do UltraVNC com o Repeater
SYNTAX:............ vncConnection($connOp = False)
PARAMETERS:........ [Optional] $connOP = Define if it's a retry or reconnect command from GUI, default is False

#ce ====================================================================================================
Func vncConnection($connOp = False)

	If $connOp Then ; If reconnect

		;Set icon on GUI
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSCONN")

		;Terminate current VNC process
		$pid = Run($workingpath & "\IntermixVNC.exe -kill")
		ProcessWaitClose($pid, 15)

		;Test the connection
		If $setupStatus = 2 Then ;If server, just test
			$connStatus = testConnection(True, $repeaterIndex)
		Else
			$connStatus = testConnection(False)
			; Since not server, write null ID on GUI
			GUICtrlSetData($lbNumID, "------")
		EndIf
		Sleep(2000)
	EndIf

	If $connStatus And $setupStatus = 2 Then ;==> If Connection OK and Server

		;Stop the service
		RunWait(@ComSpec & " /c " & 'net stop ' & $servicename, "", @SW_HIDE)

		;Start the service
		RunWait(@ComSpec & " /c " & 'net start ' & $servicename, "", @SW_HIDE)

		;Set icon on GUI
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")

		;Set ID Num on GUI as Installed ID
		GUICtrlSetData($lbNumID, $Inst_ID)

		Return

	ElseIf $connStatus And $setupStatus = 1 Then ;==> If Connection OK and Station

		;Gera um novo ID
		generateID()

		;Stop the service
		RunWait(@ComSpec & " /c " & 'net stop ' & $servicename, "", @SW_HIDE)

		;Write the current ID to the service config file
		IniWrite($workingpath & "\ultravnc.ini", "admin", "service_commandline", "-sc_exit -sc_prompt -multi -autoreconnect ID:" & $numId & " -connect " & $repeaterIp[$repeaterIndex] & ":" & $repeaterPort[$repeaterIndex])

		;Start the service
		RunWait(@ComSpec & " /c " & 'net start ' & $servicename, "", @SW_HIDE)

		GUICtrlSetData($lbNumID, $numId)
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")

	ElseIf $connStatus Then ;==> If Connection OK and not installed

		;Generates new ID
		generateID()

		; Start the VNC server and make a reverse connection to the repeater.
		ShellExecute($workingpath & "\IntermixVNC.exe", "-sc_exit -sc_prompt -multi -autoreconnect ID:" & $numId & " -connect " & $repeaterIp[$repeaterIndex] & ":" & $repeaterPort[$repeaterIndex] & " -run")

		; Give some time to the connection
		Sleep(2000)

		GUICtrlSetData($lbNumID, $numId)

		Sleep(500)

		_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")



	Else ;==> If Connection Error

		GUICtrlSetData($lbNumID, "------")
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSERROR")

	EndIf



EndFunc
;============> End vncConnection() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... setup($type)
DESCRIPTION:....... Instala o Intermix no
SYNTAX:............ vncConnection($connOp = False)
PARAMETERS:........ [Optional] $connOP = Define if it's a retry or reconnect command from GUI, default is False

#ce ====================================================================================================
Func setup($type = "/station")

	;Hide GUI
	GUISetState(@SW_HIDE)

	;Control flags to guide the installation procedure
	Local $quiet = False
	Local $serverSetup = False
	Local $IdInvalid = True
	Local $RepInvalid = True
	Local $update = False
	Local $Inst_type_setup = "Workstation"
	Local $repIndex = 0

	;Set the installation Directory
	Local $Inst_dir = @ProgramFilesDir & "\IntermixSupport\" & $str_company_name & "\"

	;Check if the Script is running with admin privileges and set flags for cmdline parameters
	If IsAdmin() Then ; If is admin, set the parameter to variables
		If $type == "/server" Then
			$serverSetup = True
			$Inst_type_setup = "Server"
		ElseIf $type == "/quiet" Then
			$quiet = True
		EndIf
	Else ;If not, run it as admin
		_deleteself($workingpath, 5)
		ShellExecute(@ScriptFullPath, "/setup " & $type, @ScriptDir, "runas")
		Exit
	EndIf

	; Request and validate the ID
	If $serverSetup Then
		While $IdInvalid
;~ 			WinSetOnTop($str_program_title, "", 0)
			$numId = InputBox($str_msgbox_serviceinstallation, $str_serviceenteranidnumber, $numId,"",200,125)
			If $numId < 200000 And $numId > 100000 Then
				$IdInvalid = False
			Else
				If MsgBox(1, $str_config_title, $str_serviceinvalidid) == 2 Then
					_deleteself($workingpath, 5)
					Exit ; Chamar função para fechar aplicação ou simplesmente interromper e returnar valor
				EndIf
			EndIf
		WEnd
	EndIf

	; If server, request Repeater to be used
	If $serverSetup Then
		While $RepInvalid
			$repIndex = InputBox($askRepIndexTitle,$askRepIndexMsg,"","",200,150)
			If $repIndex >= 0 And $repIndex < 4 Then
				$repeaterIndex = $repIndex
				$RepInvalid = False
;~ 				$repIndex = testConnection(True,"0")
			ElseIf @error = 1 Then
				_deleteself($workingpath, 5)
				Exit
			EndIf
		WEnd
	EndIf

	; Disable Main GUI
	_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $mainGui)

	;If a previous version is already installed
	If $version > $Inst_version And $setupStatus > 0 Then

		; Show message about the update
		SplashTextOn($str_program_title, $str_inst_update, 500, 50, -1, -1, 4, "Arial", 11)

		;Call Remove Function for update
		$update = remove("/update")

		;Verify the update control flag
		If $update Then
			Sleep(3000)
		Else
			MsgBox(0, $str_program_title, $str_update_fail)
			Exit
		EndIf

		;disable de Splash Text
		SplashOff()

	Else
		$pid = Run($workingpath & "\IntermixVNC.exe -kill")
		ProcessWaitClose($pid, 15)

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

FUNCTION:.......... closeSupport()
DESCRIPTION:....... FStop services, process and exit aplication
SYNTAX:............ No parameters

#ce ====================================================================================================
Func closeSupport()
;~ 	WinSetOnTop($str_program_title, "", 0)
	If $setupStatus = 2 Then

		Exit

	ElseIf $setupStatus = 1 Then

		; Disable Main GUI
		_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $mainGui)

		; Hide GUI
		GUISetState(@SW_HIDE)

		;Show message that the program is closing
		SplashTextOn($str_program_title, $str_end_app, 500, 50, -1, -1, 4, "Arial", 11)

		;Stop the VNC service
		RunWait(@ComSpec & " /c " & 'net stop ' & $servicename, "", @SW_HIDE)

		Exit

	Else
		If MsgBox(4, $str_program_title, $str_endsupportsession) = 6 Then
			; Disable Main GUI
			_Metro_GUIDelete($GUI_HOVER_REG_MAIN, $mainGui)
			SplashTextOn($str_program_title, $str_end_app, 500, 50, -1, -1, 4, "Arial", 11)
			$pid = Run($workingpath & "\IntermixVNC.exe -kill")
			ProcessWaitClose($pid, 15)
			_deleteself($workingpath, 5)
			Exit
		EndIf

	EndIf
EndFunc
;============> closeSupport() ==============================================================

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
	Local $sAppID = $path & "\IntermixClient.exe"
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
				& 'DEL /F /Q "' & $path & '\IntermixClient.exe"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\SecureVNCPlugin.dsm"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\ultravnc.ini"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\intermix.ini"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\unblock.js"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\IntermixVNC.exe"' & @CRLF _
				& 'DEL /F /Q "' & $path & '\First_Server_ClientAuth.pubkey"' & @CRLF _
				& 'RD /S /Q "' & $path & '"' & @CRLF _
				& 'IF EXIST "' & $path & '" GOTO DELETE' & @CRLF _
				& 'GOTO END' & @CRLF _
				& @CRLF _
				& ':END' & @CRLF _
				& 'DEL "' & @TempDir & '\scratch.bat"'
	FileWrite(@TempDir & "\scratch.bat", $scmdfile)
	Return Run(@TempDir & "\scratch.bat", @TempDir, @SW_HIDE)
EndFunc   ;==>_deleteself
;============> _deleteself() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... startProgressBar($operation,$value)
DESCRIPTION:....... Draws and handle the Startup progress bar
SYNTAX:............ startProgressBar($operation = 0[,$value = 0[)
PARAMETERS:........ [Optional] $operation = Define what to do, default is 0, draw and start the progressbar
					[Optional] $value = Define how much percentage to advance in the progressbar, default is 0
#ce ====================================================================================================
Func startProgressBar($operation = 0,$value = 0)

	; Operation 1 - Update ProgressBar
	If($operation = 1) Then
	  $barProgress = $barProgress + $value
	  _Metro_SetProgress($ProgressStartUp, $barProgress)
	  Return
	EndIf

	; Operation 2 - Finish startup screen
	If($operation = 2) Then
		Sleep(200)
		_Metro_GUIDelete($GUI_HOVER_REG_START, $startUpGui)
		Return
	EndIf

	$barProgress = 0

	$startUpGui = _Metro_CreateGUI("INICIANDO...", 500, 95, -1, -1)
	$GUI_HOVER_REG_START = $startUpGui[1]
	$startUpGui = $startUpGui[0]

	$lbStarting = GUICtrlCreateLabel($txtStart, 75, 24, 105, 20)
	GUICtrlSetFont(-1, 12, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$iconStartUp = GUICtrlCreatePic("", 15, 24, 46, 46)
	_Resource_SetToCtrlID($iconStartUp, "IMG_STARTICON")

	$ProgressStartUp = _Metro_CreateProgress(75, 50, 395, 20)

	GUISetState(@SW_SHOW,$startUpGui)

EndFunc
;============> End startProgressBar() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... mainGUI()
DESCRIPTION:....... Draws the main GUI
SYNTAX:............ No parameters

#ce ====================================================================================================
Func mainGUI()

	$mainGui = _Metro_CreateGUI($str_program_title, 500, 205, -1, -1, 1, 1)
	$GUI_HOVER_REG_MAIN = $mainGui[1]

	$GUI_CLOSE_BUTTON_MAIN = $mainGui[2]
	$GUI_MINIMIZE_BUTTON_MAIN = $mainGui[5]

	$mainGui = $mainGui[0]

	$logoIntermixMain = GUICtrlCreatePic("", 15, 24, 217, 48)
	_Resource_SetToCtrlID($logoIntermixMain, "IMG_LOGOINTERMIX")

	$barMain = GUICtrlCreatePic("", 15, 105, 470, 50)
	_Resource_SetToCtrlID($barMain, "IMG_MAINBAR")

	$lbTxtID = GUICtrlCreateLabel($txtID, 28, 107, 45, 45)
	GUICtrlSetFont(-1, 30, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbNumID = GUICtrlCreateLabel($txtIdNum, 97, 107, 135, 45)
	GUICtrlSetFont(-1, 28, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$statusMain = GUICtrlCreatePic("", 247, 105, 57, 50)
	If $connStatus Then ;==> If Connection OK
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSOK")
	Else ;==> If Connection Error
		_Resource_SetToCtrlID($statusMain, "IMG_STATUSERROR")
	EndIf

	If $setupStatus = 2 and $connStatus Then
		GUICtrlSetData($lbNumID, $Inst_ID)
	EndIf

	$configMain = GUICtrlCreatePic("", 428, 105, 57, 50)
	_Resource_SetToCtrlID($configMain, "IMG_MAINCONFIGICON")

	$lbDisclaimer = GUICtrlCreateLabel($txtDisclaimerMain, 445, 185, 100, 15)
	GUICtrlSetFont(-1, 8, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUISetState(@SW_SHOW, $mainGui)

EndFunc
;============> End mainGUI() ==============================================================



#cs FUNCTION ===========================================================================================

FUNCTION:.......... configGUI()
DESCRIPTION:....... Draws the configuration GUI
SYNTAX:............ No parameters

#ce ====================================================================================================
Func configGUI()

	$configGuiExist = True
	$configGui = _Metro_CreateGUI($str_config_title, 500, 418, -1, -1, 1, 1)
	$GUI_HOVER_REG_CONFIG = $configGui[1]

	$GUI_CLOSE_BUTTON_CONFIG = $configGui[2]
	$GUI_MINIMIZE_BUTTON_CONFIG = $configGui[5]

	$configGui = $configGui[0]

	$logoCompanyConfig = GUICtrlCreatePic("", 15, 29, 260, 58)
	_Resource_SetToCtrlID($logoCompanyConfig, "IMG_LOGOCOMPANY")

	$lbSupportConfig = GUICtrlCreateLabel($txtSupport, 330, 38, 165, 35)
	GUICtrlSetFont(-1, 22, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xF4511E)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	;===========================================================================

	$lbStatusConfig = GUICtrlCreateLabel($txtStatus, 15, 100, 105, 20)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$barConfig1 = GUICtrlCreatePic("", 15, 122, 478, 50)
	_Resource_SetToCtrlID($barConfig1, "IMG_MAINCONFIGBAR1")

	$lbStatusRepeater = GUICtrlCreateLabel($txtRepeater, 64, 136, 135, 35)
	GUICtrlSetFont(-1, 18, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbStatusLatency = GUICtrlCreateLabel($numLatency & "ms", 422, 136, 115, 35)
	GUICtrlSetFont(-1, 16, 400, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	;===========================================================================

	$lbContactConfig = GUICtrlCreateLabel($txtContact, 15, 185, 105, 20)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0xBEBEBE)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$barConfig2 = GUICtrlCreatePic("", 15, 207, 478, 75)
	_Resource_SetToCtrlID($barConfig2, "IMG_MAINCONFIGBAR2")

	$lbContactTelA = GUICtrlCreateLabel($txtTelA, 30, 219, 150, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbContactTelB = GUICtrlCreateLabel($txtTelB, 30, 249, 150, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbContactEmail = GUICtrlCreateLabel($txtEmail, 230, 219, 250, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	$lbContactSite = GUICtrlCreateLabel($txtSite, 230, 249, 250, 25)
	GUICtrlSetFont(-1, 14, 700, 0, "Arial", 5)
	GUICtrlSetColor(-1, 0x282828)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUISetState(@SW_SHOW,$configGui)
EndFunc
;============> End configGUI() ==============================================================
>>>>>>> repeater_0_1_1
