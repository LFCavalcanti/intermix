#RequireAdmin

#include "..\Aut2Exe\Include\ButtonConstants.au3"
#include "..\Aut2Exe\Include\EditConstants.au3"
#include "..\Aut2Exe\Include\GUIConstantsEx.au3"
#include "..\Aut2Exe\Include\WindowsConstants.au3"
#include "..\Aut2Exe\Include\Constants.au3"

; Exit if the script hasn't been compiled.
If Not @Compiled Then
	MsgBox(0, "ERROR", 'Script must be compiled before running!', 5)
	Exit
EndIf

; Exit if an VNC server is running.
If ProcessExists( "winvnc.exe" ) Then
	MsgBox(0, "ERROR", 'Compiling is not possible because a VNC server is running, please close the other VNC server and try again.', 5)
EndIf


; Create the GUI.
$Form1_1 = GUICreate("ChunkVNC Compiler", 434, 370, 192, 124)
GUISetBkColor(0xFFFFFF)
$Group1 = GUICtrlCreateGroup("Repeater Address", 16, 8, 401, 137)
GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x000000)
$InputWAN = GUICtrlCreateInput("arriviera.no-ip.org", 96, 48, 305, 28)
GUICtrlSetFont(-1, 13, 400, 0, "MS Sans Serif")
$InputLAN = GUICtrlCreateInput("10.100.100.14", 96, 96, 305, 28)
GUICtrlSetFont(-1, 13, 400, 0, "MS Sans Serif")
$Label1 = GUICtrlCreateLabel("WAN:", 32, 48, 49, 24)
GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
$Label2 = GUICtrlCreateLabel("LAN:", 32, 96, 43, 24)
GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Repeater Ports", 16, 160, 401, 89)
GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x000000)
$Label3 = GUICtrlCreateLabel("Viewer:", 32, 200, 63, 24)
GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
$Label4 = GUICtrlCreateLabel("Server:", 232, 200, 61, 24)
GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
$InputViewerPort = GUICtrlCreateInput("14001", 104, 200, 97, 28)
GUICtrlSetFont(-1, 13, 400, 0, "MS Sans Serif")
$InputServerPort = GUICtrlCreateInput("14000", 304, 200, 97, 28)
GUICtrlSetFont(-1, 13, 400, 0, "MS Sans Serif")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("InstantSupport Password", 16, 264, 305, 89)
GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x000000)
$InputPassword = GUICtrlCreateInput("Arrivier@", 32, 304, 273, 28)
GUICtrlSetFont(-1, 13, 400, 0, "MS Sans Serif")
GUICtrlCreateGroup("", -99, -99, 1, 1)
;GUICtrlSetLimit( $InputPassword, 8 )
$ButtonCompile = GUICtrlCreateButton("Compile!", 336, 272, 81, 81)
GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
GUISetState(@SW_SHOW)


; Main Loop.
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $ButtonCompile

			; Check the password.
			$PlainTextPassword = GUICtrlRead( $InputPassword )

			If $PlainTextPassword = "" or StringInStr( $PlainTextPassword, " " ) Then

				MsgBox( 0, "Information", "The password cannot be blank or contain whitespace." )

			ElseIf Stringlen( $PlainTextPassword ) < 9 Then

				MsgBox( 0, "Information", "The password cannot be less than 9 characters." )

			Else

				; Automate the SecureVNC plugin to generate a password hash and store it in ultravnc.ini

				; Blank VNC passwords in ultravnc.ini so that the property page displays.
				IniWrite( @ScriptDir & "\SOURCE\client\files\ultravnc.ini", "ultravnc", "passwd", "" )
				IniWrite( @ScriptDir & "\SOURCE\client\files\ultravnc.ini", "ultravnc", "passwd2", "" )
				IniWrite( @ScriptDir & "\SOURCE\client\files\ultravnc.ini", "admin", "DSMPluginConfig", "" )


				; Configure SecureVNC with our password.
				Run( @ScriptDir & "\SOURCE\client\files\winvnc.exe" )

				WinWait( " UltraVNC Server Property Page" )
				ControlClick(" UltraVNC Server Property Page", "Config.", "[CLASS:Button; INSTANCE:44]", "primary" )
				WinWait( "SecureVNCPlugin Configuration" )
				ControlSend( "SecureVNCPlugin Configuration", "", "[CLASS:Edit; INSTANCE:1]", $PlainTextPassword )
				ControlSend( "SecureVNCPlugin Configuration", "", "[CLASS:Edit; INSTANCE:2]", $PlainTextPassword )
				ControlClick("SecureVNCPlugin Configuration", "Close", "[CLASS:Button; INSTANCE:19]", "primary" )
				ControlClick(" UltraVNC Server Property Page", "&Apply", "[CLASS:Button; INSTANCE:50]", "primary" )


				; Kill the UltraVNC process.
				Sleep( 500 ) ; Give old computers some time to write ultravnc.ini
				ProcessClose( "winvnc.exe" )


				; Put UltraVNC passwords back in ultravnc.ini (these arn't used it simply stops the server property page from popping up).
				IniWrite( @ScriptDir & "\SOURCE\client\files\ultravnc.ini", "ultravnc", "passwd", "ac476d03f66b9e0300" )
				IniWrite( @ScriptDir & "\SOURCE\client\files\ultravnc.ini", "ultravnc", "passwd2", "8BF749ADC043135FED" )


				; Setup source files with the repeaters address.
				$RepeaterAddressWAN = GUICtrlRead( $InputWAN )
				$RepeaterAddressLAN = GUICtrlRead( $InputLAN )
				$ViewerPort = GUICtrlRead( $InputViewerPort )
				$ServerPort = GUICtrlRead( $InputServerPort )

				IniWrite( @ScriptDir & "\SOURCE\viewer\files\viewer.ini", "Repeater", "Address", $RepeaterAddressWAN )
				IniWrite( @ScriptDir & "\SOURCE\viewer\files\viewer.ini", "Repeater", "AddressLAN", $RepeaterAddressLAN )
				IniWrite( @ScriptDir & "\SOURCE\viewer\files\viewer.ini", "Repeater", "ViewerPort", $ViewerPort )

				IniWrite( @ScriptDir & "\SOURCE\client\files\intermix.ini", "Repeater", "Address", $RepeaterAddressWAN )
				IniWrite( @ScriptDir & "\SOURCE\client\files\intermix.ini", "Repeater", "AddressLAN", $RepeaterAddressLAN )
				IniWrite( @ScriptDir & "\SOURCE\client\files\intermix.ini", "Repeater", "ServerPort", $ServerPort )


				; Clean temp output directory.
				DirRemove( @TempDir & "\Intermix_Compiled", 1 )


				; Compile InstantSupport.exe
				DirCreate( @TempDir & "\Intermix_Compiled" )
				ShellExecuteWait( "SOURCE\Aut2Exe\Aut2Exe.exe", '/in SOURCE\client\IntermixClient.au3 /out "' & @TempDir & '\Intermix_Compiled\IntermixClient.exe" /icon SOURCE\client\img\icon.ico', @ScriptDir )


				; Compile ChunkViewer.exe
				DirCreate( @TempDir & "\Intermix_Compiled\Viewer" )
				ShellExecuteWait( "SOURCE\Aut2Exe\Aut2Exe.exe", '/in SOURCE\viewer\IntermixViewer.au3 /out "' & @TempDir & '\Intermix_Compiled\Viewer\IntermixViewer.exe" /icon SOURCE\viewer\img\icon.ico', @ScriptDir )


				; Check if SecureVNC was configured properly
				$DSMPluginConfig = IniRead( @ScriptDir & "\SOURCE\client\files\ultravnc.ini", "admin", "DSMPluginConfig", $RepeaterAddressWAN )
				If $DSMPluginConfig = "" Then
					MsgBox( 0, "Information", "Compile Failed: SecureVNC plugin failed to configure. Please compile again." )
					Exit
				Else
					If FileExists( @TempDir & "\Intermix_Compiled\IntermixClient.exe" ) Then
;~ 						FileMove( @ScriptDir & "\Intermix.exe", @TempDir & "\Intermix_Compiled", 1 )
						DirCopy( @ScriptDir & "\SOURCE\viewer\files", @TempDir & "\Intermix_Compiled\Viewer\Bin", 1 )
						Run( "explorer.exe " & @TempDir & "\Intermix_Compiled" )
					Else
						MsgBox( 0, "Information", "Compile Failed: InstermixClient.exe failed to compile. Please compile again." )
					EndIf
				EndIf

				Sleep( 2000 )

				MsgBox( 0, "Information", "If completed successfully you will find IntermixClient.exe and a Viewer directory. If you do not have these files try compiling again." )

				Exit


			EndIf

	EndSwitch

WEnd

Func _WinWaitActivate($title,$text,$timeout=0)
	WinWait($title,$text,$timeout)
	If Not WinActive($title,$text) Then WinActivate($title,$text)
	WinWaitActive($title,$text,$timeout)
EndFunc

