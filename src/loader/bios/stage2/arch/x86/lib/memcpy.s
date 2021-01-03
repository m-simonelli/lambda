; memcpy.S
; Copyright Marco Simonelli 2020
; You are free to redistribute/modify this code under the 
; terms of the GPL version 3 (see the file LICENSE)

[bits 32]
global memcpy

memcpy:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]  ; dest
    mov edx, [ebp + 12] ; src
    mov ecx, [ebp + 16] ; cnt

    push ebp ; ebp gets clobbered, this should get popped to esp in epilogue
    push ebx
    push edi
    push esi
    push eax ; rval

    mov edi, eax ; dest
    mov esi, edx ; src

    ; for the case when cnt < 16 bytes
    cmp ecx, 16
    jb .tail

    ; check for case 2
    cmp edi, esi
    ja .reverse
    ; predecrement
    lea ecx, [ecx - 16]

    align 16 ; Assembly/Compiler Coding Rule 12 - All branch targets should be 16-byte aligned.
  .forward_copy_loop:
    sub ecx, 16
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
    lea ecx, [ecx + 16]
    jmp .tail
  
    align 16
  .reverse:
    ; start at tail of src/dest
    add edi, ecx
    add esi, ecx
    ; predecrement
    lea ecx, [ecx - 16]

    align 16
  .reverse_copy_loop:
    sub ecx, 16
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
    lea ecx, [ecx + 16]
    sub edi, ecx
    sub esi, ecx

    align 16
  .tail:
    ; it's not really worth doing optimizations here for up to 16 bytes

    ; todo: on second thought, it might actually be worth it since rep when
    ; ecx < 64 induces large performance penalties
    rep movsb
    
    pop eax ; rval
    pop esp ; from push ebp
    pop esi
    pop edi
    pop ebx
    pop ebp

    ret

; cases:
;   1. dest < src   => copy 4 bytes at a time with no issues
;   2. dest > src   => start at tail