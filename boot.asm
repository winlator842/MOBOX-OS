; ============================================================
; MOBOX OS Bootloader
; 512字节引导扇区，从实模式切换到32位保护模式，跳转到C内核
; ============================================================

[org 0x7C00]
[bits 16]

; ============================================
; 引导扇区入口
; ============================================
cli                    ; 关中断
xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx
mov ss, ax
mov ds, ax
mov es, ax
mov sp, 0x7C00
sti                    ; 开中断

; ============================================
; 读内核到内存
; 从软盘第2扇区开始，读10个扇区到 0x10000
; ============================================
mov ah, 0x02           ; 读磁盘
mov al, 10             ; 读10个扇区
mov ch, 0              ; 磁道0
mov cl, 2              ; 扇区2
mov dh, 0              ; 磁头0
mov dl, 0x00           ; 驱动器0
mov bx, 0x0000         ; 偏移
mov ax, 0x1000         ; 段地址
mov es, ax
int 0x13               ; BIOS磁盘中断

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
jmp kernel_entry

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
; NULL描述符
dd 0x0
dd 0x0
; 代码段描述符
dw 0xFFFF
dw 0x0
db 0x0
db 10011010b
db 11001111b
db 0x0
; 数据段描述符
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

; ============================================
; 32位内核入口
; ============================================
[bits 32]
kernel_entry:
mov ax, DATA_SEG
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
mov esp, 0x1FFFF

; 跳转到C内核
extern kernel_main
call kernel_main

; 死循环
.hang:
hlt
jmp .hang
