#AutoIt3Wrapper_Icon=img\icon.ico
#AutoIt3Wrapper_Res_Fileversion=0.0.9.0
#AutoIt3Wrapper_Res_LegalCopyright=GPL
#AutoIt3Wrapper_Res_Language=1046
#AutoIt3Wrapper_Outfile=..\..\COMPILADO\VIEWER\IntermixViewer.Exe

#NoTrayIcon
#include "..\Aut2Exe\Include\ButtonConstants.au3"
#include "..\Aut2Exe\Include\ComboConstants.au3"
#include "..\Aut2Exe\Include\GUIConstantsEx.au3"
#include "..\Aut2Exe\Include\WindowsConstants.au3"
#include "..\Aut2Exe\Include\GuiComboBox.au3"
#include "..\Aut2Exe\Include\EditConstants.au3"
#include "..\Aut2Exe\Include\GuiComboBoxEx.au3"

; Exit if the script hasn't been compiled
If Not @Compiled Then
	MsgBox( 0, "ERROR", 'Script must be compiled before running!', 5 )
	Exit
EndIf

; Global vars.
Global $GUI_ENABLE_DEFBUTTON = 576
$IDNumber = ""
$ConnectionEstablished = False


; Read settings file.
$RepeaterAddress = 		IniRead( @ScriptDir & "\Bin\viewer.ini", "Repeater", "Address", "" )
$RepeaterAddressLAN = 	IniRead( @ScriptDir & "\Bin\viewer.ini", "Repeater", "AddressLAN", "" )
$RepeaterViewerPort =	IniRead( @ScriptDir & "\Bin\viewer.ini", "Repeater", "ViewerPort", "" )
$IDList = 				IniRead( @ScriptDir & "\Bin\viewer.ini", "IntermixViewer", "List", "" )
$IDListMax = 			IniRead( @ScriptDir & "\Bin\viewer.ini", "IntermixViewer", "ListMax", "" )
$Quality = 				IniRead( @ScriptDir & "\Bin\viewer.ini", "IntermixViewer", "Quality", "" )
$LANMode = 				IniRead( @ScriptDir & "\Bin\viewer.ini", "IntermixViewer", "LANMode", "" )

; AutoScale connect string
$AutoScale =			IniRead( @ScriptDir & "\Bin\viewer.ini", "IntermixViewer", "AutoScale", "0" )
If $AutoScale = 1 Then
	$strAutoScale = " -autoscaling"
Else
	$strAutoScale = ""
EndIf

; Password conect string
$Password =				IniRead( @ScriptDir & "\Bin\viewer.ini", "ChunkViewer", "Password", "" )
If $Password <> "" Then
	$strPassword = " -password " & $Password
Else
	$strPassword = ""
Endif


; If we are in LAN mode use the LAN IP.
If $LANMode = 1 Then $RepeaterAddress = $RepeaterAddressLAN


; Create the GUI.
$Form1 = GUICreate( "Intermix Viewer", 300, 80, -1, -1 )
GUISetBkColor(0xFFFFFF)
$Button1 = GUICtrlCreateButton( "Connect", 185, 10, 100, 39 )
GUICtrlSetFont( -1, 12, 800, 0, "MS Sans Serif" )
GUICtrlSetState($Button1, $GUI_DISABLE)
$Combo1 = GUICtrlCreateCombo( "", 15, 11, 155, 25 )
GUICtrlSetFont( -1, 20, 800, 0, "MS Sans Serif" )
_GUICtrlComboBox_LimitText( $Combo1, 6 )	; Limit the number of characters to 6 for input.
$Line1 = GUICtrlCreateLabel( "", 0, 60, 300, 1 )
GUICtrlSetBkColor( -1, 0x000000 )
$Label1 = GUICtrlCreateLabel( "", 5, 65, 300, 15 )
GUICtrlSetFont( $Label1, 8, 400, 0, "MS Sans Serif" )


; Create right-click context menu for Combo1.
$ContextMenu1 = 		GUICtrlCreateContextMenu( $Combo1 )
$ContextMenuMode1 = 	GUICtrlCreateMenuItem( "Switch Mode", $ContextMenu1 )
$ContextMenuHistory1 = 	GUICtrlCreateMenuItem( "Clear History", $ContextMenu1 )
$ContextMenuBlank1 = 	GUICtrlCreateMenuItem( "", $ContextMenu1 )
$ContextMenuAbout1 = 	GUICtrlCreateMenuItem( "About", $ContextMenu1 )


; Fill Combo1 and show current repeater address.
GUICtrlSetData( $Combo1, $IDList )
GUISetState( @SW_SHOW, $Form1 )


; Check to see if the repeater exists.
TCPStartUp()

If $LANMode = 0 Then
	$TestAddress = $RepeaterAddress
	GUICtrlSetData( $Label1, "Connecting to: " & $RepeaterAddress & ":" & $RepeaterViewerPort )
Else
	$TestAddress = $RepeaterAddressLAN
	GUICtrlSetData( $Label1, "Connecting to: " & $RepeaterAddressLAN & ":" & $RepeaterViewerPort )
EndIf

$socket = TCPConnect(TCPNameToIP( $TestAddress ), $RepeaterViewerPort )
$socket = TCPConnect(TCPNameToIP($repeaterIp[$RepeaterIdx]), $repeaterPort[$RepeaterIdx])

If $socket = -1 Then
	GUICtrlSetData( $Label1, "Repeater " & $TestAddress & " connection failed!" )
Else
	GUICtrlSetData( $Label1, "Repeater " & $TestAddress & " connection established!" )
	$ConnectionEstablished = True
EndIf

TCPShutdown()


; Main loop.
While 1

	; Disable the Connect button if empty, alphabetic characters or incorrect ID format or if connection to the repeater failed.

	If $IDNumber <> GUICtrlRead( $Combo1 ) Then

		$IDNumber = GUICtrlRead( $Combo1 )

		If $IDNumber <> "" And StringIsDigit( $IDNumber ) = 1 And $IDNumber >= 100000 And $IDNumber <= 999999 And $ConnectionEstablished = True Then

			GUICtrlSetState( $Button1, $GUI_ENABLE_DEFBUTTON )

		Else

			GUICtrlSetState( $Button1, $GUI_DISABLE )

		EndIf

	EndIf



	$nMsg = GUIGetMsg()

	Switch $nMsg

		Case $GUI_EVENT_CLOSE

			Exit

		; Switch between LAN and WAN Mode.
		Case $ContextMenuMode1

			If $LANMode = 0 Then

				IniWrite( @ScriptDir & "\Bin\viewer.ini", "IntermixViewer", "LANMode", "1" )

			Else

				IniWrite( @ScriptDir & "\Bin\viewer.ini", "IntermixViewer", "LANMode", "0" )

			EndIf

			Run( @ScriptFullPath )
			Exit

		; Clear history.
		Case $ContextMenuHistory1

			GUICtrlSetData( $Label1, "History Cleared." )
			GUICtrlSetData( $Combo1, "" )
			IniWrite( @ScriptDir & "\Bin\viewer.ini", "IntermixViewer", "List", "" )


		; About
		Case $ContextMenuAbout1

			GUICtrlSetData( $Label1, "Intermix Remote Support - by Luiz Fernando Cavalcanti" )


		; Connect
		Case $Button1

			; Mac InstantSupport values are 100000 to 200000, higher values are for Windows
			If $IDNumber < 99000 Then

				; Start Viewer without encryption for Mac
				If $LANMode = 0 Then
					ShellExecute( @ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddress & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & " -keepalive 1" )
				Else
					ShellExecute( @ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddressLAN & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & " -keepalive 1" )
				EndIf

			Else

				; Start Viewer with encryption for Windows
				If $LANMode = 0 Then
					ShellExecute( @ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddress & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & $strAutoScale  & " -keepalive 1 -dsmplugin SecureVNCPlugin.dsm" & $strPassword)
				Else
					ShellExecute( @ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddressLAN & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & $strAutoScale & " -keepalive 1 -dsmplugin SecureVNCPlugin.dsm" & $strPassword )
				EndIf

			EndIf


			; Don't save more than ListMax, keep in mind we assume a 6 digit number.
			If StringLen( $IDList) >= ( $IDListMax * 6 + ( $IDListMax - 1 ) ) Then

				; Maximum ID's in list, trim
				$IDList = $IDNumber & "|" & StringTrimRight( $IDList, 7 )

			Else

				; Maximum ID's not yet reached.
				If $IDList = "" Then

					$IDList = $IDNumber

				Else

					$IDList = $IDNumber & "|" & $IDList

				EndIf

			EndIf

			; Save IDList in chunkviewer.ini
			IniWrite( @ScriptDir & "\Bin\viewer.ini", "IntermixViewer", "List", $IDList )

			Exit


	EndSwitch

WEnd
