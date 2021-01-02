# Makefile
# Copyright Marco Simonelli 2020
# You are free to redistribute/modify this code under the
# terms of the GPL version 3 (see the file LICENSE)

all: bios uefi

bios:
	$(MAKE) -C bios
uefi:
	$(MAKE) -C uefi

bios_clean:
	$(MAKE) -C bios clean
uefi_clean:
	$(MAKE) -C uefi clean

run_bios:
	$(MAKE) -C bios run
run_uefi:
	$(MAKE) -C uefi run

.PHONY: uefi bios