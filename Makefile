
PREF := riscv64-unknown-elf-

CC      = $(PREF)gcc
OBJCOPY = $(PREF)objcopy
OBJDUMP = $(PREF)objdump

CFLAGS := -nostartfiles -march=rv64imafdc -mabi=lp64d -Wall -O0

LINKER_SCRIPT := ../../tests/env_comp_cva6/cva6SDRAM.ld
SRC := main

build/cva6-$(SRC).hex: build/$(SRC).hex
	cd build && \
	$(OBJCOPY) -I ihex -O binary $(SRC).hex $(SRC).bin && \
		hexdump -v -e '"%08x\n"' $(SRC).bin > cva6-$(SRC).hex

build/$(SRC).hex: build/$(SRC).elf
	cd build && \
	$(OBJCOPY) $(SRC).elf -O ihex $(SRC).hex && \
	$(OBJDUMP)  -D -h -S  $(SRC).elf > $(SRC).dump

build/$(SRC).elf: build/$(SRC).o
	cd build && \
	$(CC) $(CFLAGS) -T $(LINKER_SCRIPT) $(SRC).o -o $(SRC).elf

build/$(SRC).o: build
	$(CC) $(CFLAGS) -c $(SRC).c -o ./build/$(SRC).o

build:
	mkdir -p build

clean:
	rm -rf build

.PHONY: clean