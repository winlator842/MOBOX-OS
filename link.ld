ENTRY(kernel_entry)

SECTIONS
{
    . = 0x10000;
    .text : ALIGN(4)
    {
        *(.text*)
        *(.rodata*)
    }
    .data : ALIGN(4)
    {
        *(.data*)
    }
    .bss : ALIGN(4)
    {
        *(COMMON)
        *(.bss*)
    }
}
