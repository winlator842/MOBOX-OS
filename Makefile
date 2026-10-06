.PHONY: all clean

CC=clang
CFLAGS=--target=i386 -ffreestanding -fno-stack-protector -nostdlib
LD=ld
LDFLAGS=-m elf_i386

all: mobox_os.img mobox_os.iso

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o kernel.o

kernel.bin: kernel.o link.ld
	$(LD) $(LDFLAGS) -T link.ld -o kernel.bin kernel.o

mobox_os.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > mobox_os.img

mobox_os.iso: mobox_os.img
	mkdir -p iso_root
	cp mobox_os.img iso_root/mobox_os.img
	xorriso -as mkisofs \
		-o mobox_os.iso \
		-b mobox_os.img \
		-no-emul-boot \
		-boot-load-size 1 \
		-boot-info-table \
		iso_root

clean:
	rm -f boot.bin kernel.o kernel.bin mobox_os.img mobox_os.iso
	rm -rf iso_root
