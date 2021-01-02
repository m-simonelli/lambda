/*
 *  vga.h
 *  Copyright Marco Simonelli 2020
 *  You are free to redistribute/modify this code under the
 *  terms of the GPL version 3 (see the file LICENSE)
 */

#ifndef _drivers_display_vga_vga_h
#define _drivers_display_vga_vga_h

#define VGA_MEM (0xB8000)

/* Handy macro to convert an x,y position to an offset from vga_mem base */
#define VGA_X_Y_TO_OFFSET(x, y) ((y)*VGA_MAX_COLS + (x))

#define VGA_MEM_LOW 0xA0000
#define VGA_MEM_HIGH 0xBFFFF

#define VGA_MAX_ROWS 25
#define VGA_MAX_COLS 80

/* cpu port addresses */

#define VGA_CTRL_REG 0x3d4
#define VGA_DATA_REG 0x3d5

struct vga_cursor_pos {
    unsigned short x;
    unsigned short y;
};

/* Colours */
#define VGA_COL_FOREGROUND_BLUE 0x1
#define VGA_COL_FOREGROUND_BLACK 0x0
#define VGA_COL_FOREGROUND_GREEN 0x2
#define VGA_COL_FOREGROUND_CYAN 0x3
#define VGA_COL_FOREGROUND_RED 0x4
#define VGA_COL_FOREGROUND_MAGENTA 0x5
#define VGA_COL_FOREGROUND_BROWN 0x6
#define VGA_COL_FOREGROUND_LIGHT_GRAY 0x7
#define VGA_COL_FOREGROUND_DARK_GRAY 0x8
#define VGA_COL_FOREGROUND_LIGHT_BLUE 0x9
#define VGA_COL_FOREGROUND_LIGHT_GREEN 0xa
#define VGA_COL_FOREGROUND_LIGHT_CYAN 0xb
#define VGA_COL_FOREGROUND_LIGHT_RED 0xc
#define VGA_COL_FOREGROUND_LIGHT_MAGENTA 0xd
#define VGA_COL_FOREGROUND_YELLOW 0xe
#define VGA_COL_FOREGROUND_WHITE 0xf

#define VGA_COL_BACKGROUND_BLACK 0x00
#define VGA_COL_BACKGROUND_BLUE 0x10
#define VGA_COL_BACKGROUND_GREEN 0x20
#define VGA_COL_BACKGROUND_CYAN 0x30
#define VGA_COL_BACKGROUND_RED 0x40
#define VGA_COL_BACKGROUND_MAGENTA 0x50
#define VGA_COL_BACKGROUND_BROWN 0x60
#define VGA_COL_BACKGROUND_LIGHT_GRAY 0x70
#define VGA_COL_BACKGROUND_DARK_GRAY 0x80
#define VGA_COL_BACKGROUND_LIGHT_BLUE 0x90
#define VGA_COL_BACKGROUND_LIGHT_GREEN 0xa0
#define VGA_COL_BACKGROUND_LIGHT_CYAN 0xb0
#define VGA_COL_BACKGROUND_LIGHT_RED 0xc0
#define VGA_COL_BACKGROUND_LIGHT_MAGENTA 0xd0
#define VGA_COL_BACKGROUND_YELLOW 0xe0
#define VGA_COL_BACKGROUND_WHITE 0xf0

/* func decls */
void vga_print(const char *const s);
void vga_init();
void vga_clear_screen();
void vga_print_char(char c, char attr);
void vga_scroll_line();

#endif