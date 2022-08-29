; #UDF# =======================================================================================================================
; Name ..........: MetroGUI UDF
; Description ...: Create metro style borderless GUIs, buttons, checkboxes, toggles, radios MsgBoxes and progressbars.
; Version .......: v3.5
; Author ........: BB_19
; ===============================================================================================================================

#include-once
#include <GDIPlus.au3>
#include "MetroThemes.au3"
#include ".\BorderlessWinUDF.au3"
#include ".\StringSize.au3"
#include ".\_GUIDisable.au3"

_GDIPlus_Startup()
Global $Font_DPI_Ratio = _SetFont_GetDPI()
$Font_DPI_Ratio = $Font_DPI_Ratio[2]

#Region Metro Functions for creating GUIs:
;========================================MAIN GUI==================================================
;_Metro_CreateGUI - Creates a borderless Metro-Style GUI
;_SetTheme - Sets the GUI color scheme from the included MetroThemes.au3
;_Metro_GUIDelete - Destroys all created metro buttons,checkboxes,radios etc., deletes the GUI and reduces memory usage.
;_Metro_HoverCheck_Loop - Required for the hover effects. This has to be added to the main while loop of the GUI.

;==========================================Buttons=================================================
;_Metro_CreateButton - Creates metro style buttons. Hovering creates a frame around the buttons.
;_Metro_CreateButtonEx - Creates Windows 10 style buttons with a frame around. Hovering changes the button color to a lighter color.

;==========================================Toggles=================================================
;_Metro_CreateToggle - Creates a Windows 10 style toggle with a text on the right side.
;_Metro_ToggleIsChecked - Checks if a toggle is checked or not. Returns True or False.
;_Metro_ToggleCheck - Checks/Enables a toggle.
;_Metro_ToggleUnCheck - Unchecks/Disables a toggle.

;===========================================Radios=================================================
;_Metro_CreateRadio - Creates a metro style radio.
;_Metro_RadioCheck - Checks the selected radio and unchecks all other radios in the selected group.
;_Metro_RadioIsChecked - Checks if the radio in a specific group is selected.

;==========================================Checkboxes==============================================
;_Metro_CreateCheckbox - Creates a metro style checkbox.
;_Metro_CheckboxIsChecked - Checks if a checkbox is checked. Returns True or False.
;_Metro_CheckboxCheck - Checks a checkbox.
;_Metro_CheckboxUncheck - Unchecks a checkbox.

;=============================================MsgBox===============================================
;_Metro_MsgBox - Creates a MsgBox with a OK button and displays the text. _GUIDisable($GUI, 0, 30) should be used before, so the MsgBox is better visible and afterwards _GUIDisable($GUI).

;=============================================Progress=============================================
;_Metro_CreateProgress - Creates a simple progressbar.
;_Metro_SetProgress - Sets the progress in % of a progressbar.
#EndRegion Metro Functions for creating GUIs:


#Region MetroGUI===========================================================================================
; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CreateGUI
; Description ...: Creates a borderless Metro-Style GUI
; Syntax ........: _Metro_CreateGUI($Title, $Width, $Height[, $Left = -1[, $Top = -1[, $TypeOption = 0[,
;                  $ControlButtons = True[, $ParentGUI = ""]]]]])
; Parameters ....: $Title               - Title of the window.
;                  $Width               - Width
;                  $Height              - Height
;                  $Left                - [optional] Left position. Default is -1.
;                  $Top                 - [optional] Top position. Default is -1.
;
;                  $TypeOption        - [optional] Borderless window that allows drag, resize and also keeps the AeroSnap functions working. Default is 0.
;													0 - Popup style, no resize, move or maximize
;													1 - Move but no resize or maximize, but with AeroSnap
;													2 - All features with AeroSnap
;				   [NOTE]: Can only be called for one GUI. If you create a second GUI with this option, you have to call _GUI_DragAndResizeUpdate($GUI) for your previous GUI after closing the second one.
;
;                  $ControlButtons      - [optional] Adds Close,Maximize/Restore and Minimize buttons to the GUI. Default is 0.
; 													0 - No Control Buttons
; 													1 - Minimize and Close Buttons
; 													2 - All control Buttons
;					[NOTE]: Remember to only implement the apropriate array references for the Hover Loop and actions.
;
;                  $ParentGUI           - [optional] Parent GUI/Window, This makes sure, there are not multiple windows of your program in the taskbar.
; Return values .: Array[6]
;				   [0] = Handle to the created GUI.
;				   [1] = Array for GUI_HOVER_REG. This is very important. Without this you won't be having working hover effects. Name the variable wisely. For example $GUI_HOVER_REG.
;				   [2] = Handle for the $GUI_CLOSE_BUTTON (Only if created with $ControlButtons = True)
;				   [3] = Handle for the $GUI_MAXIMIZE_BUTTON (Only if created with $ControlButtons = True)
;				   [4] = Handle for the $GUI_RESTORE_BUTTON (Only if created with $ControlButtons = True)
;				   [5] = Handle for the $GUI_MINIMIZE_BUTTON (Only if created with $ControlButtons = True)
; Example .......: $Form1 = _Metro_CreateGUI("Example", 500, 300, -1, -1, True, True)
; ===============================================================================================================================
Func _Metro_CreateGUI($Title, $Width, $Height, $Left = -1, $Top = -1, $TypeOption = 0, $ControlButtons = 0, $ParentGUI = "")
	Local $GUI_Return[6]
#Region ## UPDATED RESIZE ##
	If $TypeOption = 0 Then
		$GUI_Return[0] = GUICreate($Title, $Width, $Height, $Left, $Top, $WS_POPUP, -1, $ParentGUI)
	ElseIf $TypeOption = 1 Then
		$GUI_Return[0] = GUICreate($Title, $Width, $Height, $Left, $Top, BitOR($WS_POPUP, $WS_MINIMIZEBOX), -1, $ParentGUI)
		_GUI_EnableDragAndResize($GUI_Return[0], $Width, $Height, $Width, $Height)
	Else
		$GUI_Return[0] = GUICreate($Title, $Width, $Height, $Left, $Top, BitOR($WS_SIZEBOX, $WS_MINIMIZEBOX, $WS_MAXIMIZEBOX), -1, $ParentGUI)
		_GUI_EnableDragAndResize($GUI_Return[0], $Width, $Height, $Width, $Height, True)
	EndIf
#EndRegion
	Local $GUI_HOVER_REG = _Metro_InitHover()
	$GUI_Return[1] = $GUI_HOVER_REG

	If $ParentGUI = "" Then
		Local $Center_GUI = _GetDesktopWorkArea($GUI_Return[0])
		If ($Left = -1) And ($Top = -1) Then
			WinMove($GUI_Return[0], "", ($Center_GUI[2] - $Width) / 2, ($Center_GUI[3] - $Height) / 2, $Width, $Height)
		EndIf
	Else
		If ($Left = -1) And ($Top = -1) Then
			$GUI_NewPos = _WinPos($ParentGUI, $Width, $Height)
			WinMove($GUI_Return[0], "", $GUI_NewPos[0], $GUI_NewPos[1], $Width, $Height)
		EndIf
	EndIf

	GUISetBkColor($GUIThemeColor)
	_CreateBorder($Width, $Height, $GUIBorderColor, 0, 1)
#Region ## UPDATE CONTROL BUTTONS CALL ##
; ====================================================================================================================================
; 				Added a function to separate the creation of the buttons, more organized and consume less resources
; ====================================================================================================================================
	If $ControlButtons = 1 Then
		$Control_Buttons = _Metro_CreateControlButtonsCloseMini($GUI_Return[1], $GUI_Return[0], $GUIThemeColor, $FontThemeColor, $ControlThickStyle, False)
		$GUI_Return[2] = $Control_Buttons[0];Close
		$GUI_Return[5] = $Control_Buttons[3];Minimize
	ElseIf $ControlButtons = 2 Then
		$Control_Buttons = _Metro_CreateControlButtonsAll($GUI_Return[1], $GUI_Return[0], $GUIThemeColor, $FontThemeColor, $ControlThickStyle, False)
		$GUI_Return[2] = $Control_Buttons[0];Close
		$GUI_Return[3] = $Control_Buttons[1];Maximize
		$GUI_Return[4] = $Control_Buttons[2];Restore
		$GUI_Return[5] = $Control_Buttons[3];Minimize
	EndIf

#EndRegion
	Return ($GUI_Return)
EndFunc   ;==>_Metro_CreateGUI


; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CreateControlButtonsAll
; Description ...: Internal use only. Creates the GUI control buttons for Close,Maximize/Restore and Minimize.
; ===============================================================================================================================
Func _Metro_CreateControlButtonsAll(ByRef $GUI_HOVER_REG, $hForm, $GUI_BG_Color = $GUIThemeColor, $GUI_Font_Color = "0xFFFFFF", $ThickStyle = $ControlThickStyle, $CloseButtonOnStyle = False)

	;Set Colors, create brushes and pens
	$GUI_Font_Color = StringReplace($GUI_Font_Color, "0x", "0xFF")
	$GUI_BG_Color = StringReplace($GUI_BG_Color, "0x", "0xFF")
	If StringInStr($GUI_Theme_Name, "Light") Then
		$Hover_BK_Color = StringReplace(_AlterBrightness($GUI_BG_Color, -20), "0x", "0xFF")
	Else
		$Hover_BK_Color = StringReplace(_AlterBrightness($GUI_BG_Color, +20), "0x", "0xFF")
	EndIf
	If $ThickStyle Then
		Local $hPen = _GDIPlus_PenCreate($GUI_Font_Color, 2)
		Local $hPen2 = _GDIPlus_PenCreate($GUI_Font_Color, 2)
		Local $hPen3 = _GDIPlus_PenCreate("0xFFFFFFFF", 2)
	Else
		Local $hPen = _GDIPlus_PenCreate($GUI_Font_Color, 1)
		Local $hPen2 = _GDIPlus_PenCreate($GUI_Font_Color, 1)
		Local $hPen3 = _GDIPlus_PenCreate("0xFFFFFFFF", 1)
	EndIf
	$hBrush = _GDIPlus_BrushCreateSolid($GUI_BG_Color)
	$hBrush2 = _GDIPlus_BrushCreateSolid($Hover_BK_Color)

	;Create Button Arrays
	Local $Control_Buttons[15]
	Local $Button_Close_Array[15]
	Local $Button_Minimize_Array[15]
	Local $Button_Maximize_Array[15]
	Local $Button_Restore_Array[15]

	$Win_POS = WinGetPos($hForm)
	$Button_Close_Array[0] = GUICtrlCreatePic("", $Win_POS[2] - 50, 5, 45, 29)
	$Button_Close_Array[1] = False; Hover state
	$Button_Close_Array[3] = "0" ; Type

	$Button_Maximize_Array[0] = GUICtrlCreatePic("", $Win_POS[2] - 96, 5, 45, 29)
	$Button_Maximize_Array[1] = False
	$Button_Maximize_Array[3] = "3"

	$Button_Restore_Array[0] = GUICtrlCreatePic("", $Win_POS[2] - 96, 5, 45, 29)
	$Button_Restore_Array[1] = False
	$Button_Restore_Array[3] = "4"

	$Button_Minimize_Array[0] = GUICtrlCreatePic("", $Win_POS[2] - 142, 5, 45, 29)
	$Button_Minimize_Array[1] = False
	$Button_Minimize_Array[3] = "0"

	;Create Graphics Arrays, 0=default button, 1=button with hover effect
	Local $Button_Close_Bitmaps[2] = [_GDIPlus_BitmapCreateFromScan0(45, 29), _GDIPlus_BitmapCreateFromScan0(45, 29)]
	Local $Button_Close_GraphicsContext[2] = [_GDIPlus_ImageGetGraphicsContext($Button_Close_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Button_Close_Bitmaps[1])]
	Local $Button_Maximize_Bitmaps[2] = [_GDIPlus_BitmapCreateFromScan0(45, 29), _GDIPlus_BitmapCreateFromScan0(45, 29)]
	Local $Button_Maximize_GraphicsContext[2] = [_GDIPlus_ImageGetGraphicsContext($Button_Maximize_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Button_Maximize_Bitmaps[1])]
	Local $Button_Restore_Bitmaps[2] = [_GDIPlus_BitmapCreateFromScan0(45, 29), _GDIPlus_BitmapCreateFromScan0(45, 29)]
	Local $Button_Restore_GraphicsContext[2] = [_GDIPlus_ImageGetGraphicsContext($Button_Restore_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Button_Restore_Bitmaps[1])]
	Local $Button_Minimize_Bitmaps[2] = [_GDIPlus_BitmapCreateFromScan0(45, 29), _GDIPlus_BitmapCreateFromScan0(45, 29)]
	Local $Button_Minimize_GraphicsContext[2] = [_GDIPlus_ImageGetGraphicsContext($Button_Minimize_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Button_Minimize_Bitmaps[1])]

	;Set button BG colors
	If $CloseButtonOnStyle Then
		_GDIPlus_GraphicsClear($Button_Close_GraphicsContext[0], "0xFFB52231");
	Else
		_GDIPlus_GraphicsClear($Button_Close_GraphicsContext[0], $GUI_BG_Color)
	EndIf
	_GDIPlus_GraphicsClear($Button_Close_GraphicsContext[1], "0xFFE81123")
	_GDIPlus_GraphicsClear($Button_Maximize_GraphicsContext[0], $GUI_BG_Color)
	_GDIPlus_GraphicsClear($Button_Maximize_GraphicsContext[1], $Hover_BK_Color)
	_GDIPlus_GraphicsClear($Button_Restore_GraphicsContext[0], $GUI_BG_Color)
	_GDIPlus_GraphicsClear($Button_Restore_GraphicsContext[1], $Hover_BK_Color)
	_GDIPlus_GraphicsClear($Button_Minimize_GraphicsContext[0], $GUI_BG_Color)
	_GDIPlus_GraphicsClear($Button_Minimize_GraphicsContext[1], $Hover_BK_Color)

	;Set Smoothing/Antialiasing for close button
	_GDIPlus_GraphicsSetSmoothingMode($Button_Close_GraphicsContext[0], 4)
	_GDIPlus_GraphicsSetSmoothingMode($Button_Close_GraphicsContext[1], 4)

	;Create Close Button
	If $CloseButtonOnStyle Then
		_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[0], 17, 9, 27, 19, $hPen3)
		_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[0], 27, 9, 17, 19, $hPen3)
	Else
		_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[0], 17, 9, 27, 19, $hPen)
		_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[0], 27, 9, 17, 19, $hPen)
	EndIf
	_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[1], 17, 9, 27, 19, $hPen3)
	_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[1], 27, 9, 17, 19, $hPen3)

	;Create Maximize Button
	If $ThickStyle Then
		_GDIPlus_GraphicsDrawRect($Button_Maximize_GraphicsContext[0], 18, 10, 8, 8, $hPen)
		_GDIPlus_GraphicsDrawRect($Button_Maximize_GraphicsContext[1], 18, 10, 8, 8, $hPen2)
	Else
		_GDIPlus_GraphicsDrawRect($Button_Maximize_GraphicsContext[0], 17, 9, 9, 9, $hPen)
		_GDIPlus_GraphicsDrawRect($Button_Maximize_GraphicsContext[1], 17, 9, 9, 9, $hPen2)
	EndIf

	;Create Restore Button
	If $ThickStyle Then
		_GDIPlus_GraphicsDrawRect($Button_Restore_GraphicsContext[0], 17, 12, 7, 7, $hPen)
		_GDIPlus_GraphicsDrawRect($Button_Restore_GraphicsContext[0], 20, 9, 7, 7, $hPen)
		_GDIPlus_GraphicsFillRect($Button_Restore_GraphicsContext[0], 18, 13, 5, 5, $hBrush)
		_GDIPlus_GraphicsDrawRect($Button_Restore_GraphicsContext[1], 17, 12, 7, 7, $hPen2)
		_GDIPlus_GraphicsDrawRect($Button_Restore_GraphicsContext[1], 20, 9, 7, 7, $hPen2)
		_GDIPlus_GraphicsFillRect($Button_Restore_GraphicsContext[1], 18, 13, 5, 5, $hBrush2)
	Else
		_GDIPlus_GraphicsDrawRect($Button_Restore_GraphicsContext[0], 17, 11, 7, 7, $hPen)
		_GDIPlus_GraphicsDrawRect($Button_Restore_GraphicsContext[0], 19, 9, 7, 7, $hPen)
		_GDIPlus_GraphicsFillRect($Button_Restore_GraphicsContext[0], 18, 12, 6, 6, $hBrush)
		_GDIPlus_GraphicsDrawRect($Button_Restore_GraphicsContext[1], 17, 11, 7, 7, $hPen2)
		_GDIPlus_GraphicsDrawRect($Button_Restore_GraphicsContext[1], 19, 9, 7, 7, $hPen2)
		_GDIPlus_GraphicsFillRect($Button_Restore_GraphicsContext[1], 18, 12, 6, 6, $hBrush2)
	EndIf

	;Create Minimize Button
	If $ThickStyle Then
		_GDIPlus_GraphicsDrawLine($Button_Minimize_GraphicsContext[0], 18, 16, 28, 16, $hPen)
		_GDIPlus_GraphicsDrawLine($Button_Minimize_GraphicsContext[1], 18, 16, 28, 16, $hPen2)
	Else
		_GDIPlus_GraphicsDrawLine($Button_Minimize_GraphicsContext[0], 18, 14, 27, 14, $hPen)
		_GDIPlus_GraphicsDrawLine($Button_Minimize_GraphicsContext[1], 18, 14, 27, 14, $hPen2)
	EndIf

	;Release created objects
	_GDIPlus_GraphicsDispose($Button_Close_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Button_Close_GraphicsContext[1])
	_GDIPlus_GraphicsDispose($Button_Maximize_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Button_Maximize_GraphicsContext[1])
	_GDIPlus_GraphicsDispose($Button_Restore_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Button_Restore_GraphicsContext[1])
	_GDIPlus_GraphicsDispose($Button_Minimize_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Button_Minimize_GraphicsContext[1])
	_GDIPlus_PenDispose($hPen)
	_GDIPlus_PenDispose($hPen2)
	_GDIPlus_PenDispose($hPen3)
	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_BrushDispose($hBrush2)


	;Create bitmap handles
	$Button_Close_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Close_Bitmaps[0])
	$Button_Close_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Close_Bitmaps[1])
	$Button_Maximize_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Maximize_Bitmaps[0])
	$Button_Maximize_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Maximize_Bitmaps[1])
	$Button_Restore_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Restore_Bitmaps[0])
	$Button_Restore_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Restore_Bitmaps[1])
	$Button_Minimize_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Minimize_Bitmaps[0])
	$Button_Minimize_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Minimize_Bitmaps[1])

	;More cleanup
	_GDIPlus_BitmapDispose($Button_Close_Bitmaps[0])
	_GDIPlus_BitmapDispose($Button_Close_Bitmaps[1])
	_GDIPlus_BitmapDispose($Button_Maximize_Bitmaps[0])
	_GDIPlus_BitmapDispose($Button_Maximize_Bitmaps[1])
	_GDIPlus_BitmapDispose($Button_Restore_Bitmaps[0])
	_GDIPlus_BitmapDispose($Button_Restore_Bitmaps[1])
	_GDIPlus_BitmapDispose($Button_Minimize_Bitmaps[0])
	_GDIPlus_BitmapDispose($Button_Minimize_Bitmaps[1])

	;For GUI Resizing
	GUICtrlSetResizing($Button_Close_Array[0], 768 + 32 + 4)
	GUICtrlSetResizing($Button_Maximize_Array[0], 768 + 32 + 4)
	GUICtrlSetResizing($Button_Restore_Array[0], 768 + 32 + 4)
	GUICtrlSetResizing($Button_Minimize_Array[0], 768 + 32 + 4)

	;Set default button images visible
	_WinAPI_DeleteObject(GUICtrlSendMsg($Button_Close_Array[0], 0x0172, 0, $Button_Close_Array[5]))
	_WinAPI_DeleteObject(GUICtrlSendMsg($Button_Maximize_Array[0], 0x0172, 0, $Button_Maximize_Array[5]))
	_WinAPI_DeleteObject(GUICtrlSendMsg($Button_Restore_Array[0], 0x0172, 0, $Button_Restore_Array[5]))
	_WinAPI_DeleteObject(GUICtrlSendMsg($Button_Minimize_Array[0], 0x0172, 0, $Button_Minimize_Array[5]))

	$Control_Buttons[0] = $Button_Close_Array[0]
	$Control_Buttons[1] = $Button_Maximize_Array[0]
	$Control_Buttons[2] = $Button_Restore_Array[0]
	$Control_Buttons[3] = $Button_Minimize_Array[0]

	_Metro_AddHoverItem($GUI_HOVER_REG, $Button_Close_Array)
	_Metro_AddHoverItem($GUI_HOVER_REG, $Button_Maximize_Array)
	_Metro_AddHoverItem($GUI_HOVER_REG, $Button_Restore_Array)
	_Metro_AddHoverItem($GUI_HOVER_REG, $Button_Minimize_Array)
	Return $Control_Buttons
EndFunc   ;==>_Metro_CreateControlButtonsAll

; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CreateControlButtonsCloseMini
; Description ...: Internal use only. Creates the GUI control buttons for Close,Maximize/Restore and Minimize.
; ===============================================================================================================================
Func _Metro_CreateControlButtonsCloseMini(ByRef $GUI_HOVER_REG, $hForm, $GUI_BG_Color = $GUIThemeColor, $GUI_Font_Color = "0xFFFFFF", $ThickStyle = $ControlThickStyle, $CloseButtonOnStyle = False)

	;Set Colors, create brushes and pens
	$GUI_Font_Color = StringReplace($GUI_Font_Color, "0x", "0xFF")
	$GUI_BG_Color = StringReplace($GUI_BG_Color, "0x", "0xFF")
	If StringInStr($GUI_Theme_Name, "Light") Then
		$Hover_BK_Color = StringReplace(_AlterBrightness($GUI_BG_Color, -20), "0x", "0xFF")
	Else
		$Hover_BK_Color = StringReplace(_AlterBrightness($GUI_BG_Color, +20), "0x", "0xFF")
	EndIf
	If $ThickStyle Then
		Local $hPen = _GDIPlus_PenCreate($GUI_Font_Color, 2)
		Local $hPen2 = _GDIPlus_PenCreate($GUI_Font_Color, 2)
		Local $hPen3 = _GDIPlus_PenCreate("0xFFFFFFFF", 2)
	Else
		Local $hPen = _GDIPlus_PenCreate($GUI_Font_Color, 1)
		Local $hPen2 = _GDIPlus_PenCreate($GUI_Font_Color, 1)
		Local $hPen3 = _GDIPlus_PenCreate("0xFFFFFFFF", 1)
	EndIf
	$hBrush = _GDIPlus_BrushCreateSolid($GUI_BG_Color)
	$hBrush2 = _GDIPlus_BrushCreateSolid($Hover_BK_Color)

	;Create Button Arrays
	Local $Control_Buttons[15]
	Local $Button_Close_Array[15]
	Local $Button_Minimize_Array[15]

	$Win_POS = WinGetPos($hForm)
	$Button_Close_Array[0] = GUICtrlCreatePic("", $Win_POS[2] - 50, 5, 45, 29)
	$Button_Close_Array[1] = False; Hover state
	$Button_Close_Array[3] = "0" ; Type

;~ 	$Button_Minimize_Array[0] = GUICtrlCreatePic("", $Win_POS[2] - 142, 5, 45, 29)
	$Button_Minimize_Array[0] = GUICtrlCreatePic("", $Win_POS[2] - 96, 5, 45, 29)
	$Button_Minimize_Array[1] = False
	$Button_Minimize_Array[3] = "0"

	;Create Graphics Arrays, 0=default button, 1=button with hover effect
	Local $Button_Close_Bitmaps[2] = [_GDIPlus_BitmapCreateFromScan0(45, 29), _GDIPlus_BitmapCreateFromScan0(45, 29)]
	Local $Button_Close_GraphicsContext[2] = [_GDIPlus_ImageGetGraphicsContext($Button_Close_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Button_Close_Bitmaps[1])]
	Local $Button_Minimize_Bitmaps[2] = [_GDIPlus_BitmapCreateFromScan0(45, 29), _GDIPlus_BitmapCreateFromScan0(45, 29)]
	Local $Button_Minimize_GraphicsContext[2] = [_GDIPlus_ImageGetGraphicsContext($Button_Minimize_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Button_Minimize_Bitmaps[1])]

	;Set button BG colors
	If $CloseButtonOnStyle Then
		_GDIPlus_GraphicsClear($Button_Close_GraphicsContext[0], "0xFFB52231");
	Else
		_GDIPlus_GraphicsClear($Button_Close_GraphicsContext[0], $GUI_BG_Color)
	EndIf
	_GDIPlus_GraphicsClear($Button_Close_GraphicsContext[1], "0xFFE81123")
	_GDIPlus_GraphicsClear($Button_Minimize_GraphicsContext[0], $GUI_BG_Color)
	_GDIPlus_GraphicsClear($Button_Minimize_GraphicsContext[1], $Hover_BK_Color)

	;Set Smoothing/Antialiasing for close button
	_GDIPlus_GraphicsSetSmoothingMode($Button_Close_GraphicsContext[0], 4)
	_GDIPlus_GraphicsSetSmoothingMode($Button_Close_GraphicsContext[1], 4)

	;Create Close Button
	If $CloseButtonOnStyle Then
		_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[0], 17, 9, 27, 19, $hPen3)
		_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[0], 27, 9, 17, 19, $hPen3)
	Else
		_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[0], 17, 9, 27, 19, $hPen)
		_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[0], 27, 9, 17, 19, $hPen)
	EndIf
	_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[1], 17, 9, 27, 19, $hPen3)
	_GDIPlus_GraphicsDrawLine($Button_Close_GraphicsContext[1], 27, 9, 17, 19, $hPen3)

	;Create Minimize Button
	If $ThickStyle Then
		_GDIPlus_GraphicsDrawLine($Button_Minimize_GraphicsContext[0], 18, 16, 28, 16, $hPen)
		_GDIPlus_GraphicsDrawLine($Button_Minimize_GraphicsContext[1], 18, 16, 28, 16, $hPen2)
	Else
		_GDIPlus_GraphicsDrawLine($Button_Minimize_GraphicsContext[0], 18, 14, 27, 14, $hPen)
		_GDIPlus_GraphicsDrawLine($Button_Minimize_GraphicsContext[1], 18, 14, 27, 14, $hPen2)
	EndIf

	;Release created objects
	_GDIPlus_GraphicsDispose($Button_Close_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Button_Close_GraphicsContext[1])
	_GDIPlus_GraphicsDispose($Button_Minimize_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Button_Minimize_GraphicsContext[1])
	_GDIPlus_PenDispose($hPen)
	_GDIPlus_PenDispose($hPen2)
	_GDIPlus_PenDispose($hPen3)
	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_BrushDispose($hBrush2)


	;Create bitmap handles
	$Button_Close_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Close_Bitmaps[0])
	$Button_Close_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Close_Bitmaps[1])
	$Button_Minimize_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Minimize_Bitmaps[0])
	$Button_Minimize_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Minimize_Bitmaps[1])

	;More cleanup
	_GDIPlus_BitmapDispose($Button_Close_Bitmaps[0])
	_GDIPlus_BitmapDispose($Button_Close_Bitmaps[1])
	_GDIPlus_BitmapDispose($Button_Minimize_Bitmaps[0])
	_GDIPlus_BitmapDispose($Button_Minimize_Bitmaps[1])

	;For GUI Resizing
	GUICtrlSetResizing($Button_Close_Array[0], 768 + 32 + 4)
	GUICtrlSetResizing($Button_Minimize_Array[0], 768 + 32 + 4)

	;Set default button images visible
	_WinAPI_DeleteObject(GUICtrlSendMsg($Button_Close_Array[0], 0x0172, 0, $Button_Close_Array[5]))
	_WinAPI_DeleteObject(GUICtrlSendMsg($Button_Minimize_Array[0], 0x0172, 0, $Button_Minimize_Array[5]))

	$Control_Buttons[0] = $Button_Close_Array[0]
	$Control_Buttons[3] = $Button_Minimize_Array[0]

	_Metro_AddHoverItem($GUI_HOVER_REG, $Button_Close_Array)
	_Metro_AddHoverItem($GUI_HOVER_REG, $Button_Minimize_Array)
	Return $Control_Buttons
EndFunc   ;==>_Metro_CreateControlButtonsCloseMini


; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_GUIDelete
; Description ...: Destroys all created metro buttons,checkboxes,radios etc., deletes the GUI and reduces memory usage.
; Syntax ........: _Metro_GUIDelete($GUI_HOVER_REG, $GUI)
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $GUI                 - The GUI to delete.
; ===============================================================================================================================
Func _Metro_GUIDelete($GUI_HOVER_REG, $GUI)
	For $i = 0 To (UBound($GUI_HOVER_REG) - 1) Step +1
		Switch ($GUI_HOVER_REG[$i][3])
			Case "5", "7"
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][5])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][6])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][7])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][8])
			Case "6"
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][5])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][6])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][7])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][8])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][9])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][10])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][11])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][12])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][13])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][14])
			Case Else
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][5])
				_WinAPI_DeleteObject($GUI_HOVER_REG[$i][6])
		EndSwitch
	Next
	GUIDelete($GUI)
	_ReduceMemory()
EndFunc   ;==>_Metro_GUIDelete
#EndRegion MetroGUI===========================================================================================

#Region MetroButtons===========================================================================================
; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CreateButtonEx
; Description ...: Creates Windows 10 style buttons with a frame around. Hovering changes the button color to a lighter color.
; Syntax ........: _Metro_CreateButtonEx(Byref $GUI_HOVER_REG, $Text, $Left, $Top, $Width, $Height[, $BG_Color = $ButtonBKColor[,
;                  $Font_Color = $ButtonTextColor[, $Font = "Arial"[, $Fontsize = 12.5[, $FontStyle = 1[,
;                  $FrameColor = "0xFFFFFF"]]]]]])
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Text            	- Text of the button.
;                  $Left              	- Left pos.
;                  $Top                 - Top pos.
;                  $Width               - Width.
;                  $Height              - Height.
;                  $BG_Color       	    - [optional] Button background color. Default is $ButtonBKColor.
;                  $Font_Color       	- [optional] Font colore. Default is $ButtonTextColor.
;                  $Font            	- [optional] Font. Default is "Arial".
;                  $Fontsize        	- [optional] Fontsize. Default is 12.5.
;                  $FontStyle       	- [optional] Fontstyle. Default is 1.
;                  $FrameColor      	- [optional] Button frame color. Default is "0xFFFFFF".
; Return values .: Handle to the button.
; Example .......: _Metro_CreateButtonEx($GUI_HOVER_REG,"Button 1",50,50,120,34)
; ===============================================================================================================================

Func _Metro_CreateButtonEx(ByRef $GUI_HOVER_REG, $Text, $Left, $Top, $Width, $Height, $BG_Color = $ButtonBKColor, $Font_Color = $ButtonTextColor, $Font = "Arial", $Fontsize = 11, $FontStyle = 1, $FrameColor = "0xFFFFFF")
	Local $Button_Array[15]
	$Button_Array[0] = GUICtrlCreatePic("", $Left, $Top, $Width, $Height)
	$Button_Array[1] = False; Set hover OFF
	$Button_Array[3] = "2"; Type

	;Set Colors
	$BG_Color = StringReplace($BG_Color, "0x", "0xFF")
	$Font_Color = StringReplace($Font_Color, "0x", "0xFF")
	$FrameColor = StringReplace($FrameColor, "0x", "0xFF")
	Local $Brush_BTN_FontColor = _GDIPlus_BrushCreateSolid($Font_Color)
	Local $Pen_BTN_FrameHoverColor = _GDIPlus_PenCreate($FrameColor, 2)

	;Create Graphics Arrays, 0=default Button, 1=Button with Hover Effect
	Local $Button_Bitmaps[2] = [_GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height)]
	Local $Button_GraphicsContext[2] = [_GDIPlus_ImageGetGraphicsContext($Button_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Button_Bitmaps[1])]

	;Create font, Set font options
	$Fontsize = $Fontsize / $Font_DPI_Ratio;Set Fontsize to match the selected DPI Settings in Windows

	Local $hFormat = _GDIPlus_StringFormatCreate(), $hFamily = _GDIPlus_FontFamilyCreate($Font), $hFont = _GDIPlus_FontCreate($hFamily, $Fontsize, $FontStyle)
	Local $tLayout = _GDIPlus_RectFCreate(0, 0, $Width, $Height)
	_GDIPlus_StringFormatSetAlign($hFormat, 1)
	_GDIPlus_StringFormatSetLineAlign($hFormat, 1)
	_GDIPlus_GraphicsSetTextRenderingHint($Button_GraphicsContext[0], 5);Set ClearType option for the Font
	_GDIPlus_GraphicsSetTextRenderingHint($Button_GraphicsContext[1], 5);Set ClearType option for the Font

	;Set button BG color
	_GDIPlus_GraphicsClear($Button_GraphicsContext[0], $BG_Color)
	_GDIPlus_GraphicsClear($Button_GraphicsContext[1], StringReplace(_AlterBrightness(StringReplace($BG_Color, "0xFF", "0x"), 25), "0x", "0xFF"))

	;Draw button text
	_GDIPlus_GraphicsDrawStringEx($Button_GraphicsContext[0], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Button_GraphicsContext[1], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)

	;Add frames
	_GDIPlus_GraphicsDrawRect($Button_GraphicsContext[0], 0, 0, $Width, $Height, $Pen_BTN_FrameHoverColor)
	_GDIPlus_GraphicsDrawRect($Button_GraphicsContext[1], 0, 0, $Width, $Height, $Pen_BTN_FrameHoverColor)

	;Release created objects
	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_GDIPlus_GraphicsDispose($Button_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Button_GraphicsContext[1])
	_GDIPlus_BrushDispose($Brush_BTN_FontColor)
	_GDIPlus_PenDispose($Pen_BTN_FrameHoverColor)

	;Create bitmap handles
	$Button_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Bitmaps[0])
	$Button_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Bitmaps[1])

	;More cleanup
	_GDIPlus_BitmapDispose($Button_Bitmaps[0])
	_GDIPlus_BitmapDispose($Button_Bitmaps[1])

	;For GUI Resizing
	GUICtrlSetResizing($Button_Array[0], 768)

	;Set default button image visible
	_WinAPI_DeleteObject(GUICtrlSendMsg($Button_Array[0], 0x0172, 0, $Button_Array[5]))

	_Metro_AddHoverItem($GUI_HOVER_REG, $Button_Array)
	Return $Button_Array[0]
EndFunc   ;==>_Metro_CreateButtonEx




; ===============================================================================================================================
; Name ..........: _Metro_CreateButton
; Description ...: Creates metro style buttons. Hovering creates a frame around the buttons.
; Syntax ........: _Metro_CreateButton(Byref $GUI_HOVER_REG, $Text, $Left, $Top, $Width, $Height[, $BGColor = $ButtonBKColor[,
;                  $FontColor = $ButtonTextColor[, $Font = "Arial"[, $Fontsize = 12.5[, $FontStyle = 1 $FrameColor = "0xFFFFFF"]]]]])
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Text            - Text of the button.
;                  $Left               - Left pos.
;                  $Top                - Top pos.
;                  $Width              - Width.
;                  $Height             - Height.
;                  $BGColor         - [optional] Button background color. Default is $ButtonBKColor.
;                  $FontColor       - [optional] Font colore. Default is $ButtonTextColor.
;                  $Font            - [optional] Font. Default is "Arial".
;                  $Fontsize        - [optional] Fontsize. Default is 12.5.
;                  $FontStyle       - [optional] Fontstyle. Default is 1.
;                  $FrameColor      - [optional] Button frame color. Default is "0xFFFFFF".
; Return values .: Handle to the button.
; Example .......: _Metro_CreateButton($GUI_HOVER_REG,"Button 1",50,50,120,34)
; ===============================================================================================================================

Func _Metro_CreateButton(ByRef $GUI_HOVER_REG, $Text, $Left, $Top, $Width, $Height, $BGColor = $ButtonBKColor, $FontColor = $ButtonTextColor, $Font = "Arial", $Fontsize = 11, $FontStyle = 1, $FrameColor = "0xFFFFFF")
	Local $Button_Array[15];Array with basic information about the created Button
	$Button_Array[0] = GUICtrlCreatePic("", $Left, $Top, $Width, $Height)
	$Button_Array[1] = False; Set hover OFF
	$Button_Array[3] = "1"; Type

	;Button Colors
	$BGColor = StringReplace($BGColor, "0x", "0xFF")
	$FontColor = StringReplace($FontColor, "0x", "0xFF")
	$FrameColor = StringReplace($FrameColor, "0x", "0xFF")

	;Create Graphics Arrays
	Local $Button_Bitmaps[2] = [_GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height)]
	Local $Button_GraphicsContext[2] = [_GDIPlus_ImageGetGraphicsContext($Button_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Button_Bitmaps[1])]

	;Create font, Set font options
	$Fontsize = $Fontsize / $Font_DPI_Ratio;Set Fontsize to match the selected DPI Settings in Windows
	Local $Brush_BTN_FontColor = _GDIPlus_BrushCreateSolid($FontColor)
	Local $hFormat = _GDIPlus_StringFormatCreate(), $hFamily = _GDIPlus_FontFamilyCreate($Font), $hFont = _GDIPlus_FontCreate($hFamily, $Fontsize, $FontStyle)
	Local $tLayout = _GDIPlus_RectFCreate(0, 0, $Width, $Height)
	_GDIPlus_StringFormatSetAlign($hFormat, 1)
	_GDIPlus_StringFormatSetLineAlign($hFormat, 1)
	_GDIPlus_GraphicsSetTextRenderingHint($Button_GraphicsContext[0], 5);Set ClearType option for the Font

	;Set button BG color
	_GDIPlus_GraphicsClear($Button_GraphicsContext[0], $BGColor)

	;Draw button text
	_GDIPlus_GraphicsDrawStringEx($Button_GraphicsContext[0], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)

	;Copy button bitmap from first graphic and add frame for hover effects
	Local $Pen_BTN_FrameHoverColor = _GDIPlus_PenCreate($FrameColor, 4)
	_GDIPlus_GraphicsDrawImageRect($Button_GraphicsContext[1], $Button_Bitmaps[0], 0, 0, $Width, $Height)
	_GDIPlus_GraphicsDrawRect($Button_GraphicsContext[1], 0, 0, $Width, $Height, $Pen_BTN_FrameHoverColor)

	;Release created objects
	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_GDIPlus_GraphicsDispose($Button_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Button_GraphicsContext[1])
	_GDIPlus_BrushDispose($Brush_BTN_FontColor)
	_GDIPlus_PenDispose($Pen_BTN_FrameHoverColor)

	;Create bitmap handles
	$Button_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Bitmaps[0])
	$Button_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Button_Bitmaps[1])

	;More cleanup
	_GDIPlus_BitmapDispose($Button_Bitmaps[0])
	_GDIPlus_BitmapDispose($Button_Bitmaps[1])

	;For GUI Resizing
	GUICtrlSetResizing($Button_Array[0], 768)

	;Set default button image visible
	_WinAPI_DeleteObject(GUICtrlSendMsg($Button_Array[0], 0x0172, 0, $Button_Array[5]))

	_Metro_AddHoverItem($GUI_HOVER_REG, $Button_Array)
	Return $Button_Array[0]
EndFunc   ;==>_Metro_CreateButton



;===================== GUI_HOVER_REG Array Legend [INTERNAL USE ONLY]=============
;[0] = ImageHandle
;[1] = Hover = True/False
;[2] = Checked/Not Checked = True/False
;[3] = Type (Checkbox,Buttons etc.)
;[4] = Radiogroup (Only for Radios)

;[5] = Image -> default state
;[6] = Image -> default hover state
;[7] = Image -> checked state
;[8] = Image -> checked hover state

;[9] = Image -> Toggle effects
;[10] = Image -> Toggle effects
;[11] = Image -> Toggle effects
;[12] = Image -> Toggle effects
;[13] = Image -> Toggle effects
;[14] = Image -> Toggle effects

;Buttons:    [0],[1],[3],[5],[6]
;Checkboxes: [0],[1],[2],[3],[5],[6],[7],[8]
;Toggles:	 [0],[1],[2],[3],[5]=Normal Sate,[6]->[11]=CheckedSteps 1-6,[12]=Checked Sate,[13]=Normal hover state,[14]=Checked hover state
;Radios: 	 [0],[1],[2],[3],[4],[5],[6],[7],[8]
;==================================================================================



; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_HoverCheck_Loop
; Description ...: Checks all created buttons, checkboxes etc for mouse hover. Required for the hover effects. This has to be added to the main while loop of the GUI.
; Syntax ........: _Metro_HoverCheck_Loop(Byref $GUI_HOVER_REG, $Metro_GUI[, $Metro_GUI_2 = 0])
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Metro_GUI           - The GUI to check for the mouse hover.
;                  $Metro_GUI_2         - [optional] A second GUI to check for the mouse hover.(If you have 2 GUIs in one for example)
; ===============================================================================================================================
Func _Metro_HoverCheck_Loop(ByRef $GUI_HOVER_REG, $Metro_GUI, $Metro_GUI_2 = 0)
	Local $MInfo
;~ 	If WinActive($Metro_GUI) Or WinActive($Metro_GUI_2) Then
		$MInfo = GUIGetCursorInfo($Metro_GUI)
		For $i_BTN = 0 To (UBound($GUI_HOVER_REG) - 1)
			Switch $GUI_HOVER_REG[$i_BTN][3]
				Case "3";Swap Max/Restore buttons on state change
					$Max_State = WinGetState($Metro_GUI)
					If Not ($Max_State = 47) Then
						If GUICtrlGetState($GUI_HOVER_REG[$i_BTN][0]) = 96 Then GUICtrlSetState($GUI_HOVER_REG[$i_BTN][0], 16)
					Else
						If GUICtrlGetState($GUI_HOVER_REG[$i_BTN][0]) = 80 Then GUICtrlSetState($GUI_HOVER_REG[$i_BTN][0], 32)
					EndIf
				Case "4";Swap Max/Restore buttons on state change
					$Max_State = WinGetState($Metro_GUI)
					If ($Max_State = 47) Then
						If GUICtrlGetState($GUI_HOVER_REG[$i_BTN][0]) = 96 Then GUICtrlSetState($GUI_HOVER_REG[$i_BTN][0], 16)
					Else
						If GUICtrlGetState($GUI_HOVER_REG[$i_BTN][0]) = 80 Then GUICtrlSetState($GUI_HOVER_REG[$i_BTN][0], 32)
					EndIf
				Case "5", "7";Check hover for checkboxes and radios
					If $MInfo[4] = $GUI_HOVER_REG[$i_BTN][0] Then;Enable hover
						If (Not $GUI_HOVER_REG[$i_BTN][1]) And Not (GUICtrlGetState($GUI_HOVER_REG[$i_BTN][0]) = 144) Then
							$GUI_HOVER_REG[$i_BTN][1] = True
							If $GUI_HOVER_REG[$i_BTN][2] Then
								_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][8]));Checked hover image
							Else
								_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][6]));Default hover image
							EndIf
						EndIf
					Else;Disable hover
						If $GUI_HOVER_REG[$i_BTN][1] Then
							$GUI_HOVER_REG[$i_BTN][1] = False
							If $GUI_HOVER_REG[$i_BTN][2] Then
								_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][7]));Checked image
							Else
								_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][5]));Default image
							EndIf
						EndIf
					EndIf
					ContinueLoop
				Case "6";Check hover for Toggles
					If $MInfo[4] = $GUI_HOVER_REG[$i_BTN][0] Then
						If (Not $GUI_HOVER_REG[$i_BTN][1]) And Not (GUICtrlGetState($GUI_HOVER_REG[$i_BTN][0]) = 144) Then
							$GUI_HOVER_REG[$i_BTN][1] = True
							If $GUI_HOVER_REG[$i_BTN][2] Then
								_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][14]));Checked hover image
							Else
								_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][13]));Default hover image
							EndIf
						EndIf
					Else;Disable hover Toggles
						If $GUI_HOVER_REG[$i_BTN][1] Then
							$GUI_HOVER_REG[$i_BTN][1] = False
							If $GUI_HOVER_REG[$i_BTN][2] Then
								_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][12]));Checked image
							Else
								_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][5]));Default image
							EndIf
						EndIf
					EndIf
					ContinueLoop
			EndSwitch

			;Enable Hover for Buttons
			If $MInfo[4] = $GUI_HOVER_REG[$i_BTN][0] Then;If mouseover
				If (Not $GUI_HOVER_REG[$i_BTN][1]) And Not (GUICtrlGetState($GUI_HOVER_REG[$i_BTN][0]) = 144) Then;if not hover on allready and button enabled
					$GUI_HOVER_REG[$i_BTN][1] = True
					_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][6]));Button hover image
				EndIf
				GUISetCursor(2, 1)
				ContinueLoop
			EndIf
			;Disable hover for Buttons
			If $GUI_HOVER_REG[$i_BTN][1] Then
				$GUI_HOVER_REG[$i_BTN][1] = False
				_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i_BTN][0], 0x0172, 0, $GUI_HOVER_REG[$i_BTN][5]));Button default image
			EndIf
		Next
;~ 	EndIf
EndFunc   ;==>_Metro_HoverCheck_Loop

Func _Metro_AddHoverItem(ByRef $Hover_Buttons, $Button_ADD)
	ReDim $Hover_Buttons[UBound($Hover_Buttons) + 1][15]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][0] = $Button_ADD[0]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][1] = $Button_ADD[1]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][2] = $Button_ADD[2]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][3] = $Button_ADD[3]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][4] = $Button_ADD[4]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][5] = $Button_ADD[5]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][6] = $Button_ADD[6]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][7] = $Button_ADD[7]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][8] = $Button_ADD[8]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][9] = $Button_ADD[9]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][10] = $Button_ADD[10]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][11] = $Button_ADD[11]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][12] = $Button_ADD[12]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][13] = $Button_ADD[13]
	$Hover_Buttons[UBound($Hover_Buttons) - 1][14] = $Button_ADD[14]
EndFunc   ;==>_Metro_AddHoverItem

Func _Metro_InitHover()
	Local $GUI_HOVER_REG[0]
	Return $GUI_HOVER_REG
EndFunc   ;==>_Metro_InitHover
#EndRegion MetroButtons===========================================================================================


#Region Metro Toggles===========================================================================================
; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CreateToggle
; Description ...: Creates a Windows 10 style toggle with a text on the right side.
; Syntax ........: _Metro_CreateToggle(Byref $GUI_HOVER_REG, $Text, $Left, $Top, $Width, $Height[, $BG_Color = $GUIThemeColor[,
;                  $Font_Color = $FontThemeColor[, $Font = "Segoe UI"[, $FontSize = "11"[, $FontStyle = 0]]]]])
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Text                - Text to be displayed on the right side of the GUI.
;                  $Left                - Left pos
;                  $Top                 - Top pos.
;                  $Width               - Width
;                  $Height              - Height
;                  $BG_Color            - [optional] Background color. Default is $GUIThemeColor.
;                  $Font_Color          - [optional] Font color. Default is $FontThemeColor.
;                  $Font                - [optional] Font. Default is "Segoe UI".
;                  $FontSize            - [optional] Fontsize. Default is "11".
;                  $FontStyle           - [optional] Fontstyle. Default is 0.
; Return values .: Handle to the toggle.
; ===============================================================================================================================
Func _Metro_CreateToggle(ByRef $GUI_HOVER_REG, $Text, $Left, $Top, $Width, $Height, $BG_Color = $GUIThemeColor, $Font_Color = $FontThemeColor, $Font = "Segoe UI", $Fontsize = "11", $FontStyle = 0)
	If $Height < 20 Then
		If (@Compiled = 0) Then MsgBox(48, "Metro UDF", "The min. height is 20px for metro toggles.")
	EndIf
	If $Width < 46 Then
		If (@Compiled = 0) Then MsgBox(48, "Metro UDF", "The min. width for metro toggles must be at least 46px without any text!")
	EndIf

	Local $Toggle_Array[15]
	$Toggle_Array[0] = GUICtrlCreatePic("", $Left, $Top, $Width, $Height)
	$Toggle_Array[1] = False; Hover
	$Toggle_Array[2] = False; Checked State
	$Toggle_Array[3] = "6"; Type

	;Set position
	$TopMargin = ($Height - 20) / 2

	;Set Colors
	$BG_Color = StringReplace($BG_Color, "0x", "0xFF")
	$Font_Color = StringReplace($FontThemeColor, "0x", "0xFF")
	Local $Brush_BTN_FontColor = _GDIPlus_BrushCreateSolid($Font_Color)
	Local $Brush_BTN_FontColor1 = _GDIPlus_BrushCreateSolid(StringReplace($CB_Radio_Color, "0x", "0xFF"))

	If StringInStr($GUI_Theme_Name, "Light") Then
		Local $BoxFrameCol = StringReplace(_AlterBrightness($Font_Color, +65), "0x", "0xFF")
	Else
		Local $BoxFrameCol = StringReplace(_AlterBrightness($Font_Color, -65), "0x", "0xFF")
	EndIf
	If StringInStr($GUI_Theme_Name, "Light") Then
		Local $Font_Color1 = StringReplace(_AlterBrightness($Font_Color, +45), "0x", "0xFF")
	Else
		Local $Font_Color1 = StringReplace(_AlterBrightness($Font_Color, -45), "0x", "0xFF")
	EndIf
	Local $BoxFrameCol1 = StringReplace($CB_Radio_CheckMark_Color, "0x", "0xFF")
	Local $Brush1 = _GDIPlus_BrushCreateSolid($BoxFrameCol)
	Local $Brush2 = _GDIPlus_BrushCreateSolid($BoxFrameCol1)
	Local $Brush3 = _GDIPlus_BrushCreateSolid(StringReplace($ButtonBKColor, "0x", "0xFF"))
	Local $Brush4 = _GDIPlus_BrushCreateSolid($Font_Color1)
	Local $Brush5 = _GDIPlus_BrushCreateSolid(StringReplace(_AlterBrightness($ButtonBKColor, +20), "0x", "0xFF"))


	;Create image array
	Local $Toggle_Bitmaps[10] = [_GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height)]
	Local $Toggle_GraphicsContext[10] = [_GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[1]), _GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[2]), _GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[3]), _GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[4]), _GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[5]), _GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[6]), _GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[7]), _GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[8]), _GDIPlus_ImageGetGraphicsContext($Toggle_Bitmaps[9])]

	;Set font options
	$Fontsize = $Fontsize / $Font_DPI_Ratio;Set Fontsize to match the selected DPI Settings in Windows
	Local $hFormat = _GDIPlus_StringFormatCreate(), $hFamily = _GDIPlus_FontFamilyCreate($Font), $hFont = _GDIPlus_FontCreate($hFamily, $Fontsize, 0)
	Local $tLayout = _GDIPlus_RectFCreate(50, 0, $Width - 50, $Height)
	_GDIPlus_StringFormatSetAlign($hFormat, 1)
	_GDIPlus_StringFormatSetLineAlign($hFormat, 1)
	$tLayout.Y = 1

	;Set ClearType option for the font
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[0], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[1], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[2], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[3], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[4], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[5], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[6], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[7], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[8], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Toggle_GraphicsContext[9], 5)

	;Set BG color
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[0], $BG_Color)
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[1], $BG_Color)
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[2], $BG_Color)
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[3], $BG_Color)
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[4], $BG_Color)
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[5], $BG_Color)
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[6], $BG_Color)
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[7], $BG_Color)
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[8], $BG_Color)
	_GDIPlus_GraphicsClear($Toggle_GraphicsContext[9], $BG_Color)

	;Draw text
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[0], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[1], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[2], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[3], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[4], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[5], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[6], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[7], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[8], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Toggle_GraphicsContext[9], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)


	;Default state
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[0], 0, $TopMargin, 46, 20, $Brush1); Toggle Background
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[0], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2);Toggle inner Border
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[0], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush1);Toggle Inner
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[0], 0, $TopMargin, 11, 20, $Brush_BTN_FontColor1); Toggle Slider

	;Default hover state
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[8], 0, $TopMargin, 46, 20, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[8], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[8], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush4)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[8], 0, $TopMargin, 11, 20, $Brush_BTN_FontColor1)

	;CheckedStep1
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[1], 0, $TopMargin, 46, 20, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[1], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[1], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[1], 5, $TopMargin, 11, 20, $Brush_BTN_FontColor1)

	;CheckedStep2
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[2], 0, $TopMargin, 46, 20, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[2], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[2], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[2], 10, $TopMargin, 11, 20, $Brush_BTN_FontColor1)

	;CheckedStep3
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[3], 0, $TopMargin, 46, 20, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[3], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[3], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[3], 15, $TopMargin, 11, 20, $Brush_BTN_FontColor1)

	;CheckedStep4
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[4], 0, $TopMargin, 46, 20, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[4], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[4], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush3)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[4], 20, $TopMargin, 11, 20, $Brush_BTN_FontColor1)

	;CheckedStep5
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[5], 0, $TopMargin, 46, 20, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[5], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[5], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush3)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[5], 25, $TopMargin, 11, 20, $Brush_BTN_FontColor1)

	;CheckedStep6
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[6], 0, $TopMargin, 46, 20, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[6], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[6], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush3)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[6], 30, $TopMargin, 11, 20, $Brush_BTN_FontColor1)

	;Final checked state
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[7], 0, $TopMargin, 46, 20, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[7], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[7], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush3)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[7], 46 - 11, $TopMargin, 11, 20, $Brush_BTN_FontColor1)

	;Final checked state hover
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[9], 0, $TopMargin, 46, 20, $Brush1)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[9], 2, $TopMargin + 2, 46 - 4, 20 - 4, $Brush2)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[9], 3, $TopMargin + 3, 46 - 6, 20 - 6, $Brush5)
	_GDIPlus_GraphicsFillRect($Toggle_GraphicsContext[9], 46 - 11, $TopMargin, 11, 20, $Brush_BTN_FontColor1)

	;Release created objects
	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[1])
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[2])
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[3])
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[4])
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[5])
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[6])
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[7])
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[8])
	_GDIPlus_GraphicsDispose($Toggle_GraphicsContext[9])
	_GDIPlus_BrushDispose($Brush_BTN_FontColor)
	_GDIPlus_BrushDispose($Brush_BTN_FontColor1)
	_GDIPlus_BrushDispose($Brush1)
	_GDIPlus_BrushDispose($Brush2)
	_GDIPlus_BrushDispose($Brush3)
	_GDIPlus_BrushDispose($Brush4)
	_GDIPlus_BrushDispose($Brush5)

	;Create bitmap handles
	$Toggle_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[0])
	$Toggle_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[1])
	$Toggle_Array[7] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[2])
	$Toggle_Array[8] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[3])
	$Toggle_Array[9] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[4])
	$Toggle_Array[10] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[5])
	$Toggle_Array[11] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[6])
	$Toggle_Array[12] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[7])
	$Toggle_Array[13] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[8])
	$Toggle_Array[14] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Toggle_Bitmaps[9])

	;More cleanup
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[0])
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[1])
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[2])
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[3])
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[4])
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[5])
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[6])
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[7])
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[8])
	_GDIPlus_BitmapDispose($Toggle_Bitmaps[9])

	;For GUI Resizing
	GUICtrlSetResizing($Toggle_Array[0], 768)

	;Set Visible
	_WinAPI_DeleteObject(GUICtrlSendMsg($Toggle_Array[0], 0x0172, 0, $Toggle_Array[5]))

	;Add to GUI_HOVER_REG
	_Metro_AddHoverItem($GUI_HOVER_REG, $Toggle_Array)

	Return $Toggle_Array[0]
EndFunc   ;==>_Metro_CreateToggle


; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_ToggleIsChecked
; Description ...: Checks if a toggle is checked
; Syntax ........: _Metro_ToggleIsChecked(Byref $GUI_HOVER_REG, $Toggle)
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Toggle              - Handle of the toggle.
; Return values .: True / False
; ===============================================================================================================================
Func _Metro_ToggleIsChecked(ByRef $GUI_HOVER_REG, $Toggle)
	For $i = 0 To (UBound($GUI_HOVER_REG) - 1) Step +1
		If $GUI_HOVER_REG[$i][0] = $Toggle Then
			If $GUI_HOVER_REG[$i][2] Then
				Return True
			Else
				Return False
			EndIf
		EndIf
	Next
EndFunc   ;==>_Metro_ToggleIsChecked

; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_ToggleUnCheck
; Description ...: Unchecks/Disables a toggle
; Syntax ........: _Metro_ToggleUnCheck(Byref $GUI_HOVER_REG, $Toggle)
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Toggle              - Handle to the toggle.
; ===============================================================================================================================
Func _Metro_ToggleUnCheck(ByRef $GUI_HOVER_REG, $Toggle, $NoAnimation = False)
	For $i = 0 To (UBound($GUI_HOVER_REG) - 1) Step +1
		If $GUI_HOVER_REG[$i][0] = $Toggle Then
			If $GUI_HOVER_REG[$i][2] Then
				If Not $NoAnimation Then
					For $i2 = 12 To 6 Step -1
						_WinAPI_DeleteObject(GUICtrlSendMsg($Toggle, 0x0172, 0, $GUI_HOVER_REG[$i][$i2]))
						Sleep(1)
					Next
					_WinAPI_DeleteObject(GUICtrlSendMsg($Toggle, 0x0172, 0, $GUI_HOVER_REG[$i][13]))
				Else
					_WinAPI_DeleteObject(GUICtrlSendMsg($Toggle, 0x0172, 0, $GUI_HOVER_REG[$i][13]))
				EndIf
				$GUI_HOVER_REG[$i][1] = True
				$GUI_HOVER_REG[$i][2] = False
				ExitLoop
			EndIf
		EndIf
	Next
EndFunc   ;==>_Metro_ToggleUnCheck

; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_ToggleCheck
; Description ...: Checks/enables a toggle
; Syntax ........: _Metro_ToggleCheck(Byref $GUI_HOVER_REG, $Toggle)
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Toggle              - Handle to the toggle.
; ===============================================================================================================================
Func _Metro_ToggleCheck(ByRef $GUI_HOVER_REG, $Toggle, $NoAnimation = False)
	For $i = 0 To (UBound($GUI_HOVER_REG) - 1) Step +1
		If $GUI_HOVER_REG[$i][0] = $Toggle Then
			If Not $GUI_HOVER_REG[$i][2] Then
				If Not $NoAnimation Then
					For $i2 = 6 To 11 Step +1
						_WinAPI_DeleteObject(GUICtrlSendMsg($Toggle, 0x0172, 0, $GUI_HOVER_REG[$i][$i2]))
						Sleep(1)
					Next
					_WinAPI_DeleteObject(GUICtrlSendMsg($Toggle, 0x0172, 0, $GUI_HOVER_REG[$i][14]))
				Else
					_WinAPI_DeleteObject(GUICtrlSendMsg($Toggle, 0x0172, 0, $GUI_HOVER_REG[$i][14]))
				EndIf
				$GUI_HOVER_REG[$i][2] = True
				$GUI_HOVER_REG[$i][1] = True
				ExitLoop
			EndIf
		EndIf
	Next
EndFunc   ;==>_Metro_ToggleCheck
#EndRegion Metro Toggles===========================================================================================


#Region MetroRadio===========================================================================================
; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CreateRadio
; Description ...: Creates a metro style radio.
; Syntax ........: _Metro_CreateRadio(Byref $GUI_HOVER_REG, $RadioGroup, $Text, $Left, $Top, $Width, $Height[, $BG_Color = $GUIThemeColor[,
;                  $Font_Color = $FontThemeColor[, $Font = "Segoe UI"[, $FontSize = "11"[, $FontStyle = 0]]]]])
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $RadioGroup          - A radiogroup to assign the radio to. You can use numbers or any text.
;                  $Text                - Text.
;                  $Left                - Left pos.
;                  $Top                 - Top pos.
;                  $Width               - Width.
;                  $Height              - Height.
;                  $BG_Color            - [optional] Background color. Default is $GUIThemeColor.
;                  $Font_Color          - [optional] Font color. Default is $FontThemeColor.
;                  $Font                - [optional] Font. Default is "Segoe UI".
;                  $FontSize            - [optional] Fontsize. Default is "11".
;                  $FontStyle           - [optional] Fontstyle. Default is 0.
;				   $$RadioCircleSize    - [optional] Custom height/width for the circle of the radio.
; Return values .: Handle to the radio.
; ===============================================================================================================================
Func _Metro_CreateRadio(ByRef $GUI_HOVER_REG, $RadioGroup, $Text, $Left, $Top, $Width, $Height, $BG_Color = $GUIThemeColor, $Font_Color = $FontThemeColor, $Font = "Segoe UI", $Fontsize = "11", $FontStyle = 0, $RadioCircleSize = 22)
	If $Height < 22 And $RadioCircleSize > 21 Then
		If (@Compiled = 0) Then MsgBox(48, "Metro UDF", "The min. height is 22px for metro radios.")
	EndIf
	If Not (Mod($Height, 2) = 0) Then
		If (@Compiled = 0) Then MsgBox(48, "Metro UDF", "Please try using an even number for the height of the radio, otherwise the check mark can be slightly left.")
	EndIf

	Local $Radio_Array[15]
	$Radio_Array[0] = GUICtrlCreatePic("", $Left, $Top, $Width, $Height)
	$Radio_Array[1] = False; Hover
	$Radio_Array[2] = False; Checkmark
	$Radio_Array[3] = "7"; Type
	$Radio_Array[4] = "1"; Radiogroup

	;Set position
	$TopMargin = ($Height - $RadioCircleSize) / 2

	;Set Colors
	$BG_Color = StringReplace($BG_Color, "0x", "0xFF")
	$Font_Color = StringReplace($Font_Color, "0x", "0xFF")
	Local $Brush_BTN_FontColor = _GDIPlus_BrushCreateSolid($Font_Color)
	Local $BoxFrameCol = StringReplace($CB_Radio_Hover_Color, "0x", "0xFF")
	Local $Brush1 = _GDIPlus_BrushCreateSolid(StringReplace($CB_Radio_Color, "0x", "0xFF"))
	Local $Brush2 = _GDIPlus_BrushCreateSolid(StringReplace($CB_Radio_CheckMark_Color, "0x", "0xFF"))
	Local $Brush3 = _GDIPlus_BrushCreateSolid(StringReplace($CB_Radio_Hover_Color, "0x", "0xFF"))

	;Create graphic arrays
	Local $Radio_Bitmaps[4] = [_GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height)]
	Local $Radio_GraphicsContext[4] = [_GDIPlus_ImageGetGraphicsContext($Radio_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Radio_Bitmaps[1]), _GDIPlus_ImageGetGraphicsContext($Radio_Bitmaps[2]), _GDIPlus_ImageGetGraphicsContext($Radio_Bitmaps[3])]

	;Create font, Set font options
	$Fontsize = $Fontsize / $Font_DPI_Ratio;Set Fontsize to match the selected DPI Settings in Windows
	Local $hFormat = _GDIPlus_StringFormatCreate(), $hFamily = _GDIPlus_FontFamilyCreate($Font), $hFont = _GDIPlus_FontCreate($hFamily, $Fontsize, $FontStyle)
	Local $tLayout = _GDIPlus_RectFCreate(30, 0, $Width - 30, $Height)
	_GDIPlus_StringFormatSetAlign($hFormat, 1)
	_GDIPlus_StringFormatSetLineAlign($hFormat, 1)
	$tLayout.Y = 1

	;Set ClearType option for the Font
	_GDIPlus_GraphicsSetTextRenderingHint($Radio_GraphicsContext[0], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Radio_GraphicsContext[1], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Radio_GraphicsContext[2], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Radio_GraphicsContext[3], 5)

	;Set radio BG color
	_GDIPlus_GraphicsClear($Radio_GraphicsContext[0], $BG_Color)
	_GDIPlus_GraphicsClear($Radio_GraphicsContext[1], $BG_Color)
	_GDIPlus_GraphicsClear($Radio_GraphicsContext[2], $BG_Color)
	_GDIPlus_GraphicsClear($Radio_GraphicsContext[3], $BG_Color)

	;Draw radio text
	_GDIPlus_GraphicsDrawStringEx($Radio_GraphicsContext[0], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Radio_GraphicsContext[1], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Radio_GraphicsContext[2], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Radio_GraphicsContext[3], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)

	;Add Circle Background
	_GDIPlus_GraphicsSetSmoothingMode($Radio_GraphicsContext[0], 2)
	_GDIPlus_GraphicsSetSmoothingMode($Radio_GraphicsContext[1], 2)
	_GDIPlus_GraphicsSetSmoothingMode($Radio_GraphicsContext[2], 2)
	_GDIPlus_GraphicsSetSmoothingMode($Radio_GraphicsContext[3], 2)

	;Default state
	_GDIPlus_GraphicsFillEllipse($Radio_GraphicsContext[0], 0, $TopMargin, $RadioCircleSize - 1, $RadioCircleSize - 1, $Brush1)

	;Default hover state
	_GDIPlus_GraphicsFillEllipse($Radio_GraphicsContext[2], 0, $TopMargin, $RadioCircleSize - 1, $RadioCircleSize - 1, $Brush3)

	;Checked state
	_GDIPlus_GraphicsFillEllipse($Radio_GraphicsContext[1], 0, $TopMargin, $RadioCircleSize - 1, $RadioCircleSize - 1, $Brush1)
	_GDIPlus_GraphicsFillEllipse($Radio_GraphicsContext[1], 5, $TopMargin + 5, $RadioCircleSize - 11, $RadioCircleSize - 11, $Brush2)

	;Checked hover state
	_GDIPlus_GraphicsFillEllipse($Radio_GraphicsContext[3], 0, $TopMargin, $RadioCircleSize - 1, $RadioCircleSize - 1, $Brush3)
	_GDIPlus_GraphicsFillEllipse($Radio_GraphicsContext[3], 5, $TopMargin + 5, $RadioCircleSize - 11, $RadioCircleSize - 11, $Brush2)

	;Release created objects
	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_GDIPlus_GraphicsDispose($Radio_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Radio_GraphicsContext[1])
	_GDIPlus_GraphicsDispose($Radio_GraphicsContext[2])
	_GDIPlus_GraphicsDispose($Radio_GraphicsContext[3])
	_GDIPlus_BrushDispose($Brush_BTN_FontColor)
	_GDIPlus_BrushDispose($Brush1)
	_GDIPlus_BrushDispose($Brush2)
	_GDIPlus_BrushDispose($Brush3)

	;Create bitmap handles
	$Radio_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Radio_Bitmaps[0])
	$Radio_Array[7] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Radio_Bitmaps[1])
	$Radio_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Radio_Bitmaps[2])
	$Radio_Array[8] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Radio_Bitmaps[3])

	;More cleanup
	_GDIPlus_BitmapDispose($Radio_Bitmaps[0])
	_GDIPlus_BitmapDispose($Radio_Bitmaps[1])
	_GDIPlus_BitmapDispose($Radio_Bitmaps[2])
	_GDIPlus_BitmapDispose($Radio_Bitmaps[3])

	;Set GUI Resizing
	GUICtrlSetResizing($Radio_Array[0], 768)

	;Set Visible
	_WinAPI_DeleteObject(GUICtrlSendMsg($Radio_Array[0], 0x0172, 0, $Radio_Array[5]))

	;Add Hover effects
	_Metro_AddHoverItem($GUI_HOVER_REG, $Radio_Array)

	Return $Radio_Array[0]
EndFunc   ;==>_Metro_CreateRadio


; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_RadioCheck
; Description ...: Checks the selected radio and unchecks all other radios in the same radiogroup.
; Syntax ........: _Metro_RadioCheck(Byref $GUI_HOVER_REG, $RadioGroup, $Radio)
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $RadioGroup          - The group that the radio has been assigned to.
;                  $Radio               - Handle to the radio.
; ===============================================================================================================================
Func _Metro_RadioCheck(ByRef $GUI_HOVER_REG, $RadioGroup, $Radio)
	For $i = 0 To (UBound($GUI_HOVER_REG) - 1) Step +1
		If $GUI_HOVER_REG[$i][0] = $Radio Then
			$GUI_HOVER_REG[$i][1] = True
			$GUI_HOVER_REG[$i][2] = True
			_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i][0], 0x0172, 0, $GUI_HOVER_REG[$i][8]))
		Else
			If $GUI_HOVER_REG[$i][4] = $RadioGroup Then
				$GUI_HOVER_REG[$i][2] = False
				_WinAPI_DeleteObject(GUICtrlSendMsg($GUI_HOVER_REG[$i][0], 0x0172, 0, $GUI_HOVER_REG[$i][5]))
			EndIf
		EndIf
	Next
EndFunc   ;==>_Metro_RadioCheck
#EndRegion MetroRadio===========================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_RadioIsChecked
; Description ...: Checks if a metro radio is checked.
; Syntax ........: _Metro_RadioIsChecked(Byref $GUI_HOVER_REG, $RadioGroup, $Radio)
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $RadioGroup          - Radio group
;				   $Radio				- Handle to the radio
; Return values .: True / False
; ===============================================================================================================================
Func _Metro_RadioIsChecked(ByRef $GUI_HOVER_REG, $RadioGroup, $Radio)
	For $i = 0 To (UBound($GUI_HOVER_REG) - 1) Step +1
		If $GUI_HOVER_REG[$i][0] = $Radio Then
			If $GUI_HOVER_REG[$i][4] = $RadioGroup Then
				If $GUI_HOVER_REG[$i][2] Then
					Return True
				Else
					Return False
				EndIf
			EndIf
		EndIf
	Next
	Return False
EndFunc   ;==>_Metro_RadioIsChecked


#Region MetroCheckbox===========================================================================================
; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CreateCheckbox
; Description ...: Creates a metro style checkbox
; Syntax ........: _Metro_CreateCheckbox(Byref $GUI_HOVER_REG, $Text, $Left, $Top, $Width, $Height[, $BG_Color = $GUIThemeColor[,
;                  $Font_Color = $FontThemeColor[, $Font = "Segoe UI"[, $FontSize = "11"[, $FontStyle = 0]]]]])
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Text                - Text.
;                  $Left                - Left pos.
;                  $Top                 - Top pos.
;                  $Width               - Width.
;                  $Height              - Height.
;                  $BG_Color            - [optional] Background color. Default is $GUIThemeColor.
;                  $Font_Color          - [optional] Font color. Default is $FontThemeColor.
;                  $Font                - [optional] Font. Default is "Segoe UI".
;                  $FontSize            - [optional] Fontsize. Default is "11".
;                  $FontStyle           - [optional] Fontstyle. Default is 0.
; Return values .: Handle to the Checkbox
; ===============================================================================================================================
Func _Metro_CreateCheckbox(ByRef $GUI_HOVER_REG, $Text, $Left, $Top, $Width, $Height, $BG_Color = $GUIThemeColor, $Font_Color = $FontThemeColor, $Font = "Segoe UI", $Fontsize = "11", $FontStyle = 0)
	If $Height < 22 Then
		If (@Compiled = 0) Then MsgBox(48, "Metro UDF", "The min. height is 22px for metro checkboxes.")
	EndIf
	If Not (Mod($Height, 2) = 0) Then
		If (@Compiled = 0) Then MsgBox(48, "Metro UDF", "Please use an even number for the height of the checkbox, otherwise the check mark can be slightly left.")
	EndIf

	Local $Checkbox_Array[15]
	$Checkbox_Array[0] = GUICtrlCreatePic("", $Left, $Top, $Width, $Height)
	$Checkbox_Array[1] = False; Hover
	$Checkbox_Array[2] = False; Checkmark
	$Checkbox_Array[3] = "5"; Type

	;Box position etc.
	$TopMargin = ($Height - 22) / 2
	$CheckBox_Text_Margin = 22 + ($TopMargin * 1.3)

	;Set Colors, Create Brushes and Pens
	$BG_Color = StringReplace($BG_Color, "0x", "0xFF")
	$Font_Color = StringReplace($Font_Color, "0x", "0xFF")
	Local $Brush_BTN_FontColor = _GDIPlus_BrushCreateSolid($Font_Color)
	Local $Brush_BoxBK = _GDIPlus_BrushCreateSolid(StringReplace($CB_Radio_Color, "0x", "0xFF"))
	Local $Brush1 = _GDIPlus_BrushCreateSolid(StringReplace($CB_Radio_Hover_Color, "0x", "0xFF"))
	Local $PenX = _GDIPlus_PenCreate(StringReplace($CB_Radio_CheckMark_Color, "0x", "0xFF"), 3)

	Local $Checkbox_Bitmaps[4] = [_GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height), _GDIPlus_BitmapCreateFromScan0($Width, $Height)]
	Local $Checkbox_GraphicsContext[4] = [_GDIPlus_ImageGetGraphicsContext($Checkbox_Bitmaps[0]), _GDIPlus_ImageGetGraphicsContext($Checkbox_Bitmaps[1]), _GDIPlus_ImageGetGraphicsContext($Checkbox_Bitmaps[2]), _GDIPlus_ImageGetGraphicsContext($Checkbox_Bitmaps[3])]

	;Create font, Set font options
	$Fontsize = $Fontsize / $Font_DPI_Ratio;Set Fontsize to match the selected DPI Settings in Windows
	Local $hFormat = _GDIPlus_StringFormatCreate(), $hFamily = _GDIPlus_FontFamilyCreate($Font), $hFont = _GDIPlus_FontCreate($hFamily, $Fontsize, $FontStyle)
	Local $tLayout = _GDIPlus_RectFCreate($CheckBox_Text_Margin, 0, $Width - $CheckBox_Text_Margin, $Height)
	_GDIPlus_StringFormatSetAlign($hFormat, 1)
	_GDIPlus_StringFormatSetLineAlign($hFormat, 1)
	$tLayout.Y = 1

	;Set ClearType option for the Font
	_GDIPlus_GraphicsSetTextRenderingHint($Checkbox_GraphicsContext[0], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Checkbox_GraphicsContext[1], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Checkbox_GraphicsContext[2], 5)
	_GDIPlus_GraphicsSetTextRenderingHint($Checkbox_GraphicsContext[3], 5)

	;Set checkbox BG color
	_GDIPlus_GraphicsClear($Checkbox_GraphicsContext[0], $BG_Color)
	_GDIPlus_GraphicsClear($Checkbox_GraphicsContext[1], $BG_Color)
	_GDIPlus_GraphicsClear($Checkbox_GraphicsContext[2], $BG_Color)
	_GDIPlus_GraphicsClear($Checkbox_GraphicsContext[3], $BG_Color)

	;Draw checkbox text
	_GDIPlus_GraphicsDrawStringEx($Checkbox_GraphicsContext[0], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Checkbox_GraphicsContext[1], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Checkbox_GraphicsContext[2], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)
	_GDIPlus_GraphicsDrawStringEx($Checkbox_GraphicsContext[3], $Text, $hFont, $tLayout, $hFormat, $Brush_BTN_FontColor)

	;Default state
	_GDIPlus_GraphicsFillRect($Checkbox_GraphicsContext[0], 0, $TopMargin, 22, 22, $Brush1)
	_GDIPlus_GraphicsFillRect($Checkbox_GraphicsContext[0], 1, $TopMargin + 1, 22 - 2, 22 - 2, $Brush_BoxBK)
	;Default hover state
	_GDIPlus_GraphicsFillRect($Checkbox_GraphicsContext[2], 0, $TopMargin, 22, 22, $Brush1)

	;Checked state
	_GDIPlus_GraphicsFillRect($Checkbox_GraphicsContext[1], 0, $TopMargin, 22, 22, $Brush1)
	_GDIPlus_GraphicsFillRect($Checkbox_GraphicsContext[1], 1, $TopMargin + 1, 22 - 2, 22 - 2, $Brush_BoxBK)
	;Checked hover state
	_GDIPlus_GraphicsFillRect($Checkbox_GraphicsContext[3], 0, $TopMargin, 22, 22, $Brush1)
	;Add check mark
	_GDIPlus_GraphicsSetSmoothingMode($Checkbox_GraphicsContext[1], 2)
	_GDIPlus_GraphicsSetSmoothingMode($Checkbox_GraphicsContext[3], 2)

	_GDIPlus_GraphicsDrawLine($Checkbox_GraphicsContext[1], 9, $TopMargin + 17, 18, $TopMargin + 3, $PenX)
	_GDIPlus_GraphicsDrawLine($Checkbox_GraphicsContext[3], 9, $TopMargin + 17, 18, $TopMargin + 3, $PenX)
	_GDIPlus_GraphicsDrawLine($Checkbox_GraphicsContext[1], 3, $TopMargin + 10, 10, $TopMargin + 17, $PenX)
	_GDIPlus_GraphicsDrawLine($Checkbox_GraphicsContext[3], 3, $TopMargin + 10, 10, $TopMargin + 17, $PenX)

	;Release created objects
	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_GDIPlus_GraphicsDispose($Checkbox_GraphicsContext[0])
	_GDIPlus_GraphicsDispose($Checkbox_GraphicsContext[1])
	_GDIPlus_GraphicsDispose($Checkbox_GraphicsContext[2])
	_GDIPlus_GraphicsDispose($Checkbox_GraphicsContext[3])
	_GDIPlus_BrushDispose($Brush_BTN_FontColor)
	_GDIPlus_BrushDispose($Brush1)
	_GDIPlus_BrushDispose($Brush_BoxBK)
	_GDIPlus_PenDispose($PenX)

	;Create bitmap handles
	$Checkbox_Array[5] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Checkbox_Bitmaps[0])
	$Checkbox_Array[7] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Checkbox_Bitmaps[1])
	$Checkbox_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Checkbox_Bitmaps[2])
	$Checkbox_Array[8] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Checkbox_Bitmaps[3])

	;More cleanup
	_GDIPlus_BitmapDispose($Checkbox_Bitmaps[0])
	_GDIPlus_BitmapDispose($Checkbox_Bitmaps[1])
	_GDIPlus_BitmapDispose($Checkbox_Bitmaps[2])
	_GDIPlus_BitmapDispose($Checkbox_Bitmaps[3])

	;For GUI Resizing
	GUICtrlSetResizing($Checkbox_Array[0], 768)

	;Set Visible
	_WinAPI_DeleteObject(GUICtrlSendMsg($Checkbox_Array[0], 0x0172, 0, $Checkbox_Array[5]))

	_Metro_AddHoverItem($GUI_HOVER_REG, $Checkbox_Array)

	Return $Checkbox_Array[0]
EndFunc   ;==>_Metro_CreateCheckbox

; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CheckboxIsChecked
; Description ...: Checks if a metro checkbox is checked.
; Syntax ........: _Metro_CheckboxIsChecked(Byref $GUI_HOVER_REG, $Checkbox)
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Checkbox            - Handle to the checkbox.
; Return values .: True / False
; ===============================================================================================================================
Func _Metro_CheckboxIsChecked(ByRef $GUI_HOVER_REG, $Checkbox)
	For $i = 0 To (UBound($GUI_HOVER_REG) - 1) Step +1
		If $GUI_HOVER_REG[$i][0] = $Checkbox Then
			If $GUI_HOVER_REG[$i][2] Then
				Return True
			Else
				Return False
			EndIf
		EndIf
	Next
EndFunc   ;==>_Metro_CheckboxIsChecked

; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CheckboxUnCheck
; Description ...: Unchecks a metro checkbox
; Syntax ........: _Metro_CheckboxUnCheck(Byref $GUI_HOVER_REG, $Checkbox)
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Checkbox            - Handle to the Checkbox.
; ===============================================================================================================================
Func _Metro_CheckboxUnCheck(ByRef $GUI_HOVER_REG, $Checkbox)
	For $i = 0 To (UBound($GUI_HOVER_REG) - 1) Step +1
		If $GUI_HOVER_REG[$i][0] = $Checkbox Then
			$GUI_HOVER_REG[$i][2] = False
			$GUI_HOVER_REG[$i][1] = True
			_WinAPI_DeleteObject(GUICtrlSendMsg($Checkbox, 0x0172, 0, $GUI_HOVER_REG[$i][6]))
		EndIf
	Next
EndFunc   ;==>_Metro_CheckboxUnCheck

; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CheckboxCheck
; Description ...: Checks a metro checkbox
; Syntax ........: _Metro_CheckboxCheck(Byref $GUI_HOVER_REG, $Checkbox)
; Parameters ....: $GUI_HOVER_REG       - The variable for the GUI_HOVER_REG array created by _Metro_CreateGUI.
;                  $Checkbox            - Handle to the Checkbox.
; ===============================================================================================================================
Func _Metro_CheckboxCheck(ByRef $GUI_HOVER_REG, $Checkbox)
	For $i = 0 To (UBound($GUI_HOVER_REG) - 1) Step +1
		If $GUI_HOVER_REG[$i][0] = $Checkbox Then
			$GUI_HOVER_REG[$i][2] = True
			$GUI_HOVER_REG[$i][1] = True
			_WinAPI_DeleteObject(GUICtrlSendMsg($Checkbox, 0x0172, 0, $GUI_HOVER_REG[$i][8]))
		EndIf
	Next
EndFunc   ;==>_Metro_CheckboxCheck
#EndRegion MetroCheckbox===========================================================================================



#Region Metro MsgBox===========================================================================================
; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_MsgBox
; Description ...: Creates a metro style MsgBox
; Syntax ........: _Metro_MsgBox($Flag, $Title, $Text[, $mWidth = 600[, $FontSize = 14[, $ParentGUI = ""]]])
; Parameters ....: $Flag                - Flag / Possible button combinations - See Autoit help file for possible buttons combinations under MsgBox
;				   $Title               - Title of the MsgBox.
;                  $Text                - Text of the MsgBox.
;                  $mWidth              - [optional] Width of the MsgBox. Use a value that matches the text length and font size. Default is 600.
;                  $FontSize            - [optional] Fontsize. Default is 14.
;                  $ParentGUI           - [optional] Parent GUI/Window to prevent multiple open windows in the taskbar for one program. Default is "".
; Notes .......: _GUIDisable($GUI, 0, 30) should be used before starting the MsgBox, so the MsgBox is better visible on top of your GUI. You also have to call _GUIDisable($GUI) afterwards.
; ===============================================================================================================================
Func _Metro_MsgBox($Flag, $Title, $Text, $mWidth = 600, $Fontsize = 12, $ParentGUI = "")
	Local $1stButton, $2ndButton, $3rdButton, $1stButtonText = "-", $2ndButtonText = "-", $3rdButtonText = "-", $Buttons_Count = 1
	Local $LabelSize = _StringSize($Text, $Fontsize / $Font_DPI_Ratio, 400, 0, "Arial", $mWidth - 30)
	Local $mHeight = $LabelSize[3] + 120
	Local $MsgBox_Form = _Metro_CreateGUI($Title, $mWidth, $mHeight, -1, -1, False, False, $ParentGUI)
	Local $MSGBOX_HOVER_REG = $MsgBox_Form[1]
	$MsgBox_Form = $MsgBox_Form[0]
	GUICtrlCreateLabel(" " & $Title, 2, 2, $mWidth - 4, 30, 0x0200, 0x00100000)
	GUICtrlSetBkColor(-1, _AlterBrightness($GUIThemeColor, 30))
	GUICtrlSetColor(-1, $FontThemeColor)
	_GUICtrlSetFont(-1, 12, 600, 0, "Arial")
	GUICtrlCreateLabel($Text, 15, 50, $LabelSize[2], $LabelSize[3], -1, 0x00100000)
	GUICtrlSetBkColor(-1, $GUIThemeColor)
	GUICtrlSetColor(-1, $FontThemeColor)
	_GUICtrlSetFont(-1, $Fontsize, 400, 0, "Arial")

	Switch $Flag
		Case 0;OK
			$Buttons_Count = 1
			$1stButtonText = "OK"
		Case 1;OK / Cancel
			$Buttons_Count = 2
			$1stButtonText = "OK"
			$2ndButtonText = "Cancel"
		Case 2;Abort / Retry / Ignore
			$Buttons_Count = 3
			$1stButtonText = "Abort"
			$2ndButtonText = "Retry"
			$3rdButtonText = "Ignore"
		Case 3;Yes / NO / Cancel
			$Buttons_Count = 3
			$1stButtonText = "Yes"
			$2ndButtonText = "No"
			$3rdButtonText = "Cancel"
		Case 4;Yes / NO
			$Buttons_Count = 2
			$1stButtonText = "Yes"
			$2ndButtonText = "No"
		Case 5; Retry / Cancel
			$Buttons_Count = 2
			$1stButtonText = "Retry"
			$2ndButtonText = "Cancel"
		Case 6; Cancel / Retry / Continue
			$Buttons_Count = 3
			$1stButtonText = "Cancel"
			$2ndButtonText = "Retry"
			$3rdButtonText = "Continue"
		Case Else
			$Buttons_Count = 1
			$1stButtonText = "OK"
	EndSwitch

	If ($Buttons_Count = 1) And ($mWidth < 180) Then MsgBox(16, "MetroUDF", "Error: Messagebox width has to be at least 180px for the selected message style/flag.")
	If ($Buttons_Count = 2) And ($mWidth < 240) Then MsgBox(16, "MetroUDF", "Error: Messagebox width has to be at least 240px for the selected message style/flag.")
	If ($Buttons_Count = 3) And ($mWidth < 360) Then MsgBox(16, "MetroUDF", "Error: Messagebox width has to be at least 360px for the selected message style/flag.")


	Local $1stButton_Left = ($mWidth - ($Buttons_Count * 100) - (($Buttons_Count - 1) * 20)) / 2
	Local $2ndButton_Left = $1stButton_Left + 120
	Local $3rdButton_Left = $2ndButton_Left + 120



	GUICtrlCreateLabel("", 2, $mHeight - 53, $1stButton_Left - 4, 50, -1, 0x00100000)
	GUICtrlCreateLabel("", $mWidth - $1stButton_Left + 2, $mHeight - 53, $1stButton_Left - 4, 50, -1, 0x00100000)

	Local $1stButton = _Metro_CreateButton($MSGBOX_HOVER_REG, $1stButtonText, $1stButton_Left, $mHeight - 50, 100, 36, $ButtonBKColor, $ButtonTextColor)
	Local $2ndButton = _Metro_CreateButton($MSGBOX_HOVER_REG, $2ndButtonText, $2ndButton_Left, $mHeight - 50, 100, 36, $ButtonBKColor, $ButtonTextColor)
	If $Buttons_Count < 2 Then GUICtrlSetState($2ndButton, 32)
	Local $3rdButton = _Metro_CreateButton($MSGBOX_HOVER_REG, $3rdButtonText, $3rdButton_Left, $mHeight - 50, 100, 36, $ButtonBKColor, $ButtonTextColor)
	If $Buttons_Count < 3 Then GUICtrlSetState($3rdButton, 32)
	GUISetState(@SW_SHOW)

	While 1
		_Metro_HoverCheck_Loop($MSGBOX_HOVER_REG, $MsgBox_Form)
		Local $nMsg = GUIGetMsg()
		Switch $nMsg
			Case -3, $1stButton
				_Metro_GUIDelete($MSGBOX_HOVER_REG, $MsgBox_Form)
				Return $1stButtonText
			Case $2ndButton
				_Metro_GUIDelete($MSGBOX_HOVER_REG, $MsgBox_Form)
				Return $2ndButtonText
			Case $3rdButton
				_Metro_GUIDelete($MSGBOX_HOVER_REG, $MsgBox_Form)
				Return $3rdButtonText
		EndSwitch
	WEnd
EndFunc   ;==>_Metro_MsgBox

#EndRegion Metro MsgBox===========================================================================================


#Region Metro Progressbar===========================================================================================
; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_CreateProgress
; Description ...: Creates a simple progressbar.
; Syntax ........: _Metro_CreateProgress($Left, $Top, $Width, $Height[, $EnableBorder = False[, $Backgroud_Color = $CB_Radio_Color[,
;                  $Progress_Color = $ButtonBKColor]]])
; Parameters ....: $Left                - Left pos.
;                  $Top                 - Top pos.
;                  $Width               - Width.
;                  $Height              - Height.
;                  $EnableBorder        - [optional] Enables a 1px border from each side for the progressbar. Default is False.
;                  $Backgroud_Color     - [optional] Background color. Default is $CB_Radio_Color.
;                  $Progress_Color      - [optional] Progress color. Default is $ButtonBKColor.
; Return values .: Array containing basic information about the progressbar that is required to set the % progress.
; ===============================================================================================================================
Func _Metro_CreateProgress($Left, $Top, $Width, $Height, $EnableBorder = False, $Backgroud_Color = $CB_Radio_Color, $Progress_Color = $ButtonBKColor)
	Local $Progress_Array[8]
	$Progress_Array[0] = GUICtrlCreatePic("", $Left, $Top, $Width, $Height)
	$Progress_Array[1] = $Width
	$Progress_Array[2] = $Height
	$Progress_Array[3] = StringReplace($Backgroud_Color, "0x", "0xFF")
	$Progress_Array[4] = StringReplace($Progress_Color, "0x", "0xFF")
	$Progress_Array[5] = StringReplace($CB_Radio_Hover_Color, "0x", "0xFF")
	$Progress_Array[7] = $EnableBorder

	;Set Colors
	Local $ProgressBGPen = _GDIPlus_PenCreate($Progress_Array[5], 2)

	;Create Graphics
	Local $Progress_Bitmap = _GDIPlus_BitmapCreateFromScan0($Width, $Height)
	Local $Button_GraphicContext = _GDIPlus_ImageGetGraphicsContext($Progress_Bitmap)

	;Set Progress BG color
	_GDIPlus_GraphicsClear($Button_GraphicContext, $Progress_Array[3])

	;Draw Progressbar border
	If $EnableBorder Then
		_GDIPlus_GraphicsDrawRect($Button_GraphicContext, 0, 0, $Width, $Height, $ProgressBGPen)
	EndIf
	;Release created objects
	_GDIPlus_GraphicsDispose($Button_GraphicContext)
	_GDIPlus_PenDispose($ProgressBGPen)

	;Create bitmap handles
	$Progress_Array[6] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Progress_Bitmap)

	;More cleanup
	_GDIPlus_BitmapDispose($Progress_Bitmap)

	;For GUI Resizing
	GUICtrlSetResizing($Progress_Array[0], 768)

	;Set Main Button Image visible
	_WinAPI_DeleteObject(GUICtrlSendMsg($Progress_Array[0], 0x0172, 0, $Progress_Array[6]))

	Return $Progress_Array
EndFunc   ;==>_Metro_CreateProgress

; #FUNCTION# ====================================================================================================================
; Name ..........: _Metro_SetProgress
; Description ...: Sets the progress in % of a created progressbar.
; Syntax ........: _Metro_SetProgress(Byref $Progress, $Percent)
; Parameters ....: $Progress            - Array of the progressbar that has been returned by _Metro_CreateProgress function.
;                  $Percent             - A value from 0-100. (In %)
; ===============================================================================================================================
Func _Metro_SetProgress(ByRef $Progress, $Percent)
	;Set Colors
	Local $ProgressBGPen = _GDIPlus_PenCreate($Progress[5], 2)
	Local $ProgressBGBrush = _GDIPlus_BrushCreateSolid($Progress[4])

	;Create Graphics
	Local $Progress_Bitmap = _GDIPlus_BitmapCreateFromScan0($Progress[1], $Progress[2])
	Local $Button_GraphicContext = _GDIPlus_ImageGetGraphicsContext($Progress_Bitmap)

	;Set Progress BG color
	_GDIPlus_GraphicsClear($Button_GraphicContext, $Progress[3])

	;Draw Progressbar
	If $Percent > 100 Then $Percent = 100
	If $Progress[7] Then
		Local $ProgressWidth = (($Progress[1] - 2) / 100) * $Percent
		_GDIPlus_GraphicsDrawRect($Button_GraphicContext, 0, 0, $Progress[1], $Progress[2], $ProgressBGPen)
		_GDIPlus_GraphicsFillRect($Button_GraphicContext, 1, 1, $ProgressWidth, $Progress[2] - 2, $ProgressBGBrush)
	Else
		Local $ProgressWidth = (($Progress[1]) / 100) * $Percent
		_GDIPlus_GraphicsFillRect($Button_GraphicContext, 0, 0, $ProgressWidth, $Progress[2], $ProgressBGBrush)
	EndIf
	;Release created objects
	_GDIPlus_GraphicsDispose($Button_GraphicContext)
	_GDIPlus_PenDispose($ProgressBGPen)
	_GDIPlus_BrushDispose($ProgressBGBrush)

	;Create bitmap handles
	Local $SetProgress = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Progress_Bitmap)

	;More cleanup
	_GDIPlus_BitmapDispose($Progress_Bitmap)

	;Set visible
	_WinAPI_DeleteObject(GUICtrlSendMsg($Progress[0], 0x0172, 0, $SetProgress))

	_WinAPI_DeleteObject($Progress[6])
	$Progress[6] = $SetProgress
EndFunc   ;==>_Metro_SetProgress
#EndRegion Metro Progressbar===========================================================================================


#Region Required_Funcs===========================================================================================
Func _GUICtrlSetFont($icontrolID, $iSize, $iweight = 400, $iattribute = 0, $sfontname = "", $iquality = 4)
	GUICtrlSetFont($icontrolID, $iSize / $Font_DPI_Ratio, $iweight, $iattribute, $sfontname, $iquality)
EndFunc   ;==>_GUICtrlSetFont

Func _SetFont_GetDPI()
	Local $a1[3]
	Local $iDPI, $iDPIRat, $Logpixelsy = 90, $hWnd = 0
	Local $hDC = DllCall("user32.dll", "long", "GetDC", "long", $hWnd)
	Local $aRet = DllCall("gdi32.dll", "long", "GetDeviceCaps", "long", $hDC[0], "long", $Logpixelsy)
	$hDC = DllCall("user32.dll", "long", "ReleaseDC", "long", $hWnd, "long", $hDC)
	$iDPI = $aRet[0]
	Select
		Case $iDPI = 0
			$iDPI = 96
			$iDPIRat = 94
		Case $iDPI < 84
			$iDPIRat = $iDPI / 105
		Case $iDPI < 121
			$iDPIRat = $iDPI / 96
		Case $iDPI < 145
			$iDPIRat = $iDPI / 95
		Case Else
			$iDPIRat = $iDPI / 94
	EndSelect
	$a1[0] = 2
	$a1[1] = $iDPI
	$a1[2] = $iDPIRat
	Return $a1
EndFunc   ;==>_SetFont_GetDPI

Func _ReduceMemory($i_PID = -1)
	If $i_PID <> -1 Then
		Local $ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $i_PID)
		$ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', $ai_Handle[0])
		DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $ai_Handle[0])
	Else
		$ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', -1)
	EndIf

	Return $ai_Return[0]
EndFunc   ;==>_ReduceMemory

Func _AlterBrightness($StartCol, $adjust, $Select = 7)
	Local $red = $adjust * (BitAND(1, $Select) <> 0) + BitAND($StartCol, 0xff0000) / 0x10000
	Local $grn = $adjust * (BitAND(2, $Select) <> 0) + BitAND($StartCol, 0x00ff00) / 0x100
	Local $blu = $adjust * (BitAND(4, $Select) <> 0) + BitAND($StartCol, 0x0000FF)
	Return "0x" & Hex(String(limitCol($red) * 0x10000 + limitCol($grn) * 0x100 + limitCol($blu)), 6)
EndFunc   ;==>_AlterBrightness
Func limitCol($cc)
	If $cc > 255 Then Return 255
	If $cc < 0 Then Return 0
	Return $cc
EndFunc   ;==>limitCol

Func _CreateBorder($guiW, $guiH, $bordercolor = 0xFFFFFF, $style = 1, $borderThickness = 1)
	If $style = 0 Then
		;#TOP#
		GUICtrlCreateLabel("", 0, 0, $guiW, $borderThickness)
		GUICtrlSetColor(-1, $bordercolor)
		GUICtrlSetBkColor(-1, $bordercolor)
		GUICtrlSetResizing(-1, 544)
		GUICtrlSetState(-1, 128)
		;#Bottom
		GUICtrlCreateLabel("", 0, $guiH - $borderThickness, $guiW, $borderThickness)
		GUICtrlSetColor(-1, $bordercolor)
		GUICtrlSetBkColor(-1, $bordercolor)
		GUICtrlSetResizing(-1, 576)
		GUICtrlSetState(-1, 128)
		;#Left
		GUICtrlCreateLabel("", 0, 1, $borderThickness, $guiH - 1)
		GUICtrlSetColor(-1, $bordercolor)
		GUICtrlSetBkColor(-1, $bordercolor)
		GUICtrlSetResizing(-1, 256 + 2)
		GUICtrlSetState(-1, 128)
		;#Right
		GUICtrlCreateLabel("", $guiW - $borderThickness, 1, $borderThickness, $guiH - 1)
		GUICtrlSetColor(-1, $bordercolor)
		GUICtrlSetBkColor(-1, $bordercolor)
		GUICtrlSetResizing(-1, 256 + 4)
		GUICtrlSetState(-1, 128)
	Else
		;#TOP#
		GUICtrlCreateLabel("", 1, 1, $guiW - 2, $borderThickness)
		GUICtrlSetColor(-1, $bordercolor)
		GUICtrlSetBkColor(-1, $bordercolor)
		GUICtrlSetResizing(-1, 544)
		GUICtrlSetState(-1, 128)
		;#Bottom
		GUICtrlCreateLabel("", 1, $guiH - $borderThickness - 1, $guiW - 2, $borderThickness)
		GUICtrlSetColor(-1, $bordercolor)
		GUICtrlSetBkColor(-1, $bordercolor)
		GUICtrlSetResizing(-1, 576)
		GUICtrlSetState(-1, 128)
		;#Left
		GUICtrlCreateLabel("", 1, 1, $borderThickness, $guiH - 2)
		GUICtrlSetColor(-1, $bordercolor)
		GUICtrlSetBkColor(-1, $bordercolor)
		GUICtrlSetResizing(-1, 256 + 2)
		GUICtrlSetState(-1, 128)
		;#Right
		GUICtrlCreateLabel("", $guiW - $borderThickness - 1, 1, $borderThickness, $guiH - 2)
		GUICtrlSetColor(-1, $bordercolor)
		GUICtrlSetBkColor(-1, $bordercolor)
		GUICtrlSetResizing(-1, 256 + 4)
		GUICtrlSetState(-1, 128)
	EndIf
EndFunc   ;==>_CreateBorder

Func _WinPos($ParentWin, $Win_Wi, $Win_Hi)
	Local $Win_SetPos[2]
	$Win_SetPos[0] = "-1"
	$Win_SetPos[1] = "-1"
	$Win_POS = WinGetPos($ParentWin)
	If Not @error Then
		$Win_SetPos[0] = ($Win_POS[0] + (($Win_POS[2] - $Win_Wi) / 2))
		$Win_SetPos[1] = ($Win_POS[1] + (($Win_POS[3] - $Win_Hi) / 2))
	EndIf
	Return $Win_SetPos
EndFunc   ;==>_WinPos
#EndRegion Required_Funcs===========================================================================================
