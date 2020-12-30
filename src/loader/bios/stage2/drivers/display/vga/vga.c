#include <drivers/display/vga/vga.h>
#include <drivers/io/ports.h>
#include <lib/memcpy.h>
#include <stdbool.h>

static bool vga_did_init = false;
static char *const vga_mem = (char*)VGA_MEM;
static struct vga_cursor_pos vga_cursor_pos = {0};

void vga_init() {
    vga_did_init = true;

    /* Disable the hardware cursor */
    port_byte_out(VGA_CTRL_REG, 0x0A);
    port_byte_out(VGA_DATA_REG, 0x20);
    
    vga_clear_screen();
}

void vga_clear_screen() {
    unsigned int screen_size = 2 * VGA_MAX_COLS * VGA_MAX_ROWS;

    /* replace this with a memset */
    for (unsigned int i = 0; i < screen_size; i++) {
        vga_mem[i] = 0;
    }
}

void vga_print_char(char c, char attr) {
    if (!vga_did_init) return;

    if (!attr)
        attr = VGA_COL_FOREGROUND_WHITE | VGA_COL_BACKGROUND_BLACK;

    unsigned int off;
    if (c == '\n') {
        vga_cursor_pos.x = 0;
        vga_cursor_pos.y += 1;

        off = VGA_X_Y_TO_OFFSET(vga_cursor_pos.x, vga_cursor_pos.y);
    } else if (c == '\b') {
        vga_cursor_pos.x -= 1;
        off = VGA_X_Y_TO_OFFSET(vga_cursor_pos.x, vga_cursor_pos.y);

        vga_mem[2 * off]     = 0;
        vga_mem[2 * off + 1] = 0;
    } else {
        off = VGA_X_Y_TO_OFFSET(vga_cursor_pos.x, vga_cursor_pos.y);

        vga_mem[2 * off]     = c;
        vga_mem[2 * off + 1] = attr;
        
        vga_cursor_pos.x++;
        off++;
    }
    
    if (off >= VGA_MAX_ROWS * VGA_MAX_COLS) vga_scroll_line();
}

void vga_scroll_line() {
    if (vga_cursor_pos.y <= 0 || vga_cursor_pos.y >= VGA_MAX_COLS - 1) return;
    memcpy(&vga_mem[0], &vga_mem[VGA_MAX_COLS * 2], (VGA_MAX_COLS - 1) * VGA_MAX_ROWS);
    /* replace this with a memset */
    /* also this is flawed as it only clears the char and not the attr */
    /* but that's probably fine since when printing a char the attr is
     * overwritten anyway */
    for (int i = 0; i < VGA_MAX_COLS; i++) vga_mem[(VGA_MAX_ROWS + i) * 2] = 0;
}

void vga_print(const char *s) {
    unsigned long int i = 0;
    while (s[i]) vga_print_char(s[i++], 0);
}