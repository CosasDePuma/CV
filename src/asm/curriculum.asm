[BITS 16]

    JMP _start              ; Entrypoint

; ================================================
;   CONSTANTS
; ================================================

; Screen
width               EQU 320
height              EQU 200

; ================================================
;   BIOS PARAMETER BLOCK
; ================================================

BPB:
        ; Support 2 or 3 byte encoded JMPs before BPB
        TIMES 3-($-$$) DB 0x90
        ; BIOS Parameter Block (BPB)
        ; -- DOS 4.0 EBPB 1.44MB FloppyDisk
        OEMname:           DB    "mkfs.fat"
        bytesPerSector:    DW    512
        sectPerCluster:    DB    1
        reservedSectors:   DW    1
        numFAT:            DB    2
        numRootDirEntries: DW    224
        numSectors:        DW    2880
        mediaType:         DB    0xF0
        numFATsectors:     DW    9
        sectorsPerTrack:   DW    18
        numHeads:          DW    2
        numHiddenSectors:  dd    0
        numSectorsHuge:    dd    0
        driveNum:          DB    0
        reserved:          DB    0
        signature:         DB    0x29
        volumeID:          dd    0x2D7E5A1A
        volumeLabel:       DB    "CV KIKE    "
        fileSysType:       DB    "FAT12   "
        ; 8 byte padding (PDF Magic Number)
        DD 0xFFFFFFFF, 0xFFFFFFFF

; ================================================
;   CODE (Stage 1)
; ================================================

_first_stage:
_start:
        ; In real hardware, the BIOS puts the address
        ; of the booting drive on the DL register.
        MOV [drvaddr], DL
__setup:
        ; Setting the Stack
        MOV AX, 07C0h           ; Stack Top
        ADD AX, 120h            ; Stack Space
        MOV SS, AX
        MOV SP, 1000h           ; Stack Pointer
        MOV AX, 07C0h
        MOV DS, AX              ; Data Segment
    .graphical_mode:
        ; Enable Graphical Mode
        MOV AH, 00h             ; Interrupt 00h - Graphical Mode
        MOV AL, 13h             ; Graphical Mode: 320x200 pixels, 256 colors, Graphics
        INT 10h                 ; Interrupt
__display:
    .background:
        ; Draw mode - Graphical Segment
        MOV AX, 0xA000          ; Graphical Segment Address
        MOV ES, AX
        ; Fill the background
        MOV AL, 03h             ; Color: Cyan
        XOR DI, DI              ; Position: 0,0
        MOV CX, width*height    ; Number of times
        REP STOSB               ; Repeat String Instruction
    .separator:
        XOR AX, AX              ; Color: Black
        MOV DI, 155* width +20  ; Position: 20,140 = 140 times width + 20 
        MOV CX, width -40       ; Line width.         
        REP STOSB               ; Repeat String Instruction
    .header:
        ; Print the title
        PUSH 08h                ; Column
        PUSH 03h                ; Row
        PUSH 18h                ; Message Length
        PUSH title              ; Message
        CALL PRINT              ; Print procedure
    .subheader:
        ; Print the subtitle
        PUSH 11h                ; Column
        PUSH 05h                ; Row
        PUSH 06h                ; Message Length
        PUSH subtitle           ; Message
        CALL PRINT              ; Print procedure
    .description:
        ; Print the description
        PUSH 04h                ; Column
        PUSH 0Eh                ; Row
        PUSH 20h                ; Message Length
        PUSH desc_1             ; Message
        CALL PRINT              ; Print procedure
        PUSH 04h                ; Column
        PUSH 0Fh                ; Row
        PUSH 20h                ; Message Length
        PUSH desc_2             ; Message
        CALL PRINT              ; Print procedure
        PUSH 04h                ; Column
        PUSH 0Ah                ; Row
        PUSH 20h                ; Message Length
        PUSH desc_3             ; Message
        CALL PRINT              ; Print procedure
    .footer:
        ; Print the footer
        PUSH 0Ch                ; Column
        PUSH 16h                ; Row
        PUSH 10h                ; Message Length
        PUSH footer             ; Message
        CALL PRINT              ; Print procedure
        ; Draw mode _ Graphical Segment
        MOV AX, 0xA000          ; Graphical Segment Address
        MOV ES, AX
_loop:
        HLT                     ; End
        JMP _loop               ; Return to end

; FIXME: Transition to Stage 2 is not working
%if 0
    _transition:
            ; Stage 1 only have 512 bytes of space.
            ; Need to jump to the Stage 2

            ; Restore the direction of the booting drive
            MOV DL, [drvaddr]
            ; Setup to Stage 2 
            MOV AH, 02h             ; Load Stage 2
            MOV CH, 00h             ; Cylinder number
            MOV DH, 0003h           ; Head number
            MOV AL, 01h             ; Num. of sectors to read
            MOV CL, 02h             ; Starting sector number (2, because 1 was already loaded)
            MOV BX, _second_stage   ; Stage 2 code
            MOV DL, 0x80            ; Set up initial state (optionally)
            INT 0x13                ; Interrupt

            JMP _second_stage
%endif
; ================================================
;   PROCEDURES (Stage 1)
; ================================================

; PRINT: Writes a text on the screen
;   - [BP + 4]  Message
;   - [BP + 6]  Message Length
;   - [BP + 8]  Row
;   - [BP + 10] Column
PRINT:
        PUSH BP                 ; Save current Base Pointer
        MOV BP, SP              ; Use Base Pointer as Stack Pointer
        PUSHA                   ; Save all the Registers
        ; Arguments
        MOV AX, 07C0h           ; Beginning of the code
        MOV ES, AX              
        MOV DL, [BP + 0Ah]      ; Column
        MOV DH, [BP + 08h]      ; Row
        MOV CX, [BP + 06h]      ; Message Length
        MOV BP, [BP + 04h]      ; Message
        ; Code
        MOV AH, 13h             ; Interrupt 13h - Write
        MOV AL, 00h             ; Graphical Mode: 320x200 pixels, 16 colors, Graphics
        MOV BL, 0Fh             ; Color: Cyan
        INT 10h                 ; Interrupt
        ; Return
        POPA                    ; Restore all the Registers
        MOV SP, BP              ; Restore the Stack Pointer
        POP BP                  ; Restore the Base Pointer
        RET                     ; Exit the procedure

; ================================================
;   DATA (Stage 1)
; ================================================

; Store the drive address given by the BIOS
drvaddr:    DB 00h 
; Strings
title:      DB "?CURRICULUM POLIMORFICO?"
subtitle:   DB "!MOLA!"
desc_1      DB "  Crear cosas asi de curiosas   "
desc_2      DB "es una de mis muchas habilidades"
desc_3      DB "       ?? Me contratas ??       "
footer:     DB "-by Kike Fontan-"

; ================================================
;   END (Stage 1)
; ================================================

; The first sector MUST be 512 bytes and the last 2 bytes must be 0xAA55 for it
; to be bootable
TIMES 510 - ($ - $$) DB 0   ; Padding with 0 at the end
DW 0xAA55                   ; PC Boot Signature

; ================================================
;   CODE (Stage 2)
; ================================================

_second_stage:

; ================================================
;   PROCEDURES (Stage 2)
; ================================================

; ================================================
;   DATA (Stage 2)
; ================================================

; ================================================
;   END (Stage 2)
; ================================================

TIMES 03FAh - ($ - $$) DB 0 ; Maximum size