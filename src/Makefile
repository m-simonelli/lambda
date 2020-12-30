all:
	$(error Please specify either bios or uefi make rule!)

bios:
	$(MAKE) -C loader bios

bios_clean:
	$(MAKE) -C loader bios_clean

uefi:
	$(MAKE) -C loader uefi

uefi_clean:
	$(MAKE) -C loader uefi_clean

clean: uefi_clean bios_clean
.PHONY: uefi bios