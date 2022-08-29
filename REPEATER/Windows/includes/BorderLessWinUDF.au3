#include-once
#include <WinAPIGdi.au3>
Global $GLOBAL_MAIN_GUI, $Win_Min_ResizeX = 145, $Win_Min_ResizeY = 45

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUI_EnableDragAndResize
; Compatibility .: Windows 7 and above. Not tested on XP.
; Description ...: Removes the Borders of a GUI, allows drag and resize while keeping the AeroSnap features of Windows still working with the GUI
; Warning .......: Can only be called for one GUI, if you call if for a second GUI, you have to call _GUI_DragAndResizeUpdate($Form1) it for the first GUI after closing the second GUI.
; Syntax ........: _GUI_EnableDragAndResize($mGUI, $GUI_WIDTH, $GUI_HEIGHT [, $Min_ResizeX = $Win_Min_ResizeX[, $Min_ResizeY = $Win_Min_ResizeY[,
;                  $AddShadowEffect = True]]])
; Parameters ....: $mGUI                - Handle to your GUI.
;                  $GUI_WIDTH           - The width of the GUI. (Required to fix the wrong size after removing borders)
;                  $GUI_HEIGHT          - The height of the GUI. (Required to fix the wrong size after removing borders)
;                  $Min_ResizeX         - [optional] Min size of the GUI. Default is 145
;                  $Min_ResizeY         - [optional] Max size of the GUI. Default is 45
;				   $Resize				- [optional] Define if the window can be maximized and resized, default false
;                  $AddShadowEffect    - [optional] Adds shadow effect that looks like a thin border. Works only with Aero-Effects enabled. Default is False
; Author ........: BB_19
; Credits .......: https://www.autoitscript.com/wiki/Moving_and_Resizing_PopUp_GUIs
; Example .......: _GUI_EnableDragAndResize($Form1,300,200)
; ===============================================================================================================================
Func _GUI_EnableDragAndResize($mGUI, $GUI_WIDTH, $GUI_HEIGHT, $Min_ResizeX = $Win_Min_ResizeX, $Min_ResizeY = $Win_Min_ResizeY,$Resize = False, $AddShadowEffect = False)
	Global $GLOBAL_MAIN_GUI = $mGUI, $Win_Min_ResizeX = $Min_ResizeX, $Win_Min_ResizeY = $Min_ResizeY
	If $Resize Then
		GUIRegisterMsg(0x0024, "INTERNAL_WM_GETMINMAXINFO") ; For GUI size limits
		GUIRegisterMsg(0x0084, "INTERNAL_WM_NCHITTEST") ; For resizing and to allow doubleclick to maximize and drag on the upper GUI.
	EndIf
	GUIRegisterMsg(0x0083, "INTERNAL_WM_NCCALCSIZE") ; To Prevent window border from drawing
	GUIRegisterMsg(0x0201, "INTERNAL_WM_LBUTTONDOWN") ; For drag/GUI moving. Disable this if you want to only a specific the area for dragging.(By using labels with $GUI_WS_EX_PARENTDRAG)
	GUIRegisterMsg(0x0005, "INTERNAL_WM_SIZING") ; Fixing the maxmized position (otherwise we have a -7px margin on all sides due to the missing border)
	GUIRegisterMsg(0x0086, "INTERNAL_WM_NCACTIVATE") ; Prevent Windowframe
	If $AddShadowEffect Then
		Local $tMargs = DllStructCreate("int cxLeftWidth;int cxRightWidth;int cyTopHeight;int cyBottomHeight")
		DllStructSetData($tMargs, 1, 1)
		DllStructSetData($tMargs, 2, 1)
		DllStructSetData($tMargs, 3, 1)
		DllStructSetData($tMargs, 4, 1)
		DllCall("dwmapi.dll", "int", "DwmExtendFrameIntoClientArea", "hwnd", $mGUI, "ptr", DllStructGetPtr($tMargs))
	EndIf
	WinMove($mGUI, "", Default, Default, $GUI_WIDTH, $GUI_HEIGHT);Update Size and
EndFunc   ;==>_GUI_EnableDragAndResize


;Update drag and resize for your first GUI after using _GUI_EnableDragAndResize on a second GUI.
Func _GUI_DragAndResizeUpdate($mGUI, $Min_ResizeX = $Win_Min_ResizeX, $Min_ResizeY = $Win_Min_ResizeY)
	Global $GLOBAL_MAIN_GUI = $mGUI, $Win_Min_ResizeX = $Min_ResizeX, $Win_Min_ResizeY = $Min_ResizeY
	GUIRegisterMsg(0x0024, "INTERNAL_WM_GETMINMAXINFO")
	GUIRegisterMsg(0x0084, "INTERNAL_WM_NCHITTEST")
	GUIRegisterMsg(0x0083, "INTERNAL_WM_NCCALCSIZE")
	GUIRegisterMsg(0x0201, "INTERNAL_WM_LBUTTONDOWN")
	GUIRegisterMsg(0x0005, "INTERNAL_WM_SIZING")
	GUIRegisterMsg(0x0086, "INTERNAL_WM_NCACTIVATE")
EndFunc   ;==>_GUI_EnableDragAndResizeUpdate

;Prevent Borders from redrawing when window goes inactive
Func INTERNAL_WM_NCACTIVATE($hWnd, $iMsg, $wParam, $lParam)
	If ($hWnd = $GLOBAL_MAIN_GUI) Then Return -1
EndFunc   ;==>INTERNAL_WM_NCACTIVATE

;Fix maximized position
Func INTERNAL_WM_SIZING($hWnd, $iMsg, $wParam, $lParam)
	If ($hWnd = $GLOBAL_MAIN_GUI) Then
		If (WinGetState($GLOBAL_MAIN_GUI) = 47) Then
			Local $WrkSize = _GetDesktopWorkArea($GLOBAL_MAIN_GUI)
			Local $aWinPos = WinGetPos($GLOBAL_MAIN_GUI)
			_WinAPI_SetWindowPos($GLOBAL_MAIN_GUI, $HWND_TOP, $aWinPos[0] - 1, $aWinPos[1] - 1, $WrkSize[2], $WrkSize[3], $SWP_NOREDRAW)
		EndIf
	EndIf
EndFunc   ;==>INTERNAL_WM_SIZING

; Set min and max GUI sizes
Func INTERNAL_WM_GETMINMAXINFO($hWnd, $iMsg, $wParam, $lParam)
	$tMinMax = DllStructCreate("int;int;int;int;int;int;int;int;int;dword", $lParam)
	Local $WrkSize = _GetDesktopWorkArea($GLOBAL_MAIN_GUI)
	;Prevent Windows from misplacing the GUI when maximized, due to missing borders.
	DllStructSetData($tMinMax, 3, $WrkSize[2])
	DllStructSetData($tMinMax, 4, $WrkSize[3])
	DllStructSetData($tMinMax, 5, $WrkSize[0]+1)
	DllStructSetData($tMinMax, 6, $WrkSize[1]+1)
	;Min Size limits
	DllStructSetData($tMinMax, 7, $Win_Min_ResizeX)
	DllStructSetData($tMinMax, 8, $Win_Min_ResizeY)
	Return 0
EndFunc   ;==>INTERNAL_WM_GETMINMAXINFO

;Stop drawing GUI Borders
Func INTERNAL_WM_NCCALCSIZE($hWnd, $Msg, $wParam, $lParam)
	If $hWnd = $GLOBAL_MAIN_GUI Then
		Return 0
	EndIf
	Return 'GUI_RUNDEFMSG'
EndFunc   ;==>INTERNAL_WM_NCCALCSIZE

;Set mouse cursor for resizing etc. / Allow the upper GUI (40 pixel from top) to act as a control bar (doubleclick to maximize, move gui around..)
Func INTERNAL_WM_NCHITTEST($hWnd, $uMsg, $wParam, $lParam)
	If ($hWnd = $GLOBAL_MAIN_GUI) Then
		Local $iSide = 0, $iTopBot = 0, $CurSorInfo

		Local $mPos = MouseGetPos()
		Local $aWinPos = WinGetPos($GLOBAL_MAIN_GUI)
		Local $curInf = GUIGetCursorInfo($GLOBAL_MAIN_GUI)

		;Check if Mouse is over Border, Margin = 5
		If Not @error Then
			If $curInf[0] < 5 Then $iSide = 1
			If $curInf[0] > $aWinPos[2] - 5 Then $iSide = 2
			If $curInf[1] < 5 Then $iTopBot = 3
			If $curInf[1] > $aWinPos[3] - 5 Then $iTopBot = 6
			$CurSorInfo = $iSide + $iTopBot
		Else
			$CurSorInfo = 0
		EndIf

		;Set position for drag and doubleclick to maximize
		$xMIN = $aWinPos[0] + 4
		$xMAX = $aWinPos[0] + $aWinPos[2] - 4
		$yMIN = $aWinPos[1] + 4
		$yMAX = $aWinPos[1] + 40

		If ($mPos[0] >= $xMIN) And ($mPos[0] <= $xMAX) And ($mPos[1] >= $yMIN) And ($mPos[1] <= $yMAX) Then
			GUISetCursor(2, 1)
			Return 2; Return $HTCAPTION if mouse is within the position for drag + doubleclick to maximize
		EndIf

		If Not (WinGetState($GLOBAL_MAIN_GUI) = 47) Then
			;Set resize cursor and return the correct $HT for gui resizing
			If ($curInf[4] < 8) Then
				Local $Return_HT = 2, $Set_Cursor = 2
				Switch $CurSorInfo
					Case 1
						$Set_Cursor = 13
						$Return_HT = 10
					Case 2
						$Set_Cursor = 13
						$Return_HT = 11
					Case 3
						$Set_Cursor = 11
						$Return_HT = 12
					Case 4
						$Set_Cursor = 12
						$Return_HT = 13
					Case 5
						$Set_Cursor = 10
						$Return_HT = 14
					Case 6
						$Set_Cursor = 11
						$Return_HT = 15
					Case 7
						$Set_Cursor = 10
						$Return_HT = 16
					Case 8
						$Set_Cursor = 12
						$Return_HT = 17
				EndSwitch
				GUISetCursor($Set_Cursor, 1)
				If Not ($Return_HT = 2) Then Return $Return_HT
			EndIf
		EndIf
	EndIf
	Return 'GUI_RUNDEFMSG'
EndFunc   ;==>INTERNAL_WM_NCHITTEST

; Allow drag with mouse left button down
Func INTERNAL_WM_LBUTTONDOWN($hWnd, $iMsg, $wParam, $lParam)
	If ($hWnd = $GLOBAL_MAIN_GUI) Then
		If Not (WinGetState($GLOBAL_MAIN_GUI) = 47) Then
			Local $aCurInfo = GUIGetCursorInfo($GLOBAL_MAIN_GUI)
			If ($aCurInfo[4] = 0) Then ; Mouse not over a control
				DllCall("user32.dll", "int", "ReleaseCapture")
				DllCall("user32.dll", "long", "SendMessage", "hwnd", $GLOBAL_MAIN_GUI, "int", 0x00A1, "int", 2, "int", 0)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>INTERNAL_WM_LBUTTONDOWN


; #FUNCTION# ====================================================================================================================
; Name ..........: _GetDesktopWorkArea
; Description ...: Calculate the desktop workarea for a specific window to maximize it. Supports multi display and taskbar detection.
; Syntax ........: _GetDesktopWorkArea($hWnd)
; Parameters ....: $hWnd                - Handle to the window.
; Return values .: Array in following format:
;                : [0] = X-Pos for maximizing
;				 : [1] = Y-Pos for maximizing
;                : [2] = Max. Width
;				 : [3] = Max. Height
; Author ........: BB_19
; Note ..........: The x/y position is not the real position of the window if you have multi display. It is just for setting the maximize info for WM_GETMINMAXINFO
; ===============================================================================================================================
Func _GetDesktopWorkArea($hWnd)

	Local $MonSizePos[4], $MonNumb = 1
	$MonSizePos[0] = 0
	$MonSizePos[1] = 0
	$MonSizePos[2] = @DesktopWidth
	$MonSizePos[3] = @DesktopHeight

	;Get Monitors
	Local $aPos, $MonList = _WinAPI_EnumDisplayMonitors()
	If @error Then Return $MonSizePos

	If IsArray($MonList) Then
		ReDim $MonList[$MonList[0][0] + 1][5]
		For $i = 1 To $MonList[0][0]
			$aPos = _WinAPI_GetPosFromRect($MonList[$i][1])
			For $j = 0 To 3
				$MonList[$i][$j + 1] = $aPos[$j]
			Next
		Next
	EndIf

	;Check on which monitor our window is
	Local $GUI_Monitor = _WinAPI_MonitorFromWindow($hWnd)

	;Check on which monitor the taskbar is
	Local $TaskbarMon = _WinAPI_MonitorFromWindow(WinGetHandle("[CLASS:Shell_TrayWnd]"))

	;Write the width and height info of the correct monitor into an array
	For $iM = 1 To $MonList[0][0] Step +1
		If $MonList[$iM][0] = $GUI_Monitor Then
			$MonSizePos[0] = 0
			$MonSizePos[1] = 0
			$MonSizePos[2] = $MonList[$iM][3]
			$MonSizePos[3] = $MonList[$iM][4]
			$MonNumb = $iM
		EndIf
	Next

	;Check if Taskbar autohide is enabled, if so then we will remove 1px from the correct side so that the taskbar will reapear when moving mouse to the side
	Local $TaskBarAH = DllCall("shell32.dll", "int", "SHAppBarMessage", "int", 0x00000004, "ptr*", 0)
	If Not @error Then
		$TaskBarAH = $TaskBarAH[0]
	Else
		$TaskBarAH = 0
	EndIf


	;Check if Taskbar is on this Monitor, if so, then recalculate the position, max. width and height of the WorkArea
	If $TaskbarMon = $GUI_Monitor Then
		$TaskBarPos = WinGetPos("[CLASS:Shell_TrayWnd]")
		If @error Then Return $MonSizePos

		;Win 7 classic theme compatibility
		If ($TaskBarPos[0] = $MonList[$MonNumb][1] - 2) Or ($TaskBarPos[1] = $MonList[$MonNumb][2] - 2) Then
			$TaskBarPos[0] = $TaskBarPos[0] + 2
			$TaskBarPos[1] = $TaskBarPos[1] + 2
			$TaskBarPos[2] = $TaskBarPos[2] - 4
			$TaskBarPos[3] = $TaskBarPos[3] - 4
		EndIf
		If ($TaskBarPos[0] = $MonList[$MonNumb][1] - 2) Or ($TaskBarPos[1] = $MonList[$MonNumb][2] - 2) Then
			$TaskBarPos[0] = $TaskBarPos[0] + 2
			$TaskBarPos[1] = $TaskBarPos[1] + 2
			$TaskBarPos[2] = $TaskBarPos[2] - 4
			$TaskBarPos[3] = $TaskBarPos[3] - 4
		EndIf


		;Recalc width/height and pos
		If $TaskBarPos[2] = $MonSizePos[2] Then
			If $TaskBarAH = 1 Then
				If ($TaskBarPos[1] > 0) Then
					$MonSizePos[3] -= 1
				Else
					$MonSizePos[1] += 1
					$MonSizePos[3] -= 1
				EndIf
				Return $MonSizePos
			EndIf
			$MonSizePos[3] = $MonSizePos[3] - $TaskBarPos[3]
			If ($TaskBarPos[0] = $MonList[$MonNumb][1]) And ($TaskBarPos[1] = $MonList[$MonNumb][2]) Then $MonSizePos[1] = $TaskBarPos[3]
		Else
			If $TaskBarAH = 1 Then
				If ($TaskBarPos[0] > 0) Then
					$MonSizePos[2] -= 1
				Else
					$MonSizePos[0] += 1
					$MonSizePos[2] -= 1
				EndIf
				Return $MonSizePos
			EndIf
			$MonSizePos[2] = $MonSizePos[2] - $TaskBarPos[2]
			If ($TaskBarPos[0] = $MonList[$MonNumb][1]) And ($TaskBarPos[1] = $MonList[$MonNumb][2]) Then $MonSizePos[0] = $TaskBarPos[2]
		EndIf
	EndIf
	Return $MonSizePos
EndFunc   ;==>_GetDesktopWorkArea

