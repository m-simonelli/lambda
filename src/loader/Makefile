all: bios uefi

bios:
	$(MAKE) -C bios

bios_clean:
	$(MAKE) -C bios clean

uefi:
	$(MAKE) -C uefi

uefi_clean:
	$(MAKE) -C uefi clean

run_bios:
	$(MAKE) -C bios run
run_uefi:
	$(MAKE) -C uefi run

.PHONY: uefi bios