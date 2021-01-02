/*
 *  entry.c
 *  Copyright Marco Simonelli 2020
 *  You are free to redistribute/modify this code under the
 *  terms of the GPL version 3 (see the file LICENSE)
 */

#include <efi.h>
#include <efilib.h>
#include <lambda.h>

EFI_STATUS
EFIAPI
efi_main(EFI_HANDLE im_hdl, EFI_SYSTEM_TABLE *sys_tbl) {
    InitializeLib(im_hdl, sys_tbl);
    Print(L"lambda<UEFI>: loaded\n");
    Print(L"%s\n", lambda_logo);
    return EFI_SUCCESS;
}