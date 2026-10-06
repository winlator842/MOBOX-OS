; ============================================================
; MOBOX OS Bootloader
; ============================================================

[org 0x7C00]
[bits 16]

jmp start

; ========== GDT ==========
gdt_start:
    dd 0x0
    dd 0x0
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

start:
    cli
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x7C00
    sti

    ; ===== 串口初始化 =====
    mov dx, 0x3F8 + 1
    mov ax, 0
    out dx, ax
    mov dx, 0x3F8 + 3
    mov al, 10000011b
    out dx, al
    mov dx, 0x3F8
    mov al, 1
    out dx, al
    mov dx, 0x3F8 + 3
    mov al, 0x03
    out dx, al

    ; ===== 输出 'B' 到串口 =====
    mov dx, 0x3F8
    mov al, 'B'
    out dx, al

    ; ===== 读内核（8个扇区）=====
    pusha
    mov ah, 0x02
    mov al, 8
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x00
    mov bx, 0x0000
    mov ax, 0x1000
    mov es, ax
    int 0x13
    jc disk_error
    test ah, ah
    jnz disk_error
    popa

    ; ===== 切换保护模式 =====
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp CODE_SEG:init_32bit

[bits 32]
init_32bit:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 0x1FFFF

    ; 串口输出 'B'（32位）
    mov dx, 0x3F8
    mov al, 'B'
    out dx, al

    jmp 0x10000

disk_error:
    mov si, disk_error_msg
    mov ah, 0x0E
    mov bh, 0
.loop:
    lodsb
    test al, al
    jz .halt
    int 0x10
    jmp .loop
.halt:
    cli
    hlt

disk_error_msg db "Disk error!", 0

times 510-($-$$) db 0
dw 0xAA55
