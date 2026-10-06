/* MOBOX OS 链接器脚本 */
/* 内核加载到物理地址 0x10000（64KB处） */

ENTRY(kernel_entry)

SECTIONS {
    . = 0x10000;

    .text : ALIGN(4) {
        *(.text)
        *(.rodata)
    }

    .data : ALIGN(4) {
        *(.data)
    }

    .bss : ALIGN(4) {
        *(.bss)
    }

    _end = .;
}