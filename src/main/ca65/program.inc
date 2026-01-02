;    PEDSCII: Editor for the Commodore.
;    Copyright (C) 2025  C64PECTRE
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see https://www.gnu.org/licenses/.
;
;    Contact: https://github.com/c64pectre/pedscii/ create an issue

; notes:
;   original memory layout:
;     $1800-$367F CODE
;     $3680-$38FF DATA
;     $3900-$73FF EDIT BUFFERS 1
;     $7400-$74ff OUR TEXT SCREEN
;     $7500-$7FFF ?
;     $8000-$BFFF EDIT BUFFERS 2
;     $C000-$CFFF ?
;     $D000-$DFFF IO
;     $E000-$FFFF KERNAL ROM
;
; New memory layout:
; +----------------+------------+-----------------------------------------------------------------+--------------------------------------+
; | From .. To     | Size       | Labels From .. To                                               | Description                          |
; +----------------+------------+-----------------------------------------------------------------+--------------------------------------+
; | $0000 .. $00FF | $100 = 256 | __ZEROPAGE_START__    .. __ZEROPAGE_START__ + __ZEROPAGE_SIZE__ | Zero page                            |
; | $0801 .. $27DD |            | __PROGRAM_MEM_START__ .. __PROGRAM_MEM_LAST__                   | Program                              |
; | $2800 .. $CFFF |            | EDIT_BUFFERS_1_FIRST_PAGE<<8 .. EDIT_BUFFERS_2_LAST_PAGE<<8+$FF | EDIT BUFFERS 1                       |
; | $D000 .. $FFFF |            | EDIT_BUFFERS_1_FIRST_PAGE<<8 .. EDIT_BUFFERS_2_LAST_PAGE<<8+$FF | EDIT BUFFERS 2 under IO & KERNAL ROM |
; +----------------+------------+-----------------------------------------------------------------+--------------------------------------+

; We have got 10 edit buffers:
; 0   Main
; 1   Paste
; 2-9 User defined
EDIT_BUFFER_COUNT = 10

BUFFER_INDEX_MAIN = 0
BUFFER_INDEX_PASTE = 1

;;; summary: Maximum length of buffer name (including nul terminator)
EDIT_BUFFER_NAME_MAX_LENGTH = 8

EDIT_BUFFERS_1_FIRST_PAGE = >(__PROGRAM_MEM_LAST__ + $FF)   ; $27
EDIT_BUFFERS_1_LAST_PAGE  = $CE

EDIT_BUFFERS_2_FIRST_PAGE = $CF
EDIT_BUFFERS_2_LAST_PAGE  = $CF

PAGE_LINE_COUNT = 20

MARGIN_LEFT   = 4
MARGIN_RIGHT  = 4
MARGIN_TOP    = 6
MARGIN_BOTTOM = 6

BUMP_LEFT   = 5
BUMP_RIGHT  = 35
BUMP_TOP    = 7
BUMP_BOTTOM = 17

BUFFER_NAME_TABLE_ENTRY_SIZE = 8;
BUFFER_NAME_MAX_LENGTH = BUFFER_NAME_TABLE_ENTRY_SIZE - 1
BUFFER_NAME_TABLE_ENTRY_COUNT = 10;

COMMAND_COUNT = 8
COMMAND_NAME_LENGTH = 7

MAX_LINE_LENGTH = 240                                       ; $F0

CURSOR_BLINK_DELAY = 20                                     ; $14

;
; Screen (Video Matrix), Character Base, Color RAM
;

OUR_TEXT_SCREEN_FIRST_PAGE = >SCREEN_TEXT_RAM_BASE          ; $04
OUR_TEXT_SCREEN_LAST_PAGE  = OUR_TEXT_SCREEN_FIRST_PAGE + 3 ; $07
;OUR_TEXT_SCREEN_PAGE_COUNT = 4
;SCREEN_PAGE_COUNT = 4

COLOR_RAM_BASE := SCREEN_COLOR_RAM_BASE

; VIC Bank
;
;   CIA_2_PRA $DD00
;     Bit 0..1: Select the position of the VIC-memory
;       %00, 0: Bank 3: $C000-$FFFF, 49152-65535
;       %01, 1: Bank 2: $8000-$BFFF, 32768-49151
;       %10, 2: Bank 1: $4000-$7FFF, 16384-32767
;       %11, 3: Bank 0: $0000-$3FFF, 0-16383 (standard)

OUR_VIC_BANK_BASE := VIC_BANK_0_BASE                        ; $0000

OUR_VIDEO_MATRIX_BASE := OUR_TEXT_SCREEN_FIRST_PAGE << 8

;;; summary: Our Video Memory
OUR_VM = $15

; V17FC := $17FC                                              ; SHELL work drive. Replaced by ZPKERNAL_FA (last used serial device)

; DISK_CMD_FA File Address we take from ZPKERNAL_FA
DISK_CMD_FH = $0F                       ; Disk command: File Handle
DISK_CMD_SA = $0F                       ; Disk command: Secondary Address (channel)

; SERIAL_DATA_FA take from ZPKERNAL_FA
SERIAL_DATA_FH = $01                    ; File Handle for disk/printer data
SERIAL_DATA_DOC_SA = $02                ; SA for loading and saving document
SERIAL_DATA_DIR_SA = $00                ; SA for loading directory
SERIAL_DATA_PRINT_SA = $07              ; SA for printing

EDIT_PANEL_FIRST_LINE = 0  ; $00
EDIT_PANEL_LAST_LINE  = 23 ; $17
EDIT_PANEL_LAST_LINE_START_VM := OUR_VIDEO_MATRIX_BASE + EDIT_PANEL_LAST_LINE * VIC_CHAR_COLUMNS ; $7798

EDIT_PANEL_BEFORE_LAST_LINE = EDIT_PANEL_LAST_LINE - 1
EDIT_PANEL_BEFORE_LAST_LINE_START_VM := OUR_VIDEO_MATRIX_BASE + EDIT_PANEL_BEFORE_LAST_LINE * VIC_CHAR_COLUMNS ; $7770

COMMAND_PANEL_FIRST_LINE = 24
COMMAND_PANEL_LAST_LINE = 24
; Ptr to start command line in Video Memory $77C0
COMMAND_PANEL_FIRST_LINE_START_VM := OUR_VIDEO_MATRIX_BASE + COMMAND_PANEL_FIRST_LINE * VIC_CHAR_COLUMNS
; Ptr to start command line in Color Ram $DBC0
COMMAND_PANEL_FIRST_LINE_START_CR := COLOR_RAM_BASE        + COMMAND_PANEL_FIRST_LINE * VIC_CHAR_COLUMNS

TABLE_POWER_OF_10_LENGTH = 4

SIZEOF_BYTE = 1
SIZEOF_WORD = 2
SIZEOF_ADDR = 2

;;; summary: Number of digits handled by INT_TO_STRING / INT_TO_STRING_RESULT [0,9999]
INT_TO_STRING_DIGIT_COUNT = 4
; INT_TO_STRING_RESULT = L2623

MODE_EDIT   = $00
MODE_SELECT = $01

FALSE = 0
TRUE  = 1

;
; Commands
;

CMD_COUNT = 21

CMD_NUMBER_SELECT_ALL     =  0
CMD_NUMBER_COMMAND_MODE   =  1
CMD_NUMBER_SPLIT_LINE     =  2
CMD_NUMBER_COPY           =  3
CMD_NUMBER_CURSOR_DOWN    =  4
CMD_NUMBER_GO_BEGIN_LINE  =  5
CMD_NUMBER_DELETE         =  6
CMD_NUMBER_CURSOR_RIGHT   =  7
CMD_NUMBER_SELECT_MODE    =  8
CMD_NUMBER_PAGE_DOWN      =  9
CMD_NUMBER_SEARCH_DOWN    = 10
CMD_NUMBER_GO_TOP         = 11
CMD_NUMBER_F7             = 12
CMD_NUMBER_PAGE_UP        = 13
CMD_NUMBER_SEARCH_UP      = 14
CMD_NUMBER_GO_BOTTOM      = 15
CMD_NUMBER_F8             = 16
CMD_NUMBER_ADD_LINE       = 17
CMD_NUMBER_CURSOR_UP      = 18
CMD_NUMBER_GO_END_LINE    = 19
CMD_NUMBER_INSERT         = 20
CMD_NUMBER_CURSOR_LEFT    = 21
CMD_NUMBER_CUT            = 22
CMD_NUMBER_PASTE          = 23

CMD_KEY_SELECT_ALL    = PETSCII_CTRL_A        ; $01    1  <CTRL> + <A>
CMD_KEY_COMMAND_MODE  = PETSCII_STOP          ; $03    3  <RUN STOP> or <CTRL> + <C>
CMD_KEY_SPLIT_LINE    = PETSCII_RETURN        ; $0D   13  <RETURN>
CMD_KEY_COPY          = PETSCII_CTRL_P        ; $10   16  <CTRL> + <P>
CMD_KEY_CURSOR_DOWN   = PETSCII_CURSOR_DOWN   ; $11   17  <CRSR U D>
CMD_KEY_GO_BEGIN_LINE = PETSCII_HOME          ; $13   19  <HOME_CLR>
CMD_KEY_DELETE        = PETSCII_DELETE        ; $14   20  <INST DEL>
CMD_KEY_CURSOR_RIGHT  = PETSCII_CURSOR_RIGHT  ; $1D   29  <CRSR L R>
CMD_KEY_SELECT_MODE   = PETSCII_RUN           ; $83  131  <SHIFT> + <RUN STOP>
CMD_KEY_PAGE_DOWN     = PETSCII_F1            ; $85  133  <F1>
CMD_KEY_SEARCH_DOWN   = PETSCII_F3            ; $86  134  <F3>
CMD_KEY_GO_TOP        = PETSCII_F5            ; $87  135  <F5>
CMD_KEY_F7            = PETSCII_F7            ; $88  136  <F7>
CMD_KEY_PAGE_UP       = PETSCII_F2            ; $89  137  <SHIFT> + <F1> (<F2>)
CMD_KEY_SEARCH_UP     = PETSCII_F4            ; $8A  138  <SHIFT> + <F3> (<F4>)
CMD_KEY_GO_BOTTOM     = PETSCII_F6            ; $8B  139  <SHIFT> + <F5> (<F6>)
CMD_KEY_F8            = PETSCII_F8            ; $8C  140  <SHIFT> + <F7> (<F8>)
CMD_KEY_ADD_LINE      = PETSCII_SHIFT_RETURN  ; $8D  141  <SHIFT> + <RETURN>
CMD_KEY_CURSOR_UP     = PETSCII_CURSOR_UP     ; $91  145  <SHIFT> + <CRSR U D>
CMD_KEY_GO_END_LINE   = PETSCII_CLR           ; $93  147  <SHIFT> + <CLR HOME>
CMD_KEY_INSERT        = PETSCII_INSERT        ; $94  148  <SHIFT> + <INST DEL>
CMD_KEY_CURSOR_LEFT   = PETSCII_CURSOR_LEFT   ; $9D  157  <SHIFT> + <CRSR L R>
CMD_KEY_CUT           = PETSCII_CTRL_X        ; $BD  189  <CTRL> + <X>
CMD_KEY_PASTE         = PETSCII_CTRL_V        ; $BE  190  <CTRL> + <V>

;
; Exceptions
;

EXCEPTION_NONE                    = 0
EXCEPTION_OUT_OF_MEMORY           = 1
EXCEPTION_NOT_ENOUGH_MEMORY       = 2
EXCEPTION_DRIVE_NOT_PRESENT       = 3
EXCEPTION_NO_MORE_FREE_FILES      = 4
EXCEPTION_SEARCH_STRING_NOT_FOUND = 5
