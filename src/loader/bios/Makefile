AS=nasm
PREFIX=x86_64-linux-gnu
CC=${PREFIX}-gcc
LD=${PREFIX}-ld
QEMU=qemu-system-x86_64

OUT_NAME=lambda
MAJOR_REV=0
MINOR_REV=0
PATCH_REV=0
RELEASE_TAG=-alpha
META_TAG=-bios

VER_STR=${OUT_NAME}.${MAJOR_REV}.${MINOR_REV}.${PATCH_REV}${RELEASE_TAG}${META_TAG}
OUT_BIN=${VER_STR}.bin

############## bootsect
BOOTSECT_DIR=bootsect
BOOTSECT_OUT=bootsect.bin
BOOTSECT_GEN=	${BOOTSECT_DIR}/defs.inc
BOOTSECT_SRC=	${BOOTSECT_DIR}/bootsect.asm		\
				${BOOTSECT_DIR}/disk.asm			\
				${BOOTSECT_DIR}/gdt.asm				\
				${BOOTSECT_DIR}/screen.asm			\
				${BOOTSECT_GEN}
				

############## stage 2
S2_DIR=stage2
S2_OUT=stage2.bin
S2_GEN=
S2_ASM_SRC=		${S2_DIR}/start.s					\
				${S2_DIR}/arch/x86/lib/memcpy.s
S2_C_SRC=		${S2_DIR}/entry.c					\
				${S2_DIR}/drivers/display/vga/vga.c	\
				${S2_DIR}/drivers/io/ports.c

S2_SRC=			${S2_ASM_SRC} ${S2_C_SRC}
S2_OBJ=			${S2_ASM_SRC:.s=.o}	\
				${S2_C_SRC:.c=.o}
S2_SEC_CNT=`wc -c < ${S2_OUT} | awk '{printf("%.0f\n", ($$1+511)/512)}'`
S2_LD_SCRIPT_GEN=${S2_DIR}/linker.ld.gen
S2_LD_SCRIPT=${S2_DIR}/linker.ld

CC_FLAGS=	-Istage2/include		\
			-Wall				 	\
			-Wextra 				\
			-g 						\
			-O0 					\
			-mno-sse                \
			-mno-sse2               \
			-mno-sse3				\
			-mno-sse4				\
			-mno-mmx                \
			-mno-80387              \
			-mno-avx512f			\
			-mno-3dnow				\
			-mno-red-zone			\
			-m32					\
			-fstack-protector-strong\
			-fno-pie

define write_defs_inc
	echo 	"%ifndef _defs_inc" 				>> ${BOOTSECT_DIR}/defs.inc
	echo 	"%define _defs_inc" 				>> ${BOOTSECT_DIR}/defs.inc
	echo 	"%define S2_SEC_CNT $(S2_SEC_CNT)" 	>> ${BOOTSECT_DIR}/defs.inc
	echo 	"%endif" 							>> ${BOOTSECT_DIR}/defs.inc
endef

all: ${OUT_BIN}

${OUT_BIN}: ${S2_OUT} ${BOOTSECT_OUT}	
	cat ${BOOTSECT_OUT} ${S2_OUT} > ${OUT_BIN}

${BOOTSECT_DIR}/defs.inc:
	$(call write_defs_inc)

${BOOTSECT_OUT}: ${BOOTSECT_SRC}
	${AS} -I ${BOOTSECT_DIR} -f bin $< -o $@

${S2_DIR}/%.o: ${S2_DIR}/%.c
	${CC} ${CC_FLAGS} -ffreestanding -c $< -o $@

${S2_DIR}/%.o: ${S2_DIR}/%.s
	${AS} -f elf32 $< -o $@

${S2_LD_SCRIPT}: ${S2_LD_SCRIPT_GEN}
	gcc -E -x c $< | grep -v '^#' > $@

${S2_OUT}: ${S2_OBJ} ${S2_LD_SCRIPT}
	${LD} -m elf_i386 -o $@ -T${S2_LD_SCRIPT} ${S2_OBJ}

run_qemu: all
	${QEMU} -m 512 -drive file=${OUT_BIN},format=raw,index=0,media=disk

run: run_qemu

debug_qemu: all
	${QEMU} -d int -monitor stdio -no-shutdown -no-reboot -m 512 -drive file=${OUT_BIN},format=raw,index=0,media=disk

clean:
	rm -rf ${BOOTSECT_OUT} ${S2_OUT} ${BOOTSECT_GEN} ${S2_OBJ} ${S2_LD_SCRIPT} ${OUT_BIN}
