; ============================================================
; MOBOX OS Bootloader
; 512字节引导扇区，从实模式切换到32位保护模式
; ============================================================

[org 0x7C00]
[bits 16]

; ============================================
; 引导扇区入口
; ============================================
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

; ============================================
; 读内核到内存
; 从软盘第2扇区开始，读10个扇区到 0x10000
; ============================================
mov ah, 0x02
mov al, 10
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

; ============================================
; 切换到32位保护模式
; ============================================
cli
lgdt [gdt_descriptor]
mov eax, cr0
or al, 1
mov cr0, eax
jmp CODE_SEG:init_32bit

; ============================================
; 32位模式代码
; ============================================
[bits 32]
init_32bit:
mov ax, DATA_SEG
mov ds, ax
mov ss, ax
mov es, ax
mov esp, 0x1FFFF
jmp 0x10000

; ============================================
; 死循环（磁盘错误时用）
; ============================================
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

; ============================================
; 填充到510字节，加上引导签名
; ============================================
times 510-($-$$) db 0
dw 0xAA55

; ============================================
; GDT（全局描述符表）
; ============================================
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
