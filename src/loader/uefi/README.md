to build, simply:
    make

to run in qemu:
    make run

to run in qemu over a fake usb:
    make run_qemu_usb

autoboot doesn't work right now, so run:
    1. wait for pxe/http boot to finish (or move efi shell to top in boot settings)
    2. once in efi shell do:
        1. fs0:
        2. cd EFI\BOOT
        3. BOOTX64.EFI