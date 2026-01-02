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

.include "opcodes.inc"
.include "cpu-6510.inc"
.include "c64/basic-internal.inc"
.include "c64/cia-1.inc"
.include "c64/cia-2.inc"
.include "c64/colors.inc"
.include "c64/kernal-r3.inc"
.include "c64/kernal-r3-internal.inc"
.include "c64/memory-map.inc"
.include "c64/petscii.inc"
.include "c64/registers.inc"
.include "c64/vic.inc"
.include "c64/cpu.inc"
.include "structured-programming.inc"

.import __OS_TAPE_BUFFER_START__
.import __PROGRAM_MEM_LAST__

.include "program.inc"

.include "features.inc"

; | P:14-21:P | T:22-2A:T | P:2B-4A:P | T:4B-60:T | T:FB-FC:T | P:FD-FE:P | P:033C-03FB:P | Hex

;   Available zero page locations:
;   FROM- TO  SIZE  LABEL       USAGE
;   $02 - $09    8  ZP_1_FIRST  REGISTERS_BASE AX - DX
;   $0B - $12    8  ZP_2_FIRST
;   $14 - $2A   23  ZP_3_FIRST  FS FS_BOTTOM..FS_TOP
;   $3F - $48   10  ZP_4_FIRST
;   $4B - $72   40  ZP_5_FIRST  RS RS_BOTTOM RS_TOP
;   $8B - $8F    5  ZP_6_FIRST  RSP FSP FP MPX/MPL/MPH
;   $92          1  ZP_7_FIRST
;   $96 - $97    2  ZP_8_FIRST  
;   $9B - $9C    2  ZP_9_FIRST
;   $9E - $9F    2  ZP_A_FIRST  
;   $A6 - $AB    6  ZP_B_FIRST
;   $B0 - $B6    7  ZP_C_FIRST
;   $BD - $C0    4  ZP_D_FIRST  
;   $F7 - $FF    9  ZP_E_FIRST
;   Total     127

.exportzp ZP_02 := $02  ; Unused                ; AL  General purpose register
.exportzp ZP_03 := $03  ; ZPBASIC_ADRAY1_LO     ; AH  General purpose register
.exportzp ZP_04 := $04  ; ZPBASIC_ADRAY1_HI     ; BL  General purpose register
.exportzp ZP_05 := $05  ; ZPBASIC_ADRAY2_LO     ; BH  General purpose register
.exportzp ZP_06 := $06  ; ZPBASIC_ADRAY2_HI     ; CL  General purpose register
.exportzp ZP_07 := $07  ; ZPBASIC_CHARAC_INTEGR ; CH  General purpose register
.exportzp ZP_08 := $08  ; ZPBASIC_ENDCHR        ; DL  General purpose register
.exportzp ZP_09 := $09  ; ZPBASIC_TRMPOS        ; DH  General purpose register

.exportzp ZP_0B := $0B  ; ZPBASIC_COUNT
.exportzp ZP_0C := $0C  ; ZPBASIC_DIMFLG
.exportzp ZP_0D := $0D  ; ZPBASIC_VALTYP
.exportzp ZP_0E := $0E  ; ZPBASIC_INTFLG
.exportzp ZP_0F := $0F  ; ZPBASIC_DORES_GARBFL
.exportzp ZP_10 := $10  ; ZPBASIC_SUBFLG
.exportzp ZP_11 := $11  ; ZPBASIC_INPFLG
.exportzp ZP_12 := $12  ; ZPBASIC_DOMASK_TANSGN

.exportzp ZP_14 := $14  ; ZPBASIC_LINNUM_LO_POKER_LO
.exportzp ZP_15 := $15  ; ZPBASIC_LINNUM_HI_POKER_HI
.exportzp ZP_16 := $16  ; ZPBASIC_TEMPPT
.exportzp ZP_17 := $17  ; ZPBASIC_LASTPT_LO
.exportzp ZP_18 := $18  ; ZPBASIC_LASTPT_HI
.exportzp ZP_19 := $19  ; ZPBASIC_TEMPST
.exportzp ZP_1A := $1A  ; ZPBASIC_TEMPST + 1
.exportzp ZP_1B := $1B  ; ZPBASIC_TEMPST + 2
.exportzp ZP_1C := $1C  ; ZPBASIC_TEMPST + 3
.exportzp ZP_1D := $1D  ; ZPBASIC_TEMPST + 4
.exportzp ZP_1E := $1E  ; ZPBASIC_TEMPST + 5
.exportzp ZP_1F := $1F  ; ZPBASIC_TEMPST + 6
.exportzp ZP_20 := $20  ; ZPBASIC_TEMPST + 7
.exportzp ZP_21 := $21  ; ZPBASIC_TEMPST + 8
.exportzp ZP_22 := $22  ; ZPBASIC_INDEX_LO_INDEX1_LO
.exportzp ZP_23 := $23  ; ZPBASIC_INDEX_HI_INDEX1_HI
.exportzp ZP_24 := $24  ; ZPBASIC_INDEX2_LO
.exportzp ZP_25 := $25  ; ZPBASIC_INDEX2_HI
.exportzp ZP_26 := $26  ; ZPBASIC_RESHO
.exportzp ZP_27 := $27  ; ZPBASIC_RESMOH
.exportzp ZP_28 := $28  ; ZPBASIC_ADDEND_RESMO
.exportzp ZP_29 := $29  ; ZPBASIC_RESLO
.exportzp ZP_2A := $2A  ; ZPBASIC_UNUSED_2A ; Unused

.exportzp ZP_3F := $3F  ; ZPBASIC_DATLIN_LO
.exportzp ZP_40 := $40  ; ZPBASIC_DATLIN_HI
.exportzp ZP_41 := $41  ; ZPBASIC_DATPTR_LO
.exportzp ZP_42 := $42  ; ZPBASIC_DATPTR_HI
.exportzp ZP_43 := $43  ; ZPBASIC_INPPTR_LO
.exportzp ZP_44 := $44  ; ZPBASIC_INPPTR_HI
.exportzp ZP_45 := $45  ; ZPBASIC_VARNAM_LO
.exportzp ZP_46 := $46  ; ZPBASIC_VARNAM_HI
.exportzp ZP_47 := $47  ; ZPBASIC_FDECPT_LO_VARPNT_LO
.exportzp ZP_48 := $48  ; ZPBASIC_FDECPT_HI_VARPNT_HI

.exportzp ZP_4B := $4B  ; ZPBASIC_OPPTR_LO_VARTXT_LO
.exportzp ZP_4C := $4C  ; ZPBASIC_OPPTR_HI_VARTXT_HI
.exportzp ZP_4D := $4D  ; ZPBASIC_OPMASK
.exportzp ZP_4E := $4E  ; ZPBASIC_DEFPNT_LO_GRBPNT_LO_TEMPF3_LO
.exportzp ZP_4F := $4F  ; ZPBASIC_DEFPNT_HI_GRBPNT_HI_TEMPF3_HI
.exportzp ZP_50 := $50  ; ZPBASIC_DSCPNT_LO
.exportzp ZP_51 := $51  ; ZPBASIC_DSCPNT_HI
.exportzp ZP_52 := $52  ; ZPBASIC_UNUSED_52 ; Unused
.exportzp ZP_53 := $53  ; ZPBASIC_FOUR6
.exportzp ZP_54 := $54  ; ZPBASIC_JMPER
.exportzp ZP_55 := $55  ; ZPBASIC_SIZE
.exportzp ZP_56 := $56  ; ZPBASIC_OLDOV
.exportzp ZP_57 := $57  ; ZPBASIC_TEMPF1
.exportzp ZP_58 := $58  ; ZPBASIC_ARYPNT_LO_HIGHDS_LO
.exportzp ZP_59 := $59  ; ZPBASIC_ARYPNT_HI_HIGHDS_HI
.exportzp ZP_5A := $5A  ; ZPBASIC_HIGHTR_LO
.exportzp ZP_5B := $5B  ; ZPBASIC_HIGHTR_HI
.exportzp ZP_5C := $5C  ; ZPBASIC_TEMPF2
.exportzp ZP_5D := $5D  ; ZPBASIC_DECCNT_LO_LOWDS_LO
.exportzp ZP_5E := $5E  ; ZPBASIC_DECCNT_HI_LOWDS_HI_TENEXP
.exportzp ZP_5F := $5F  ; ZPBASIC_DPTFLG_GRBTOP_LOWTR
.exportzp ZP_60 := $60  ; ZPBASIC_EXPSGN_EPSGN
.exportzp ZP_61 := $61  ; ZPBASIC_DSCTMP_FAC_FACEXP
.exportzp ZP_62 := $62  ; ZPBASIC_FACHO
.exportzp ZP_63 := $63  ; ZPBASIC_FACMOH
.exportzp ZP_64 := $64  ; ZPBASIC_FACMO_INDICE
.exportzp ZP_65 := $65  ; ZPBASIC_FACLO
.exportzp ZP_66 := $66  ; ZPBASIC_FACSGN
.exportzp ZP_67 := $67  ; ZPBASIC_DEGREE_SGNFLG
.exportzp ZP_68 := $68  ; ZPBASIC_BITS
.exportzp ZP_69 := $69  ; ZPBASIC_ARGEXP
.exportzp ZP_6A := $6A  ; ZPBASIC_ARGHO
.exportzp ZP_6B := $6B  ; ZPBASIC_ARGMOH
.exportzp ZP_6C := $6C  ; ZPBASIC_ARGMO
.exportzp ZP_6D := $6D  ; ZPBASIC_ARGLO
.exportzp ZP_6E := $6E  ; ZPBASIC_ARGSGN
.exportzp ZP_6F := $6F  ; ZPBASIC_ARISGN_STRNGI_STRNG1
.exportzp ZP_70 := $70  ; ZPBASIC_FACOV
.exportzp ZP_71 := $71  ; ZPBASIC_BUFPTR_LO_CURTOL_LO_FBUFPT_LO_POLYPT_LO_STRNG2_LO
.exportzp ZP_72 := $72  ; ZPBASIC_BUFPTR_HI_CURTOL_HI_FBUFPT_HI_POLYPT_HI_STRNG2_HI

.exportzp ZP_8B := $8B  ; ZPBASIC_RNDX
.exportzp ZP_8C := $8C  ; ZPBASIC_RNDX + 1
.exportzp ZP_8D := $8D  ; ZPBASIC_RNDX + 2
.exportzp ZP_8E := $8E  ; ZPBASIC_RNDX + 3
.exportzp ZP_8F := $8F  ; ZPBASIC_RNDX + 4

.exportzp ZP_92 := $92  ; ZPKERNAL_SVXT         ; Datasette

.exportzp ZP_96 := $96  ; ZPKERNAL_SYNO         ; Datasette
.exportzp ZP_97 := $97  ; ZPKERNAL_XSAV         ; Datasette, RS232

.exportzp ZP_9B := $9B  ; ZPKERNAL_PRTY         ; Datasette
.exportzp ZP_9C := $9C  ; ZPKERNAL_DPSW         ; Datasette

.exportzp ZP_9E := $9E  ; ZPKERNAL_PTR1_T1      ; Datasette, RS232
.exportzp ZP_9F := $9F  ; ZPKERNAL_PTR2_T2_TMPC ; Datasette

.exportzp ZP_A6 := $A6  ; ZPKERNAL_BUFPT        ; Datasette
.exportzp ZP_A7 := $A7  ; ZPKERNAL_INBIT_SHCNL  ; RS232
.exportzp ZP_A8 := $A8  ; ZPKERNAL_BITCI_RER    ; RS232
.exportzp ZP_A9 := $A9  ; ZPKERNAL_REZ_RINONE   ; RS232
.exportzp ZP_AA := $AA  ; ZPKERNAL_RDFLG_RIDATA ; RS232
.exportzp ZP_AB := $AB  ; ZPKERNAL_RIPRTY_SHCNH ; Datasette, RS232

.exportzp ZP_B0 := $B0  ; ZPKERNAL_CMP0         ; Unknown
.exportzp ZP_B1 := $B1  ; ZPKERNAL_TEMP         ; Unknown
.exportzp ZP_B2 := $B2  ; ZPKERNAL_TAPE1_LO     ; Datasette ; Pointer to datasette buffer. Default: $033C
.exportzp ZP_B3 := $B3  ; ZPKERNAL_TAPE1_HI     ; Datasette ; ^
.exportzp ZP_B4 := $B4  ; ZPKERNAL_BITTS_SNSW1  ; RS232
.exportzp ZP_B5 := $B5  ; ZPKERNAL_DIFF_NXTBIT  ; RS232
.exportzp ZP_B6 := $B6  ; ZPKERNAL_PRP_RODATA   ; RS232

.exportzp ZP_BD := $BD  ; ZPKERNAL_OCHAR_ROPRTY ; RS232
.exportzp ZP_BE := $BE  ; ZPKERNAL_FSBLK        ; Datasette
.exportzp ZP_BF := $BF  ; ZPKERNAL_FSBLK        ; Unknown
.exportzp ZP_C0 := $C0  ; ZPKERNAL_CAS1         ; Datasette

.exportzp ZP_F7 := $F7  ; ZPKERNAL_RIBUF_LO     ; RS232
.exportzp ZP_F8 := $F8  ; ZPKERNAL_RIBUF_HI     ; RS232
.exportzp ZP_F9 := $F9  ; ZPKERNAL_ROBUF_LO     ; RS232
.exportzp ZP_FA := $FA  ; ZPKERNAL_ROBUF_HI     ; RS232
.exportzp ZP_FB := $FB  ; ZPKERNAL_FREKZP_FB    ; Unused
.exportzp ZP_FC := $FC  ; ZPKERNAL_FREKZP_FC    ; Unused
.exportzp ZP_FD := $FD  ; ZPKERNAL_FREKZP_FD    ; Unused
.exportzp ZP_FE := $FE  ; ZPKERNAL_FREKZP_FE    ; Unused
.exportzp ZP_FF := $FF  ; ZPKERNAL_BASZPT_STRTMP_LOFBUF ; Might be used


; ZPKERNAL_TIME_0 := $A0 ; Value of TI variable, time of day, increased by 1 every 1/60 second (on PAL machines). Values: $000000-$4F19FF, 0-518399 (on PAL machines).
; ZPKERNAL_TIME_1 := $A1
; ZPKERNAL_TIME_2 := $A2
; kernal-r3-internal.export.asm:
; ZPKERNAL_PNT    := $D1-$D2 Pointer to current line in screen memory
; KVAR_COLOR := $0286 ; Current color, cursor color. Values: $00-$0F, 0-15.

.exportzp P19 := ZP_19

.exportzp T22 := $22    ; [T22+T23],y
.exportzp T23 := $23

.exportzp T26 := $26    ; [T26+T27],y
.exportzp T27 := $27

.exportzp P35 := $35
.exportzp P36 := $36
.exportzp P38 := $38
.exportzp P39 := $39

.exportzp T4E := $4E    ; [T4E+T4F],y
.exportzp T4F := $4F

.exportzp T50 := $50
.exportzp T52 := $52
.exportzp T53 := $53

.exportzp T57 := $57    ; [T57+T58],y
.exportzp T58 := $58

.exportzp T59 := $59
.exportzp T5A := $5A
.exportzp T5B := $5B    ; CURSOR_X_SCREEN 0..35

.exportzp T5C := $5C    ; [T5C+T5D],y
.exportzp T5D := $5D

.exportzp T5E := $5E    ; [T5E+T5F],y
.exportzp T5F := $5F

.exportzp Z92 := $92

.exportzp TFB := $FB    ; [TFB+TFC],y
.exportzp TFC := $FC

.exportzp PFD := $FD    ; [PFD+PFE],y
.exportzp PFE := $FE

.exportzp Z96 := $96
.exportzp Z97 := $97

.exportzp Z9B := $9B
.exportzp Z9C := $9C                    ; X = V37D8

.exportzp Z9E := $9E
.exportzp Z9F := $9F

.exportzp ZA6 := $A6                    ; free
.exportzp ZA7 := $A7                    ; free

.exportzp ZA8 := $A8
.exportzp ZA9 := $A9

.exportzp ZAA := $AA
.exportzp ZAB := $AB

.exportzp ZB0 := $B0                    ; L32D6 cmp0 ZPKERNAL_CMP0 Tape
.exportzp ZB1 := $B1                    ; L32D7 temp               Tape
.exportzp ZB2 := $B2                    ; L32E8
.exportzp ZB3 := $B3                    ; Y
.exportzp ZB4 := $B4                    ; free
.exportzp ZB5 := $B5                    ; free
.exportzp ZB6 := $B6                    ; free

V033C := __OS_TAPE_BUFFER_START__ + $0000                   ; $033C KERNAL_TBUFFR Datasette buffer (192 bytes).
V033D := __OS_TAPE_BUFFER_START__ + $0001                   ; $00 Because it is not possible to have >= 256 arguments
V033E := __OS_TAPE_BUFFER_START__ + $0002                   ; $033E argv...
V033F := __OS_TAPE_BUFFER_START__ + $0003                   ; $033F
V0340 := __OS_TAPE_BUFFER_START__ + $0004                   ; $0340
                                                            ; ...
V03FA := __OS_TAPE_BUFFER_START__ + 190                     ; $03FA
V03FB := __OS_TAPE_BUFFER_START__ + 191                     ; $03FB

;;; summary: Shell argument count
SHELL_ARGC := V033C                                         ; 1..10
SHELL_ARGC_LO := V033C
SHELL_ARGC_HI := V033D                                      ; Always 0

;;; summary: Shell arguments, each PETSCII_NUL terminated.
SHELL_ARGV_LO := V033E
SHELL_ARGV_HI := V033F
SHELL_ARGV := SHELL_ARGV_LO

;EDIT_BUFFERS_2_LAST_PAGE_PTR := EDIT_BUFFERS_2_LAST_PAGE << 8
;VBF00 := EDIT_BUFFERS_2_LAST_PAGE_PTR                       ; Was $BF00

.segment "CODE"
.include "program.code.a65"

.segment "RODATA"
.include "program.rodata.a65"

.segment "DATA"
.include "program.data.a65"

.segment "BSS"
.include "program.bss.a65"

.export main
