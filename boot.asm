; MOBOX OS - 引导扇区
; 16位实模式，加载内核后跳转到32位保护模式

[org 0x7c00]
[bits 16]

start:
    ; 初始化段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; BIOS清屏（VGA文本模式）
    mov ax, 0x0003
    int 0x10

    ; 打印启动信息
    mov si, boot_msg
    call print_string

    ; 从软盘加载内核（第2扇区开始，读16个扇区=8KB）
    mov dl, [BOOT_DRIVE]
    mov ah, 0x02      ; BIOS读扇区
    mov al, 16        ; 读16个扇区
    mov ch, 0         ; 柱面0
    mov cl, 2         ; 扇区2（扇区1是引导区）
    mov dh, 0         ; 磁头0
    mov bx, 0x1000    ; 加载到0x1000:0x0000=物理地址0x10000
    int 0x13
    jc disk_error     ; 读失败跳转

    ; 切换到32位保护模式
    cli               ; 关中断
    lgdt [gdt_descriptor]  ; 加载GDT表
    mov eax, cr0
    or al, 1          ; 设置CR0的最低位（保护模式位）
    mov cr0, eax
    jmp CODE_SEG:kernel_entry  ; 远跳到32位代码

; 打印字符串（BIOS中断10h，AH=0E）
print_string:
    pusha
.print_loop:
    lodsb             ; 从SI读取一个字节到AL
    or al, al         ; 检查是否为0（字符串结束）
    jz .done          ; 是则结束
    mov ah, 0x0e      ; BIOS打印字符功能
    int 0x10
    jmp .print_loop
.done:
    popa
    ret

; 磁盘错误处理
disk_error:
    mov si, disk_err_msg
    jmp .halt
.halt:
    jmp .halt

; 数据区
BOOT_DRIVE equ 0x7c00 + 0x40
boot_msg db "MOBOX OS is booting...", 13, 10, 0
disk_err_msg db "Disk Read Error! Press Ctrl+Alt+Del", 0

; GDT - 全局描述符表（保护模式必需）
gdt_start:
    ; 空描述符
    dq 0
    ; 代码段描述符（基址0, 限4GB, 可执行, 读）
    dw 0xffff
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0
    ; 数据段描述符（基址0, 限4GB, 可读写）
    dw 0xffff
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

; 填充到510字节
times 510-($-
$$
) db 0
) db 0
; 引导签名（0x55AA）
dw 0xaa55

; 32位入口点（链接器会在这里放置内核）
[bits 32]
kernel_entry:
    ; 初始化段寄存器
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x1FFFF  ; 栈顶

    ; 跳到C内核
    extern kernel_main
    call kernel_main

    ; 死循环（不应到达这里）
.halt:
    hlt
    jmp .halt
