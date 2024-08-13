; Registers a hook which is run whenever a new non-X11 Window
; is activated. If that window is 'firefox', remove its window
; decorations
;
; Needs to be executed before any hotkeys are set

SetBatchLines, -1
Process, Priority,, High

Gui +LastFound
hWnd := WinExist()

DllCall( "RegisterShellHookWindow", UInt,hWnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )
Return

ShellMessage( wParam,lParam )
{
  If ( wParam = 1 ) ;  HSHELL_WINDOWCREATED := 1
  {
    WinTitle := lParam = "A" ? "A" : "ahk_id " . lParam
    WinGet, WinProcess, ProcessName, %WinTitle%
    If (WinProcess == "firefox.exe" || WinProcess == "WindowsTerminal.exe")
    {
      WinSet, Style, ^0xC40000,  %WinTitle%
    }
  }
}
