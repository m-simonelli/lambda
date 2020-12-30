#include <drivers/display/vga/vga.h>

void entry() {
    vga_init();
    vga_print("stage2 loaded!\n");
    while(1);
}