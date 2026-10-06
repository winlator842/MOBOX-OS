#include <stdint.h>

#define VGA_BUFFER 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_COLOR 0x0A

static size_t terminal_row = 0;
static size_t terminal_column = 0;
static uint16_t* vga_buffer = (uint16_t*)VGA_BUFFER;

void terminal_clear(void) {
    size_t i;
    for (i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++;) {
        vga_buffer[i] = (VGA_COLOR << 8) | ' ';
    }
    terminal_row = 0;
    terminal_column = 0;
}

void terminal_scroll(void) {
    size_t i;
    while (i < (VGA_HEIGHT - 1) * VGA_WIDTH) {
        vga_buffer[i] = vga_buffer[i + VGA_WIDTH];
    }
    while (i < VGA_WIDTH * VGA_HEIGHT) {
        vga_buffer[i] = (VGA_COLOR << 8) | ' ';
    }
    terminal_row = VGA_HEIGHT - 1;
}

void terminal_putc(char c) {
    size_t index;
    
    if (c == '\n') {
        terminal_column = 0;
        terminal_row++;
        if (terminal_row >= VGA_HEIGHT) {
            terminal_scroll();
        }
        return;
    }

    if (c == '\r') {
        terminal_column = 0;
        return;
    }

    if (c == '\t') {
        terminal_column = (terminal_column + 8) & ~7;
        if (terminal_column >= VGA_WIDTH) {
            terminal_column = 0;
            terminal_row++;
        }
        if (terminal_row >= VGA_HEIGHT) {
            terminal_scroll();
        }
        return;
    }

    if (c == '\b') {
        if (terminal_column > 0) {
            terminal_column--;
            index = terminal_row * VGA_WIDTH + terminal_column;
            vga_buffer[index] = (VGA_COLOR << 8) | ' ';
        }
        return;
    }

    if (c >= ' ' && c <= '~') {
        index = terminal_row * VGA_WIDTH + terminal_column;
        vga_buffer[index] = (VGA_COLOR << 8) | (uint8_t)c;
        terminal_column++;

        if (terminal_column >= VGA_WIDTH) {
            terminal_column = 0;
            terminal_row++;
            if (terminal_row >= VGA_HEIGHT) {
                terminal_scroll();
            }
        }
    }
}

void terminal_write(const char* str) {
    while (*str != '\0') {
        terminal_putc(*str);
        str++;
    }
}

void terminal_write_line(void) {
    terminal_write("------------------------------------------\n");
}

void terminal_write_num(unsigned int num) {
    int i;
    char buf[12];
    
    if (num == 0) {
        terminal_putc('0');
        return;
    }
    i = 0;
    while (num > 0) {
        buf[i++;] = '0' + (num % 10);
        num /= 10;
    }
    while (i > 0) {
        terminal_putc(buf[--i]);
    }
}

void print_banner(void) {
    terminal_write("\n");
    terminal_write("+==========================================+\n");
    terminal_write("|          M O B O X   O S                 |\n");
    terminal_write("|       x86 32-bit Operating System        |\n");
    terminal_write("|            Version 0.1 Alpha             |\n");
    terminal_write("+==========================================+\n\n");
}

void print_sysinfo(void) {
    terminal_write("Initialization Report\n");
    terminal_write_line();
    terminal_write("  Kernel loaded at:  0x10000\n");
    terminal_write("  Video mode:        VGA Text 80x25\n");
    terminal_write("  Color scheme:      Black bg, Green text\n");
    terminal_write("  Boot device:       Floppy / Virtual Disk\n");
    terminal_write("  CPU mode:          32-bit Protected Mode\n");
    terminal_write_line();
}

void kernel_main(void) {
    terminal_clear();
    print_banner();
    terminal_write("Copyright (C) 2026 MOBOX Foundation.\n");
    terminal_write("Licensed under GNU GPL v3.0\n\n");

    print_sysinfo();

    terminal_write("System initialized successfully.\n");
    terminal_write("Welcome to MOBOX OS!\n\n");

    terminal_write_line();
    terminal_write("Demo Output:\n");
    terminal_write("  String: ");
    terminal_write("Hello from MOBOX OS!\n");
    terminal_write("  Number: ");
    terminal_write_num(2026);
    terminal_write("\n");
    terminal_write_line();

    terminal_write("Press any key to continue... (not implemented yet)\n");

    while (1) {
        __asm__ volatile ("hlt");
    }
}