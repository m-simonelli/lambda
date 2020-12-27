[bits 16]
; trashes registers
clr_scrn:
    ; clear screen with attrs:
    ;   bg: black
    ;   fg: white
    ;   rc: 79
    ;   cc: 24
    ;    o: top left
    mov ah, 0x07
    xor al, al
    mov bh, 0x0F
    xor cx, cx
    mov dx, 0x184F

    int 0x10
    ret