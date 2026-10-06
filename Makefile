# MOBOX OS Makefile
# 一键编译

CC = clang
ASM = nasm
LD = ld

CFLAGS = -ffreestanding -nostdlib -m32 -Wall -Wextra
LDFLAGS = -m elf_i386 -T link.ld -nostdlib

all: mobox_os.img

# 编译引导扇区
boot.bin: boot.asm
	$(ASM) -f bin boot.asm -o boot.bin

# 编译内核C代码
kernel.o: kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o kernel.o

# 链接内核
kernel.bin: kernel.o link.ld
	$(LD) $(LDFLAGS) kernel.o -o kernel.bin

# 合并引导扇区和内核
mobox_os.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > mobox_os.img
	@echo ""
	@echo "====================================="
	@echo "  MOBOX OS build successful!"
	@echo "  Image: mobox_os.img"
	@echo "  Size:
$$
(wc -c < mobox_os.img) bytes"
	@echo "====================================="

# 用QEMU运行
run: mobox_os.img

# 用Vectras VM挂载
vectras: mobox_os.img
	@echo "Copy mobox_os.img to Vectras VM storage"
	@echo "Set as floppy/first boot device"

# 清理
clean:
	rm -f *.bin *.o *.img

.PHONY: all run vectras clean