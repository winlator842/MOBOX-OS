static const char* BOOT_BANNER = 
    "                                \n"
    "   MOBOX OS  v0.1              \n"
    "   MODOS - Mode of MOBOX       \n"
    "   Boot successful!            \n"
    "                                \n";

static volatile unsigned short* const VGA_BUFFER = (unsigned short*)0xB8000;
static int cursor_x = 0;
static int cursor_y = 0;
static unsigned char color = 0x0A;

static void terminal_scroll(void) {
    int i;
    if (cursor_y < 25) {
        return;
    }
    for (i = 0; i < 24 * 80; i++) {
        VGA_BUFFER[i] = VGA_BUFFER[i + 80];
    }
    for (i = 24 * 80; i < 25 * 80; i++) {
        VGA_BUFFER[i] = (color << 8) | ' ';
    }
    cursor_y = 24;
}

static void terminal_putc(char c) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
        terminal_scroll();
        return;
    }
    VGA_BUFFER[cursor_y * 80 + cursor_x] = (color << 8) | c;
    cursor_x++;
    if (cursor_x >= 80) {
        cursor_x = 0;
        cursor_y++;
        terminal_scroll();
    }
}

static void terminal_writestring(const char* str) {
    while (*str) {
        terminal_putc(*str);
        str++;
    }
}

void kernel_entry(void) {
    int i = 0;
    for (i = 0; i < 25 * 80; i++) {
        VGA_BUFFER[i] = (color << 8) | ' ';
    }
    terminal_writestring(BOOT_BANNER);
    while (1) {
        __asm__ volatile("hlt");
    }
}
