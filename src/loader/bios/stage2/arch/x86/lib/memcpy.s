; memcpy.S
; Copyright Marco Simonelli 2020
; You are free to redistribute/modify this code under the 
; terms of the GPL version 3 (see the file LICENSE)

[bits 32]
global memcpy

memcpy:
    pop eax ; dest
    pop edx ; src
    pop ecx ; cnt

    ; check for case 2
    cmp eax, edx
    jne .neq
    ret

  .neq:
    push ebp
    push ebx
    push edi
    push esi
    push esp

    mov edi, eax ; dest
    mov esi, edx ; src

    ; for the case when cnt < 4 bytes
    cmp ecx, 0x10
    jb .tail

    ; check for case 3
    cmp edi, esi
    ja .reverse
    ; predecrement
    sub ecx, 0x10
  .forward_copy_loop:
    sub ecx, 0x10
    ; move in 4x4 groups
    ; load
    mov eax, [esi + 0]
    mov ebx, [esi + 4]
    mov edx, [esi + 8]
    mov ebp, [esi + 12]
    lea esi, [esi + 16] ; equivalent to add esi, 16 but lea is faster
    ; store
    mov [edi + 0],  eax
    mov [edi + 4],  ebx
    mov [edi + 8],  edx
    mov [edi + 12], ebp
    lea edi, [edi + 16]
    ; if the sub ecx, 0x10 didn't underflow, loop
    jae .forward_copy_loop
    add ecx, 0x10
    jmp .tail
  
  .reverse:
    ; start at tail of src/dest
    add edi, ecx
    add esi, ecx
    ; predecrement
    sub ecx, 0x10
  .reverse_copy_loop:
    sub ecx, 0x10
    ; move in 4x4 groups
    ; load
    mov eax, [esi - 0]
    mov ebx, [esi - 4]
    mov edx, [esi - 8]
    mov ebp, [esi - 12]
    lea esi, [esi - 16] ; equivalent to add esi, 16 but lea is faster
    ; store
    mov [edi - 0],  eax
    mov [edi - 4],  ebx
    mov [edi - 8],  edx
    mov [edi - 12], ebp
    lea edi, [edi - 16]
    jae .reverse_copy_loop
  
    ; .tail only handles forward copy, fix pointers
    add ecx, 0x10
    sub edi, ecx
    sub esi, ecx

  .tail:
    ; it's not really worth doing optimizations here for up to 16 bytes
    rep movsb
    
    pop esp
    pop esi
    pop edi
    pop ebx
    pop ebp

    ret

; cases:
;   1. dest < src   => copy 4 bytes at a time with no issues
;   2. dest == src  => return
;   3. dest > src   => start at tail