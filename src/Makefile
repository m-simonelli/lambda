# Makefile
# Copyright Marco Simonelli 2020
# You are free to redistribute/modify this code under the
# terms of the GPL version 3 (see the file LICENSE)

all: bios uefi

bios:
	$(MAKE) -C loader bios
uefi:
	$(MAKE) -C loader uefi

uefi_clean:
	$(MAKE) -C loader uefi_clean
bios_clean:
	$(MAKE) -C loader bios_clean

run_bios:
	$(MAKE) -C loader run_bios
run_uefi:
	$(MAKE) -C loader run_uefi

clean: uefi_clean bios_clean

.PHONY: uefi bios