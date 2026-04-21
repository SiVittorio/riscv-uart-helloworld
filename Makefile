PREF := riscv64-linux-gnu-

CC      = $(PREF)gcc
OBJCOPY = $(PREF)objcopy
OBJDUMP = $(PREF)objdump

CFLAGS := -g -nostartfiles -march=rv64imafdc -mabi=lp64d -Wall -O0 -nostdlib

SRC := test_uart_hello_world

build/sdram-$(SRC).hex: build/$(SRC).hex
	cd build && \
	$(OBJCOPY) -I ihex -O binary $(SRC).hex $(SRC).bin && \
		hexdump -v -e '"%08x\n"' $(SRC).bin > sdram-$(SRC).hex

build/$(SRC).hex: build/$(SRC).elf
	cd build && \
	$(OBJCOPY) $(SRC).elf -O ihex $(SRC).hex && \
	$(OBJDUMP)  -D -h -S  $(SRC).elf > $(SRC).dump

build/$(SRC).elf: build/$(SRC).o build/startup.o
	cd build && \
	$(CC) $(CFLAGS) -T ../src/sdram.ld $(SRC).o startup.o -o $(SRC).elf

build/$(SRC).o: build
	$(CC) $(CFLAGS) -c src/$(SRC).c -o ./build/$(SRC).o

build/startup.o: build src/startup.S
	$(CC) $(CFLAGS) -c src/startup.S -o ./build/startup.o

build:
	mkdir -p build

clean:
	rm -rf build

.PHONY: clean
