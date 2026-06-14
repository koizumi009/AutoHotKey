;===================================================================
; fvwm風ウィンドウ操作スクリプト マルチモニタ対応版
;  ※AutoHotkey 2.0.18で動作確認済
;  ショートカット一覧
;    Ctrl+Shift+Alt+i	ウィンドウ縦拡大
;    Ctrl+Shift+Alt+k	ウィンドウ横拡大
;    Ctrl+Shift+Alt+j	ウィンドウ全画面
;    Ctrl+Shift+Alt+←	ウィンドウ左寄せ
;    Ctrl+Shift+Alt+→	ウィンドウ右寄せ
;    Ctrl+Shift+Alt+↑	ウィンドウ上寄せ
;    Ctrl+Shift+Alt+↓	ウィンドウ下寄せ
;    Ctrl+←	仮想デスクトップ切り替え左
;    Ctrl+→	仮想デスクトップ切り替え右
;    Ctrl+↑	仮想デスクトップ切り替え左
;    Ctrl+↓	仮想デスクトップ切り替え右
;===================================================================
MyWin:=Map() ; 制御ウィンドウ連想配列
;===================================================================
; マウスポジションのモニタを取得する
;===================================================================
MyGetMonitor(){
  CoordMode "Mouse", "Screen"
  MouseGetPos &x, &y
  MonitorCount := MonitorGetCount()
  Loop MonitorCount
  {
    MonitorGetWorkArea(A_Index, &MonitorWorkAreaLeft, &MonitorWorkAreaTop, &MonitorWorkAreaRight, &MonitorWorkAreaBottom)
    if(x >= MonitorWorkAreaLeft AND x <= MonitorWorkAreaRight){
      if(y >= MonitorWorkAreaTop AND y <= MonitorWorkAreaBottom){
        ;モニタの左上とセンタの座標を求める
        if(MonitorWorkAreaLeft<MonitorWorkAreaRight){
          MonitorW:=MonitorWorkAreaRight-MonitorWorkAreaLeft
          CenterX:=MonitorWorkAreaLeft+(MonitorWorkAreaRight-MonitorWorkAreaLeft)/2
        }
        else{
          MonitorW:=Abs(MonitorWorkAreaLeft)-Abs(MonitorWorkAreaRight)
          CenterX:=MonitorWorkAreaLeft+(Abs(MonitorWorkAreaLeft)-Abs(MonitorWorkAreaRight))/2
        }
        if(MonitorWorkAreaTop<MonitorWorkAreaBottom){
          MonitorH:=MonitorWorkAreaBottom-MonitorWorkAreaTop
          CenterY:=MonitorWorkAreaTop+(MonitorWorkAreaBottom-MonitorWorkAreaTop)/2
        }
        else{
          MonitorH:=Abs(MonitorWorkAreaTop)-Abs(MonitorWorkAreaBottom)
          CenterY:=MonitorWorkAreaTop+(Abs(MonitorWorkAreaTop)-Abs(MonitorWorkAreaBottom))/2
        }
        Return MonitorWorkAreaLeft . " " . MonitorWorkAreaTop . " " . MonitorW . " " . MonitorH . " " . CenterX . " " . CenterY . " " . A_Index
      }
    }
  }
}
;===================================================================
; ウィンドウ管理中判定
;===================================================================
isMyWin(id){
  For key, value in MyWin
    if(key = id){
       return 1 ; 配列有
    }
  return 0 ; 配列無
}
;===================================================================
; メインルーチン
;===================================================================
^+!i::
^+!k::
^+!j::
^+!Left::
^+!Right::
^+!UP::
^+!DOWN::
{
  id := WinGetID("A")
  if(WinGetMinMax("ahk_id" id) = 1){ ; ウィンドウが最大化なら解除する
    WinRestore("ahk_id " id)
  }
  WinGetPos &x, &y, &w, &h, "A"
  String := MyGetMonitor()
  if(String = ""){
      return
  }
  Array := StrSplit(String, A_Space)
  MonitorX := Array[1]
  MonitorY := Array[2]
  MonitorW := Array[3]
  MonitorH := Array[4]
  CenterX  := Array[5]
  CenterY  := Array[6]
  MonitorNum := Array[7]
  if(isMyWin(id)=0){ ; ウィンドウが操作管理対象外の場合
    MyWin[id] := {} ; オブジェクト作成
    MyWin[id].x := x
    MyWin[id].y := y
    MyWin[id].w := w
    MyWin[id].h := h
    MyWin[id].m := MonitorNum
    Switch A_ThisHotkey
    {
      Case "^+!i": ;縦拡大
        if(MyWin[id].x+MyWin[id].w/2 < CenterX){ ;左
          WinMove MonitorX,MonitorY+4,MonitorW/2,MonitorH,"ahk_id " id
        }
        Else{                        ;右
          WinMove CenterX,MonitorY+4,MonitorW/2,MonitorH,"ahk_id " id
        }
      Case "^+!k": ;横拡大
        if(MyWin[id].y+MyWin[id].h/2 < CenterY){ ;上
          WinMove MonitorX,MonitorY+4,MonitorW,MonitorH/2,"ahk_id " id
        }
        Else{                        ;下
          WinMove MonitorX,CenterY+4,MonitorW,MonitorH/2,"ahk_id " id
        }
      Case "^+!j": ;全画面
        WinMove MonitorX,MonitorY+4,MonitorW,MonitorH,"ahk_id " id
      Case "^+!Left":
        WinMove MonitorX,MonitorY+4,MonitorW/2,MonitorH,"ahk_id " id
      Case "^+!Right":
        WinMove CenterX,MonitorY+4,MonitorW/2,MonitorH,"ahk_id " id
      Case "^+!UP":
        WinMove MonitorX,MonitorY+4,MonitorW,MonitorH/2,"ahk_id " id
      Case "^+!DOWN":
        WinMove MonitorX,CenterY+4,MonitorW,MonitorH/2,"ahk_id " id
    }
  }
  Else{ ;ウィンドウが操作管理対象の場合
    if(A_ThisHotkey = "^+!i" or A_ThisHotkey = "^+!k" or A_ThisHotkey = "^+!j"){
      if(MonitorNum != MyWin[id].m){ ; モニタ番号が変わった
        MyWin[id].x := x
        MyWin[id].y := y
        MyWin[id].w := w
        MyWin[id].h := h
        MyWin[id].m := MonitorNum
        Switch A_ThisHotkey
        {
          Case "^+!i": ;縦拡大
            if(MyWin[id].x+MyWin[id].w/2 < CenterX){ ;左
          WinMove MonitorX,MonitorY+4,MonitorW/2,MonitorH,"ahk_id " id
        }
        Else{                        ;右
          WinMove CenterX,MonitorY+4,MonitorW/2,MonitorH,"ahk_id " id
            }
          Case "^+!k": ;横拡大
            if(MyWin[id].y+MyWin[id].h/2 < CenterY){ ;上
              WinMove MonitorX,MonitorY+4,MonitorW,MonitorH/2,"ahk_id " id
            }
            Else{                        ;下
              WinMove MonitorX,CenterY+4,MonitorW,MonitorH/2,"ahk_id " id
            }
          Case "^+!j":                   ;全画面
            WinMove MonitorX,MonitorY+4,MonitorW,MonitorH,"ahk_id " id
        }
      }
      Else{ ; モニタ番号が同じ
        ;元のポジションに戻してウィンドウを忘れる
        WinMove MyWin[id].x,MyWin[id].y,MyWin[id].w,MyWin[id].h,"ahk_id " id
	MyWin.Delete(id) ; 連想配列削除
      }
    }
    Else{ ; 方向キーの場合
      Switch A_ThisHotkey
      {
        Case "^+!Left":
          WinMove MonitorX,MonitorY+4,MonitorW/2,MonitorH,"ahk_id " id
        Case "^+!Right":
          WinMove CenterX,MonitorY+4,MonitorW/2,MonitorH,"ahk_id " id
        Case "^+!UP":
          WinMove MonitorX,MonitorY+4,MonitorW,MonitorH/2,"ahk_id " id
        Case "^+!DOWN":
          WinMove MonitorX,CenterY+4,MonitorW,MonitorH/2,"ahk_id " id
      }
    }
  }
  return
}
;拡張デスクトップの切り替え
^Left::#^Left
^Right::#^Right
^Up::#^Left
^Down::#^Right
; ============================================
; Emacs-like Keybindings for Wiki.js
; AutoHotkey v2
; ============================================

#HotIf WinActive("Wiki.js") || WinActive("ahk_exe notepad.exe")

; --------------------------------------------
; Kill-ring / Yank / Yank-pop
; --------------------------------------------
global KillRing := []
global KillIndex := 1
global LastCommand := ""

AddKill(text) {
    global KillRing, LastCommand
    if (LastCommand = "kill" && KillRing.Length > 0)
        KillRing[1] := KillRing[1] . text
    else
        KillRing.InsertAt(1, text)
    LastCommand := "kill"
}

CopyText() {
    A_Clipboard := ""
    Send "^c"
    if !ClipWait(0.3)
        return ""
    return A_Clipboard
}

ResetCommand() {
    global LastCommand
    LastCommand := ""
}

; --------------------------------------------
; Kill 系（mark-set / C-w は削除）
; --------------------------------------------
^k::{ ; 行末まで kill
    Send "+{End}"
    text := CopyText()
    if (text != "")
        AddKill(text)
    Send "{Delete}"
}

!d::{ ; 単語 kill
    Send "^+{Right}"
    text := CopyText()
    if (text != "")
        AddKill(text)
    Send "{Delete}"
}

!Backspace::{ ; 前の単語 kill
    Send "^+{Left}"
    text := CopyText()
    if (text != "")
        AddKill(text)
    Send "{Delete}"
}

; --------------------------------------------
; Yank 系
; --------------------------------------------
^y::{ ; yank
    global KillRing, KillIndex, LastCommand
    if (KillRing.Length = 0)
        return
    SendText KillRing[KillIndex]
    LastCommand := "yank"
}

!y::{ ; yank-pop
    global KillRing, KillIndex, LastCommand
    if (LastCommand != "yank")
        return
    KillIndex := (KillIndex >= KillRing.Length) ? 1 : KillIndex + 1
    Send "^z"
    SendText KillRing[KillIndex]
    LastCommand := "yank"
}

; --------------------------------------------
; Emacs-like Cursor / Edit Operations
; --------------------------------------------
^f::{
    ResetCommand()
    Send "{Right}"
}

^b::{
    ResetCommand()
    Send "{Left}"
}

^n::{
    ResetCommand()
    Send "{Down}"
}

^p::{
    ResetCommand()
    Send "{Up}"
}

^a::{
    ResetCommand()
    Send "{Home}"
}

^e::{
    ResetCommand()
    Send "{End}"
}

^d::{
    ResetCommand()
    Send "{Delete}"
}

^r::{
    ResetCommand()
    Send "^f"
}

^/::{
    ResetCommand()
    Send "^z"
}

^g::{
    ResetCommand()
    Send "{Esc}"
}

; ---- C-m = Enter ----
^m::{
    ResetCommand()
    SendEvent "{Enter}"
}

; ---- M-< / M-> ----
!<::{
    ResetCommand()
    Send "^Home"
}

!>::{
    ResetCommand()
    Send "^End"
}
; ---- C-v = PageDown（Emacs と同じ）----
^v::{
    ResetCommand()
    Send "{PgDn}"
}

#HotIf
