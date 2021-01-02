/*
 *  entry.c
 *  Copyright Marco Simonelli 2020
 *  You are free to redistribute/modify this code under the
 *  terms of the GPL version 3 (see the file LICENSE)
 */

#include <drivers/display/vga/vga.h>
#include <lambda.h>

void entry() {
    vga_init();
    vga_print("lambda<BIOS>: loaded stage2\n\n");
    vga_print(lambda_logo);
    while(1);
}