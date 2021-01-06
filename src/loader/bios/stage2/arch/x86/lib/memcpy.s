; memcpy.S
; Copyright Marco Simonelli 2020
; You are free to redistribute/modify this code under the 
; terms of the GPL version 3 (see the file LICENSE)

[bits 64]
global memcpy

section .text

memcpy:
    push rbp
    mov rbp, rsp

    ; rdi: dst
    ; rsi: src
    ; rdx: count

    mov rax, rdi ; rval

    ; for the case when cnt < 32 bytes
    cmp rdx, 32
    jb .tail

    ; check for case 2
    cmp rdi, rsi
    ja .reverse
    ; predecrement
    lea rdx, [rdx - 32]

    align 16 ; Assembly/Compiler Coding Rule 12 - All branch targets should be 16-byte aligned.
  .forward_copy_loop:
    sub rdx, 32
    ; move in 4x8 groups
    ; load
    mov r8,  [rsi + 0]
    mov r9,  [rsi + 8]
    mov r10, [rsi + 16]
    mov r11, [rsi + 24]
    lea rsi, [rsi + 32] ; equivalent to add rsi, 32 but lea is faster
    ; store
    mov [rdi + 0],  r8
    mov [rdi + 8],  r9
    mov [rdi + 16], r10
    mov [rdi + 24], r11
    lea rdi, [rdi + 32]
    ; if the sub rdx, 0x10 didn't underflow, loop
    jae .forward_copy_loop
    lea rdx, [rdx + 32]

    jmp .tail
  
    align 16
  .reverse:
    ; start at tail of src/dest
    add rdi, rdx
    add rsi, rdx
    ; predecrement
    lea rdx, [rdx - 32]

    align 16
  .reverse_copy_loop:
    sub rdx, 32
    ; move in 4x8 groups
    ; load
    mov r8,  [rsi - 0]
    mov r9,  [rsi - 8]
    mov r10, [rsi - 16]
    mov r11, [rsi - 24]
    lea rsi, [rsi - 32]
    ; store
    mov [rdi - 0],  r8
    mov [rdi - 8],  r9
    mov [rdi - 16], r10
    mov [rdi - 24], r11
    lea rdi, [rdi - 32]
    jae .reverse_copy_loop
  
    ; .tail only handles forward copy, fix pointers
    lea rdx, [rdx + 32]
    sub rdi, rdx
    sub rsi, rdx

    align 16
  .tail:
    mov rcx, rdx
    rep movsb

    mov rsp, rbp
    pop rbp
    ret

; this *maybe* works and probably isn't even more efficient lmao
; haven't tested so this is hypothesizing, but i think this is less efficient
; since it'll likely make it hard for the branch predictor to guess right, and
; it takes up *way* too many bytes so i-cache/uop cache misses are more likely
; i'll benchmark it later
; also this doesn't decompile nicely :(
%if 0
    lea rcx, [_memcpy_tail_jmp_table]
    jmp [rcx + rdx * 8]
    
  .tail_b32:
    ; move 16 bytes, then handle the rest with the jump table again
    mov r8,  [rsi + 0]
    mov r9,  [rsi + 8]

    sub rdx, 16
    add rsi, 16
    add rdi, 16

    mov [rdi + 0], r8
    mov [rdi + 8], r9

    jmp [rcx + rdx * 8]

  .tail_b16:
    ; move 8 bytes, then handle the rest with the jump table again
    mov r8,  [rsi + 0]

    sub rdx, 8
    add rsi, 8
    add rdi, 8

    mov [rdi + 0], r8

    jmp [rcx + rdx * 8]

  .tail_b8:
    ; move 4 bytes, then handle the rest with the jump table again
    mov r8d, [rsi + 0]

    sub rdx, 4
    add rsi, 4
    add rdi, 4

    mov [rdi + 0], r8d

    jmp [rcx + rdx * 8]
  .tail_b4:
    ; move 2 bytes, then handle the rest with the jump table again
    mov r8w, [rsi + 0]

    sub rdx, 2
    add rsi, 2
    add rdi, 2

    mov [rdi + 0], r8w

    jmp [rcx + rdx * 8]
  .tail_b2:
    ; move 1 byte
    mov r8b, [rsi + 0]
    mov [rdi + 0], r8b

  .done:
    mov rsp, rbp
    pop rbp
    ret

section .data

; cursed jump table
; 256 bytes 8)
_memcpy_tail_jmp_table:
    times 1  dq memcpy.done
    times 1  dq memcpy.tail_b2
    times 2  dq memcpy.tail_b4
    times 4  dq memcpy.tail_b8
    times 8  dq memcpy.tail_b16
    times 16 dq memcpy.tail_b32
%endif

; cases:
;   1. dest < src   => copy 4 bytes at a time with no issues
;   2. dest > src   => start at tail