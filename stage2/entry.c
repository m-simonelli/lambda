#include <drivers/display/vga/vga.h>

void entry() {
    vga_print("test\n");
    while(1);
}