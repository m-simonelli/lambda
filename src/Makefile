all: bios uefi
bios:
	$(MAKE) -C loader bios

bios_clean:
	$(MAKE) -C loader bios_clean

uefi:
	$(MAKE) -C loader uefi

uefi_clean:
	$(MAKE) -C loader uefi_clean

run_bios:
	$(MAKE) -C loader run_bios
run_uefi:
	$(MAKE) -C loader run_uefi

clean: uefi_clean bios_clean
.PHONY: uefi bios