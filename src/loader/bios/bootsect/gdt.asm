[bits 16]

gdt:
    .null: dq 0
    .code:
        dw 0xFFFF
        dw 0
        db 0
        db 0x9A
        db 0xCF
        db 0
    .data:
        dw 0xFFFF
        dw 0
        db 0
        db 0x92
        db 0xCF
        db 0
    .end:
    .descriptor:
        dw gdt.end - gdt
        dd gdt

CODE_SEG equ gdt.code - gdt
DATA_SEG equ gdt.data - gdt