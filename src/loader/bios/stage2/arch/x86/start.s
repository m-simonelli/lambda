; start.asm
; Copyright Marco Simonelli 2020
; You are free to redistribute/modify this code under the 
; terms of the GPL version 3 (see the file LICENSE)

%define s2_vaddr 0xFFFFFFFFC0000000

%include "arch/x86/lib/gdt.inc"

global start
global halt

[bits 32]
[extern entry]
[extern bss_begin]
[extern bss_end]

section .text
start:
    mov ebp, 0x90000
    mov esp, ebp

    call assert_cpuid_availability

; ################## null the bss segment
    ; extern void *bss_begin;
    ; extern void *bss_end;
    ;
    ; long *bss = (long *)bss_begin;
    ; size_t count = (size_t)bss_end - (size_t)bss_begin;
    ; int rem = count % 4;
    ; 
    ; while (count--)
    ;     bss[count] = 0;
    ; 
    ; switch (count % 4) {
    ;     case 3:
    ;         bss[2] = 0; /* fallthrough */
    ;     case 2:
    ;         bss[1] = 0; /* fallthrough */
    ;     case 1:
    ;         bss[0] = 0; /* fallthrough */
    ;     default:
    ;         break;
    ; }

    o16 push es                 ; stosb writes to es:edi
    xor eax, eax
    mov es, ax

    mov edi, bss_begin - s2_vaddr ; dest
    mov ecx, bss_end   - s2_vaddr
    sub ecx, bss_begin - s2_vaddr ; count
    mov edx, ecx
    and edx, 3                    ; ecx mod 4
    shr ecx, 2                    ; move 4 bytes at a time

    rep stosd

    lea ecx, [_start_null_bss_jmp_tbl - s2_vaddr]
    jmp DWORD [ecx + edx * 4]

  .null_bss_3_byte_left: ; jump table entry
    mov [edi + 2], eax
  .null_bss_2_byte_left: ; jump table entry
    mov [edi + 1], eax
  .null_bss_1_byte_left: ; jump table entry
    mov [edi + 0], eax
  .null_bss_0_byte_left: ; jump table entry
    ; restore es
    o16 pop es
; ################## end null bss
    
    lgdt [gdt.gdt_descriptor-s2_vaddr]
    call page_table_init

    ; far jmp to reload cs
    jmp 0x8:(goto_entry-s2_vaddr)


page_table_init:
    ; maps:
    ;   1. <virt>0->2MB                    to    <phys>0->2MB
    ;   2. <virt>s2_vaddr->s2_vaddr+2MB    to    <phys>0->2MB

    mov eax, PDP  - s2_vaddr
    mov ecx, KPDP - s2_vaddr
    mov edx, PD   - s2_vaddr
    mov edi, PT   - s2_vaddr

    or ax, 0x3
    or cx, 0x3
    or dx, 0x3
    or di, 0x3

    mov [PML4-s2_vaddr], eax
    mov [(PML4-s2_vaddr) + 511*8], ecx
    mov [PDP-s2_vaddr], edx
    mov [(KPDP-s2_vaddr) + 511*8], edx    ; map 2
    mov [PD-s2_vaddr], edi

    mov edi, PT-s2_vaddr
    
    ; map 1 (0->2MB to 0->2MB)
    ; eax, ebx, edx, and esi are entries in the page table
    mov eax, 0x0003
    mov ebx, 0x1003
    mov edx, 0x2003
    mov esi, 0x3003
    mov ecx, 512   ; only map first 2MB
  .buildpt:
    ; write the entries
    mov [edi + 0],  eax
    mov [edi + 8],  ebx
    mov [edi + 16], edx
    mov [edi + 24], esi

    ; increase the entries
    add eax, 0x4000
    add ebx, 0x4000
    add edx, 0x4000
    add esi, 0x4000

    ; increase index
    add edi, 32
    
    sub ecx, 4
    jnz .buildpt

    ; cr3 = PML4 base address
    xor eax, eax
    mov eax, PML4 - s2_vaddr
    mov cr3, eax

    ; enable PAE and PGE
    mov eax, cr4
    or eax, (1 << 5) | (1 << 7)
    mov cr4, eax

    ; enable long mode in EFER msr
    mov ecx, 0xc0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enable paging
    mov eax, cr0
    or eax, 1 | (1 << 31)
    mov cr0, eax

    ; stonks?
    ret

assert_cpuid_availability:
    push eax
    push ecx
    push edx

    ; eax = flags
    pushfd
    pop eax

    ; edx = flags
    mov edx, eax

    ; change id bit
    xor eax, 1 << 21

    ; eax -> stack -> flags -> stack -> eax
    ; if eax differs at the end then cpuid isn't supported
    push eax
    popfd
    pushfd
    pop eax

    ; restore flags
    push ecx
    popfd

    ; compare orig flags to eax
    cmp ecx, eax
    je .failed

  .check_effn:
    ; amd64 vol2 E.4.1
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .failed

    ; amd64 vol2 E.4.2
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .failed

    pop edx
    pop ecx
    pop eax
    ret

  .failed:
    ; todo: once again a terrible solution
    jmp halt

[bits 64]
goto_entry:
    ; set up segments for data
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rax, entry
    call rax

halt:
    ; this is quite frankly just a terrible to handle returns from entry (although that should never happen)
    ; todo: once acpi is implemented, replace this with an acpi shutdown
    nop
    jmp halt

section .bss
align 4096
global PML4
PML4:   resb 4096
global PDP
PDP:    resb 4096
global KPDP
KPDP:   resb 4096
global PD
PD:     resb 4096
global PT
PT:     resb 4096
global PMM_PD
PMM_PD: resb 4096

section .data
align 16

_start_null_bss_jmp_tbl:
    dd start.null_bss_0_byte_left - s2_vaddr
    dd start.null_bss_1_byte_left - s2_vaddr
    dd start.null_bss_2_byte_left - s2_vaddr
    dd start.null_bss_3_byte_left - s2_vaddr