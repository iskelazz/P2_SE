TOOLCHAIN=~/toolchain/gcc-arm-none-eabi-4_9-2014q4/bin
PREFIX=$(TOOLCHAIN)/arm-none-eabi-

ARCHFLAGS=-mthumb -mcpu=cortex-m0plus -std=c99
COMMONFLAGS=-g3 -Og -Wall -Werror $(ARCHFLAGS)


CFLAGS=-I./includes/ -I./drivers -DCPU_MKL46Z256VLH4 $(COMMONFLAGS) 

LDFLAGS=$(COMMONFLAGS) -T link.ld  --specs=nano.specs  -Wl,--gc-sections,-Map,$(TARGET).map
LDLIBS= 

CC=$(PREFIX)gcc
LD=$(PREFIX)gcc
OBJCOPY=$(PREFIX)objcopy
SIZE=$(PREFIX)size
RM=rm -f

TARGET_HELLO=hello_world
TARGET_LED=led_blinky

SRC_HELLO=$(wildcard led_blinky.c startup.c pin_mux_led.c drivers/*.c)
SRC_LED=$(wildcard hello_world.c startup.c pin_mux_hello.c drivers/*.c)

OBJ_HELLO=$(patsubst %.c, %.o, $(SRC_HELLO))
OBJ_LED=$(patsubst %.c, %.o, $(SRC_LED))

SRC = $(wildcard board/src/*.c  CMSIS/*.c drivers/*.c utilities/*.c)
OBJ_SRC = $(patsubst %.c, %.o, $(SRC))

all: all_led all_hello

all_hello :  build_hello size_hello
build_hello : elf_hello srec_hello bin_hello
elf_hello: $(TARGET_HELLO).elf
srec_hello: $(TARGET_HELLO).srec
bin_hello: $(TARGET_HELLO).bin


all_led:  build_led size_led
build_led: elf_led srec_led bin_led
elf_led: $(TARGET_LED).elf
srec_led: $(TARGET_LED).srec
bin_led: $(TARGET_LED).bin

clean:
	$(RM) $(TARGET_HELLO).srec $(TARGET_HELLO).elf $(TARGET_HELLO).bin $(TARGET_HELLO).map $(OBJ_HELLO) $(TARGET_LED).srec $(TARGET_LED).elf $(TARGET_LED).bin $(TARGET_LED).map $(OBJ_LED)

$(TARGET_HELLO).elf: $(OBJ_HELLO) 
	$(LD) $(LDFLAGS)  $(OBJ_HELLO) $(LDLIBS) -o $@
	
$(TARGET_LED).elf: $(OBJ_LED) 
	$(LD) $(LDFLAGS)  $(OBJ_LED) $(LDLIBS) -o $@

%.bin: %.elf
	    $(OBJCOPY) -O binary $< $@
	    
%.srec: %.elf
	$(OBJCOPY) -O srec $< $@
	    
size_hello:
	$(SIZE) $(TARGET_HELLO).elf
size_led:
	$(SIZE) $(TARGET_LED).elf

flash_led: all_hello
	openocd -f openocd.cfg -c "program $(TARGET_LED).elf verify reset exit"
flash_hello: all_led
	openocd -f openocd.cfg -c "program $(TARGET_HELLO).elf verify reset exit"
	



