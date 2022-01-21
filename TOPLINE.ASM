page 66,132

;
; Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
;
; This is a component of the ProDoor System.
; Do not distribute modified versions without my permission.
; Do not remove or alter this notice or any other copyright notice.
; If you use this in your own program you must distribute source code.
; Do not use any of this in a commercial product.
;

; ---------------------------------------------------------------------------
;  PRONS - NoScroll -
;     keep the top half of the screen from scrolling away
;     used by ProDOOR during file transfers.  it also preserves
;     COM port interrupt vectors and will drop carrier after
;     a specified number of clock ticks.
;
; This program works under TaskView and other environments that do
; not pass DOS or ANSI outputs to BIOS.
;
; Written: 30-dec-87 (rev. 20-jan-89)
;

; ---------------------------------------------------------------------------
;   Macros
;

; set interrupt vector to ds:dx
setdsdx  macro vect,src
   mov  ah,25h
   mov  al,vect
   int 21h
endm

; store vector into dword
getesbx  macro vect,dest
   mov  ah,35h
   mov  al,vect
   int  21h     ;changes es
endm


; ---------------------------------------------------------------------------
;
code segment
                assume  cs:code,ds:nothing,es:nothing,ss:nothing

                org     80h
tailLength      db      ?
tail            db      ?

                org     100h
entryPoint:     jmp     startup

; ---------------------------------------------------------------------------
;   Working storage
;
copyright       db      13,10,'ProNS (C) 1988, 1989 S.H.Smith; v3.1 07-31-89'
                db      13,10,26

old10Vector     dd      0               ;chain to original video handler
retp3           dd      0               ;return-to-user pointer, videoTTY

old21Vector     dd      0               ;chain to original dos handler
retp2           dd      0               ;return-to-user pointer, dosWrite
retp1           dd      0               ;return-to-user pointer, dosConOut


lastLine        db      24              ;last line of screen (0=first)

splitLine       db      18              ;line where the screen is split
                                        ;(lastLine-scrollLines-1)
    
scrollLines     db      0               ;lines in scrolling region

defaltLines     = 7                     ;default lines in scrolling region

scrollColor     = 7                     ;display attrib in scrolling region


; ---------------------------------------------------------------------------
;   New handler for video interrupts

new10:          cmp     ah,14
                jz      videoTTY

                cmp     ah,6
                jz      videoScroll

;               cmp     ah,2
;               jz      videoSetPos

useOld10:       jmp     old10Vector     ;chain to other interrupts
  
              
; ---------------------------------------------------------------------------
; we have a set cursor position request; clip it to the scrolling area only
; (just let this happen; makes PCKERMIT and others look better)
;
;videoSetPos:    cmp     dh,splitLine
;                jge     useOld10
;
;                mov     dh,splitLine
;                jmp     useOld10


; ---------------------------------------------------------------------------
; we have a scroll request; clip it to the scrolling area only
;
videoScroll:    cmp     ch,splitLine
                jge     useOld10

                mov     ch,splitLine
                jmp     useOld10


; --------------------------------------------------------------------------
; process video TTY calls
;
videoTTY:       cmp     al,10           ;linefeed?
                jnz     useOld10


; ---------------------------------------------------------------------------
; we have a linefeed request; if it will cause scrolling, 
; make sure the fixed lines stay where they are
;
videoLineFeed:  push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    si
                push    di

                mov     ah,3            ;get cursor position
                mov     bh,0
                int     10h
                cmp     dh,lastLine
                jz      vTrapScroll
;
; won't cause scroll, restore environ and pass back to bios
;
                pop     di
                pop     si
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                jmp     useOld10

;
; the linefeed will cause scroll - scroll manually instead
;
vTrapScroll:    mov     ah,6            ;scroll up
                mov     al,1            ;lines=1
                mov     bh,scrollColor  

                mov     cl,0
                mov     ch,splitLine    ;top-left of scroll region

                mov     dl,79
                mov     dh,lastLine     ;bottom-right of scroll region

                int     10h

                pop     di
                pop     si
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     word ptr retp3  ;return to user code
                pop     word ptr retp3+2
                popf
                clc
                jmp     retp3



; ===========================================================================
;   New handler for dos interrupts

new21:          cmp     ah,2
                jz      dosConOut

                cmp     ah,40h
                jz      dosWrite

useOld21:       jmp     old21Vector     ;chain to other interrupts

             

; ===========================================================================
; we have a write to file handle-1 request.  change it into repeated
; calls to dosConOut so linefeeds will be trapped
;
dosWrite:       cmp     bx,1            ;stdout
                jz      trapWrite
                cmp     bx,2            ;stderr
                jz      trapWrite
                jmp     useOld21

trapWrite:      pop     word ptr retp2  ;pointer to user code
                pop     word ptr retp2+2
                popf

                push    bx
                push    cx
                push    dx
                push    ds
                mov     bx,dx

writeChar:      cmp     cx,0
                jz      endWrite

                push    bx
                push    cx
                mov     dl,[bx]
                mov     ah,2            ;use dos dosConOut function
                int     21h             ;on each char in the buffer
                pop     cx
                pop     bx

                inc     bx
                dec     cx
                jmp     writeChar

endWrite:       pop     ds
                pop     dx
                pop     cx
                pop     bx
                mov     ax,cx           ;return as though all bytes written
                clc
                jmp     retp2


; ===========================================================================
; process console output calls
;
dosConOut:      cmp     dl,10           ;linefeed?
                jnz     useOld21


; ---------------------------------------------------------------------------
; we have a linefeed request; if it will cause scrolling, 
; make sure the fixed lines stay where they are
;
dosLineFeed:    push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    si
                push    di

                mov     ah,3            ;get cursor position
                mov     bh,0
                int     10h
                cmp     dh,lastLine
                jz      dTrapScroll
;
; won't cause scroll, restore environ and pass back to dos
;
                pop     di
                pop     si
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                jmp     useOld21

;
; the linefeed will cause scroll - scroll manually instead
;
dTrapScroll:    mov     ah,6            ;scroll up
                mov     al,1            ;lines=1
                mov     bh,scrollColor  

                mov     cl,0
                mov     ch,splitLine    ;top-left of scroll region

                mov     dl,79
                mov     dh,lastLine     ;bottom-right of scroll region

                int     10h

                pop     di
                pop     si
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     word ptr retp1  ;return to user code
                pop     word ptr retp1+2
                popf
                clc
                jmp     retp1



; ===========================================================================
;  startup entry point
; is noScroll already in memory?
;
startup:        getesbx  10h            ;es:bx <- original cs
                mov     bx,offset copyright

checkPresent:   mov     al,cs:[bx]      ;get next byte from copyright message
                cmp     al,26           ;end of message?
                jz      unInstall       ;already present if so

                cmp     al,es:[bx]      ;compare next byte to handler in chain
                jz      checkNext
                jmp     newInstall      ;new installation if mismatch

checkNext:      inc     bx              ;got a match, try the next char
                jmp     checkPresent


; ---------------------------------------------------------------------------
; already in memory - uninstall and exit
;
                assume  ds:nothing
unInstall:
                lds     dx,es:old10Vector
                setdsdx 10h

                lds     dx,es:old21Vector
                setdsdx 21h
;
; deAllocate the memory used by ProNS
;
                push    es
                mov     es,es:2ch       ;dealloc the tsr's environment segment
                mov     ah,49h          
                int     21h

                pop     es              ;dealloc the tsr's code segment
                mov     ah,49h          
                int     21h

                mov     ax,4ch          ;terminate process
                int     21h


; ---------------------------------------------------------------------------
; install noScroll
;
newInstall:
                xor     ch,ch
                mov     cl,tailLength
                lea     si,tail

nextTail:
                jcxz    checkEga

                lodsb
                dec cx

                cmp     al,'0'
                jl      nextTail
                cmp     al,'9'
                jg      nextTail
                sub     al,'0'

                mov     ah,scrollLines
                add     ah,ah           ;*2
                add     ah,ah           ;*4
                add     ah,scrollLines  ;*5
                add     ah,ah           ;*10
                add     al,ah
                mov     scrollLines,al
                jmp     nextTail

checkEga:
                mov     ax,40h
                mov     es,ax           ;is ega present and active?
                test    byte ptr es:[87h],8
                jnz     notEga

                mov     ax,01130h
                xor     bx,bx           ;get last screen line
                mov     dl,lastLine     ;default to normal setting
                int     10h
                mov     lastLine,dl

notEga:
                ;verify that scrollLines is in range, use default if not
                mov     ah,scrollLines
                cmp     ah,lastLine
                jg      defaultScroll
                cmp     ah,2
                jle     defaultScroll
                jmp     scrollOK

defaultScroll:
                mov     ah,defaltLines

scrollOK:
                mov     scrollLines,ah
                mov     al,lastLine
                sub     al,ah
                inc     al
                mov     splitLine,al

                getesbx  10h
                mov  word ptr [old10Vector+0],bx
                mov  word ptr [old10Vector+2],es

                getesbx  21h
                mov  word ptr [old21Vector+0],bx
                mov  word ptr [old21Vector+2],es

;
; prepare screen
; make sure the original cursor is below the split line
;
prepare_scr:    mov     ah,2            ;linefeed once
                mov     dl,10
                int     21h
 
                mov     ah,3            ;get cursor position
                mov     bh,0
                int     10h
                cmp     dh,splitLine
                jl      prepare_scr
;
; make sure the original cursor line is above the split line
;
                xor     ch,ch
                mov     cl,scrollLines
                dec     cl
                dec     cl

moveDown:       mov     ah,2
                mov     dl,10
                push    cx
                int     21h
                pop     cx
                loop    moveDown

                mov     ah,2            ;set cursor position
                mov     bh,0
                mov     dh,splitLine
                mov     dl,0
                int     10h

;
; vector in the new handler
;
                assume  ds:code
                push    cs
                pop     ds
                
                mov     dx,offset new10
                setdsdx 10h

                mov     dx,offset new21
                setdsdx 21h

                mov     dx,offset startup       ;last resident byte
                int     27h                     ;terminate and stay resident

code ends
                end entryPoint

