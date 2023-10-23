    P4      EQU     0C0h    ; Define P4
    ORG     0000h           ; \ Link to the beginning
    JMP     PREP            ; / of the program
    ORG     0003h           ; \ Reference to the interrupt
    JMP     INTIN           ; / handler function int0


PREP:
    MOV     DPTR,   #8000h  ; \ 
    MOV     A,      #04h    ; | 
    MOVX    @DPTR,  A       ; | Loading array addresses
    INC     DPTR            ; | into external memory
    MOV     A,      #12h    ; | 
    MOVX    @DPTR,  A       ; / 

    MOV     DPTR,   #8000h  ; \ 
    MOVX    A,      @DPTR   ; | 
    MOV     DPL,    A       ; | 
    MOV     A,      #0Fh    ; | 
    MOVX    @DPTR,  A       ; | 
    INC     DPTR            ; | 
    MOV     A,      #11h    ; | Loading array "A"
    MOVX    @DPTR,  A       ; | into external memory
    INC     DPTR            ; | 
    MOV     A,      #00h    ; | 
    MOVX    @DPTR,  A       ; | 
    INC     DPTR            ; | 
    MOV     A,      #0FFh   ; | 
    MOVX    @DPTR,  A       ; / 

    MOV     DPTR,   #8001h  ; \ 
    MOVX    A,      @DPTR   ; | 
    MOV     DPL,    A       ; | 
    MOV     A,      #0FFh   ; | 
    MOVX    @DPTR,  A       ; | 
    INC     DPTR            ; | 
    MOV     A,      #05Ch   ; | Loading array "B"
    MOVX    @DPTR,  A       ; | into external memory
    INC     DPTR            ; | 
    MOV     A,      #7Ah    ; | 
    MOVX    @DPTR,  A       ; | 
    INC     DPTR            ; | 
    MOV     A,      #0C3h   ; | 
    MOVX    @DPTR,  A       ; / 

    SETB    EA              ; \ 
    SETB    EX0             ; | Permission to catch interrupts
    SETB    IT0             ; / 


MAIN:
    MOV     P4,     R1      ; \ 
    MOV     DPTR,   #7FFAh  ; | Updating the result in port
    MOVX    A,      @DPTR   ; | P4 and updating the control
    MOV     R2,     A       ; | word to register R2 in the loop
    JMP     MAIN            ; / 


INTIN:
    MOV     A,      R2      ; \ 
    ANL     A,      #03h    ; | 
    MOV     R0,     A       ; | 
    MOV     DPTR,   #8000h  ; | Reading a number from array
    MOVX    A,      @DPTR   ; | "A" according to the control word
    ADD     A,      R0      ; | 
    MOV     DPL,    A       ; | 
    MOVX    A,      @DPTR   ; | 
    MOV     R3,     A       ; / 

    MOV     A,      R2      ; \ 
    ANL     A,      #0Ch    ; | 
    RR      A               ; | 
    RR      A               ; | 
    MOV     R0,     A       ; | Reading a number from array
    MOV     DPTR,   #8001h  ; | "B" according to the control word
    MOVX    A,      @DPTR   ; | 
    ADD     A,      R0      ; | 
    MOV     DPL,    A       ; | 
    MOVX    A,      @DPTR   ; | 
    MOV     R4,     A       ; / 

    MOV     A,      R2      ; \ Checking the
    JNB     ACC.4,  F1      ; | operation bit
    JMP     F2              ; / in the control word


F1:
    MOV     A,      R3      ; Performing the operation at C=0
    CLR     C               ; |
    SUBB    A,      R4      ; V
    JNC     F1_0            ;
    MOV     A,      R3      ;
    JMP     F1_1            ;
F1_0:
    MOV     A,      R4      ;
    JMP     F1_1            ;
F1_1:
    MOV     R0,     A       ;
F1_2:
    JZ      F1_4            ;
    CLR     C               ;
    SUBB    A,      R4      ;
    JNC     F1_3            ;
    MOV     A,      R0      ;
    MOV     B,      A       ;
    MUL     AB              ;
    CLR     C               ;
    SUBB    A,      R3      ;
    JNC     F1_3            ;
    MOV     A,      B       ;
    JNZ     F1_3            ;
    MOV     A,      R0      ;
    JMP     F1_4            ;
F1_3:
    MOV     A,      R0      ;
    DEC     A               ;
    MOV     R0,     A       ;
    JMP     F1_2            ;
F1_4:
    MOV     R1,     A       ; ^
    JMP     INTOUT          ; |


F2:
    MOV     A,      R3      ; Performing the operation at C=1
    MOV     C,      ACC.0   ; |
    MOV     07h,    C       ; V
    MOV     C,      ACC.1   ;
    MOV     06h,    C       ;
    MOV     C,      ACC.2   ;
    MOV     05h,    C       ;
    MOV     C,      ACC.3   ;
    MOV     04h,    C       ;
    MOV     C,      ACC.4   ;
    MOV     03h,    C       ;
    MOV     C,      ACC.5   ;
    MOV     02h,    C       ;
    MOV     C,      ACC.6   ;
    MOV     01h,    C       ;
    MOV     C,      ACC.7   ;
    MOV     00h,    C       ;
    MOV     A,      20h     ;
    XRL     A,      R4      ;
    MOV     R1,     A       ; ^
    JMP     INTOUT          ; |


INTOUT:
    RETI                    ; Return from Interrupt Handling

END
