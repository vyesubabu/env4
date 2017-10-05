all: clean build install

clean:
	@echo "\n[CLEAN]\n"
	rm -f write_grib.exe

build:
	@echo "\n[BUILD]\n"
	gcc -g -Wall -o write_grib.exe write_grib.c -I/common/include/ -L/common/lib/ -lgrib_api -ljasper -lm

install:
	@echo "\n[INSTALL]\n"
