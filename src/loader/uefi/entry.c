#include <efi.h>
#include <efilib.h>

EFI_STATUS
EFIAPI
efi_main(EFI_HANDLE im_hdl, EFI_SYSTEM_TABLE *sys_tbl) {
    InitializeLib(im_hdl, sys_tbl);
    Print(L"UEFI loaded!\n");
    return EFI_SUCCESS;
}