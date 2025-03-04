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
    If (WinProcess == "qutebrowser.exe" || WinProcess == "WindowsTerminal.exe")
    {
      WinSet, Style, ^0xC40000, %WinTitle%
    }
  }
}

^#q::
  If Transparent := !Transparent
  {
    WinSet, Transparent, 0, ahk_class Shell_TrayWnd
  }
  Else
  {
    WinSet, Transparent, 255, ahk_class Shell_TrayWnd
    WinSet, TransColor, OFF, ahk_class Shell_TrayWnd
    WinSet, Transparent, OFF, ahk_class Shell_TrayWnd
    WinSet, Redraw,, ahk_class Shell_TrayWnd
  }
  Return

^#e::
  WinSet, Style, ^0xC40000, A
