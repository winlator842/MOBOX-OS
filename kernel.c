#include <stdint.h>

#define VGA_BUFFER 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_COLOR 0x0F

struct vga_char {
    uint8_t character;
    uint8_t color;
};

static struct vga_char *vga_buffer = (struct vga_char *)VGA_BUFFER;
static int cursor_row = 0;
static int cursor_col = 0;

static void terminal_clear(void) {
    int i = 0;
    while (i < VGA_WIDTH * VGA_HEIGHT) {
        vga_buffer[i].character = ' ';
        vga_buffer[i].color = VGA_COLOR;
        i++;
    }
    cursor_row = 0;
    cursor_col = 0;
}

static void terminal_newline(void) {
    int i, j;
    cursor_col = 0;
    cursor_row++;
    if (cursor_row >= VGA_HEIGHT) {
        i = 0;
        while (i < VGA_HEIGHT - 1) {
            j = 0;
            while (j < VGA_WIDTH) {
                vga_buffer[i * VGA_WIDTH + j] = vga_buffer[(i + 1) * VGA_WIDTH + j];
                j++;
            }
            i++;
        }
        j = 0;
        while (j < VGA_WIDTH) {
            vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + j].character = ' ';
            vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + j].color = VGA_COLOR;
            j++;
        }
        cursor_row = VGA_HEIGHT - 1;
    }
}

static void terminal_putc(char c) {
    if (c == '\n') {
        terminal_newline();
    } else if (c == '\r') {
        cursor_col = 0;
    } else if (c == '\t') {
        cursor_col = (cursor_col + 8) & ~7;
        if (cursor_col >= VGA_WIDTH) {
            terminal_newline();
        }
    } else if (c == '\b') {
        if (cursor_col > 0) {
            cursor_col--;
            vga_buffer[cursor_row * VGA_WIDTH + cursor_col].character = ' ';
        }
    } else {
        vga_buffer[cursor_row * VGA_WIDTH + cursor_col].character = c;
        vga_buffer[cursor_row * VGA_WIDTH + cursor_col].color = VGA_COLOR;
        cursor_col++;
        if (cursor_col >= VGA_WIDTH) {
            terminal_newline();
        }
    }
}

static void terminal_write(const char *str) {
    while (*str) {
        terminal_putc(*str);
        str++;
    }
}

void kernel_entry(void) {
    terminal_clear();
    
    terminal_write("========================================\n");
    terminal_write("       MOBOX OS v0.1 booting...\n");
    terminal_write("       Welcome to MOBOX OS!\n");
    terminal_write("========================================\n\n");
    terminal_write("MOBOX OS kernel loaded successfully!\n");
    terminal_write("VGA text mode: 80x25, color enabled\n");
    terminal_write("Memory: Protected mode 32-bit\n\n");
    terminal_write("System ready.\n");
    
    while (1) {
        __asm__ __volatile__("hlt");
    }
}
