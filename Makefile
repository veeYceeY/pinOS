asm: src/boot.s
	riscv64-unknown-elf-as src/boot.s -o boot.o

link: asm kernel.lds
	riscv64-unknown-elf-ld -T kernel.lds boot.o -o kernel.elf

build: link

run: link
	qemu-system-riscv64 -machine virt -cpu rv64 -smp 4 -m 128M -serial mon:stdio -bios none -kernel kernel.elf

runo: 
	qemu-system-riscv64 -machine virt -cpu rv64 -smp 4 -m 128M -serial mon:stdio -bios none -kernel kernel.elf

