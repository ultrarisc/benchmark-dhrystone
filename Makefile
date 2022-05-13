DHRY-LFLAGS =

DHRY-CFLAGS := -DTIME -DNOENUM -Wno-implicit -save-temps
DHRY-CFLAGS += -fno-builtin-printf -fno-common -falign-functions=4

#Uncomment below for FPGA run, default DHRY_ITERS is 2000 for RTL
DHRY-CFLAGS += -DDHRY_ITERS=200000000

SRC = dhry_1.c dhry_2.c #strcmp.S
HDR = dhry.h

override CFLAGS += $(DHRY-CFLAGS) $(XCFLAGS) -Xlinker --defsym=__stack_size=0x800 -Xlinker --defsym=__heap_size=0x1000
all: dhrystone-o2 dhrystone-o3 dhrystone-o2-lto dhrystone-o2-noinline
dasm: dhrystone-o2 dhrystone-o3 dhrystone-o2-lto dhrystone-o2-noinline
	$(OBJDUMP) -dj .text dhrystone-o2 > dhrystone-o2.d
	$(OBJDUMP) -dj .text dhrystone-o3 > dhrystone-o3.d
	$(OBJDUMP) -dj .text dhrystone-o2-lto > dhrystone-o2-lto.d
	$(OBJDUMP) -dj .text dhrystone-o2-noinline > dhrystone-o2-noinline.d
dhrystone-o2: $(SRC) $(HDR)
	$(CC) $(CFLAGS) -O2 $(SRC) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) -o $@
dhrystone-o3: $(SRC) $(HDR)
	$(CC) $(CFLAGS) -O3 $(SRC) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) -o $@
dhrystone-o2-lto: $(SRC) $(HDR)
	$(CC) $(CFLAGS) -O2 -flto $(SRC) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) -o $@
dhrystone-o2-noinline: $(SRC) $(HDR)
	$(CC) $(CFLAGS) -O2 -fno-inline $(SRC) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) -o $@
benchmark: all
	./dhrystone-o2 | grep "Dhrystones"| sed "s/Dhrystones per Second://g"|awk '{$$1=$$1;print}'
	./dhrystone-o3 | grep "Dhrystones"| sed "s/Dhrystones per Second://g"|awk '{$$1=$$1;print}'
	./dhrystone-o2-lto | grep "Dhrystones"| sed "s/Dhrystones per Second://g"|awk '{$$1=$$1;print}'
	./dhrystone-o2-noinline | grep "Dhrystones"| sed "s/Dhrystones per Second://g"|awk '{$$1=$$1;print}'

clean:
	rm -f *.i *.s *.o dhrystone* dhrystone*.hex *.res

