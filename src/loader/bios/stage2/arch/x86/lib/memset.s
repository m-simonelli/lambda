; memcpy.S
; Copyright Andrew De Leonardis 2020
; Copyright Marco Simonelli 2020
; You are free to redistribute/modify this code under the
; terms of the GPL version 3 (see the file LICENSE)

[bits 32]
global memset

memset:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]  ; dst
    mov edx, [ebp + 12] ; val
    mov ecx, [ebp + 16] ; count

    push edi
    push esi
    mov esi, eax

    ; count == 0
    test ecx, ecx
    jz .done 

    ; align dst to 4 byte boundary
    test eax, 3
    jnz .fix_align

  .align_fixed:
    ; count < 32
    test ecx, ~31
    jz .loop_1byte

    ; zero extend val into edx
    movzx edx, dl
    mov edi, 0x01010101
    imul edx, edi

    align 16
  .loop_32bytes:
    sub ecx, 32
    mov DWORD [eax],      edx
    mov DWORD [eax + 4],  edx
    mov DWORD [eax + 8],  edx
    mov DWORD [eax + 12], edx
    mov DWORD [eax + 16], edx
    mov DWORD [eax + 20], edx
    mov DWORD [eax + 24], edx
    mov DWORD [eax + 28], edx
    lea eax, [eax + 32]
    jae .loop_32bytes
    lea ecx, [ecx + 32]

    align 16
  .loop_1byte:
    sub ecx, 1
    mov BYTE [eax], dl
    lea eax, [eax + 1]
    jae .loop_1byte
    lea ecx, [ecx + 1]

    align 16
  .done:
    pop esi
    pop edi
    pop ebp

    mov eax, esi ; rval
    ret

    align 16
  .fix_align:
    ; align dst to be 4 byte aligned
    lea ecx, [ecx - 1]
    mov BYTE [eax], dl
    lea eax, [eax - 1]
    test eax, 3
    jnz .fix_align
    jmp .align_fixed
    