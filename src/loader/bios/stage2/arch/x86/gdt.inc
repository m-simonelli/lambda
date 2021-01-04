; gdt.inc
; Copyright Marco Simonelli 2020
; You are free to redistribute/modify this code under the 
; terms of the GPL version 3 (see the file LICENSE)

%ifndef _s2_arch_x86_64_gdt_inc
%define _s2_arch_x86_64_gdt_inc

%ifndef s2_vaddr
%define s2_vaddr 0xFFFFFFFFC0000000
%endif

section .rodata
gdt:
.gdt_start:
.gdt_null:
    dq 0

; 64 bit mode s2
; entry 0x0: null
; entry 0x8: k_code
; entry 0x10: k_data
.s2_code_64:
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; code segment

.s2_data_64:
    dq (1<<41) | (1<<44) | (1<<47) ; data segment

.tss:
    dq 0
    dq 0

.gdt_end:
.gdt_descriptor:
    dw .gdt_end - .gdt_start - 1    ; size
    dd .gdt_start-s2_vaddr          ; start addr

CODE_64 equ gdt.s2_code_64 - gdt.gdt_start
DATA_64 equ gdt.s2_data_64 - gdt.gdt_start

section .text
%endif