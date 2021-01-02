; memcpy.S
; Copyright Andrew De Leonardis 2020
; Copyright Marco Simonelli 2020
; You are free to redistribute/modify this code under the
; terms of the GPL version 3 (see the file LICENSE)

memset:
    pop eax ; dst
    pop edx ; val
    pop ecx ; count

    push ebp
    push ebx
    push edi
    push esi

    ; count == 0
    test ecx, ecx
    jz .done 

    ; align dst to 4 byte boundary
    test ecx, 3
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
    mov DWORD [eax],      edx
    mov DWORD [eax + 4],  edx
    mov DWORD [eax + 8],  edx
    mov DWORD [eax + 12], edx
    mov DWORD [eax + 16], edx
    mov DWORD [eax + 20], edx
    mov DWORD [eax + 24], edx
    mov DWORD [eax + 28], edx
    sub ecx, 32
    jae .loop_32bytes

    align 16
  .loop_1byte:
    mov BYTE [eax], dl
    sub ecx, 1
    jae .loop_1byte

    align 16
  .done:
    pop esi
    pop edi
    pop ebx
    pop ebp

    ret

    align 16
  .fix_align:
    ; align dst to be 4 byte aligned
    mov BYTE [eax], dl
    lea ecx, [ecx - 1]
    test ecx, 3
    jnz .fix_align
    jmp .align_fixed
    