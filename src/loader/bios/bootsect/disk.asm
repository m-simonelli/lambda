[bits 16]

; extended disk read - int 0x13 ah 0x42
; EAX: sector to read
; ES: buffer segment to write to
; BX: buffer offset to write to
; CX: amount of segments to be read
lba_sector_read:
    pusha
    
    ; set buf segment
    push es
    pop word [da_packet.bufseg]
    ; set buf offset
    mov [da_packet.bufoff], bx
    ; set sector to read
    mov [da_packet.blknum], eax
    ; set amount of segments
    mov [seg_count], cx

    ; in case carry was somehow set
    clc

  .loop:
    ; now read
    mov esi, da_packet
    mov ah, 0x42

    int 0x13
    jc .exit

    ; update vars
    add word [da_packet.bufoff], 512
    inc dword [da_packet.blknum]
    dec word [seg_count]
    ; if nz, there are more sectors to read. rinse and repeat until done
    jnz .loop
    
  .exit:
    popa
    ret

fix_disk_num:
    ; apparently some bioses make a mess of drive numbers so we need to
    ; fix it ourselves
    pusha
    
    ; assume that drives <0x80 are invalid
    cmp dl, 0x80
    jb .fix_drive_num

    ; drives >0x90 are also invalid
    cmp dl, 0x90
    jb .fine

  .fix_drive_num:
    ; uh oh
    ; hope that 0x80 is the right drive /shrug
    mov byte [drive_num], 0x80

  .fine:
    popa
    mov dl, [drive_num]
    ret

check_drive_ext_supported:
    ; check if int 13h supports extended read/write
    ; hcf on error
    mov ah, 0x41
    mov dl, [drive_num]
    mov bx, 0x55AA
    int 0x13

    ; on success:
    ;   carry is cleared
    ;   bx is set to 0xAA55
    ;   cx has bit 0, 1 and 2 set depending on features supported. we care about bit 1
    jc .err
    cmp bx, 0xAA55
    jne .err
    test cx, 0x1
    jz .err

    ; all good!
    ret
  .err:
    call rm_err

align 4
; 16 byte packet size
; 1 block count
; seg:off passed in es:bx
; segcount passed in cx
; eax lba sector to be loaded
da_packet:
    .size:      db 0x10 
    .reserved   db 0
    .blkcnt:    dw 1
    .bufoff:    dw 0
    .bufseg:    dw 0
    .blknum:    dd 0
    .blknumhi:  dd 0

seg_count: dd 0
drive_num: db 0