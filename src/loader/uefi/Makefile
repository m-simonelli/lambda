# Makefile
# Copyright Marco Simonelli 2020
# You are free to redistribute/modify this code under the
# terms of the GPL version 3 (see the file LICENSE)

AS=nasm
PREFIX=x86_64-linux-gnu
AS_FMT=elf64
CC=${PREFIX}-gcc
# mingw throws a fit if you try and operate on a non pe output
LD=${PREFIX}-ld
OBJCOPY=objcopy
QEMU=qemu-system-x86_64

ARCH= $(shell uname -m | sed s,i[3456789]86,ia32,)

# this will vary depending on your gnu-efi installation
GNU_EFI_PATH=/usr/lib
# this varies depending on ovmf install
QEMU_OVMF_DIR=/usr/share/qemu

OUT_NAME=lambda
MAJOR_REV=0
MINOR_REV=0
PATCH_REV=0
RELEASE_TAG=-alpha
META_TAG=-uefi

VER_STR=${OUT_NAME}.${MAJOR_REV}.${MINOR_REV}.${PATCH_REV}${RELEASE_TAG}${META_TAG}
OUT_EFI=${VER_STR}.efi
# linking generates a shared object, objcopy is used to convert it to PE
OUT_LD=${OUT_EFI:.efi=.so}
OUT_IMG=${OUT_EFI:.efi=.img}
OUT_HDD=${OUT_EFI:.efi=.bin}

CC_INCLUDES=-I/usr/include/efi			\
			-I/usr/include/efi/protocol	\
			-I/usr/include/efi/x86_64	\
			-Iinclude
CFLAGS=		-fpic						\
			-ffreestanding				\
			-fno-stack-protector		\
			-fno-stack-check			\
			-fshort-wchar				\
			-mno-red-zone				\
			-O0							\
			-mno-sse                	\
			-mno-sse2               	\
			-mno-sse3					\
			-mno-sse4					\
			-mno-mmx                	\
			-mno-80387              	\
			-mno-avx512f				\
			-mno-3dnow					\
			-mno-red-zone				\
			-maccumulate-outgoing-args	\
			-Wall						\
			${CC_INCLUDES}

ifeq (${ARCH},x86_64)
  CFLAGS += -DEFI_FUNCTION_WRAPPER
endif

LD_FLAGS=	-shared									\
			-Bsymbolic								\
			-L${GNU_EFI_PATH}						\
			-T${GNU_EFI_PATH}/elf_${ARCH}_efi.lds

SRC=		entry.c
SRC_ASM=
OBJS=${SRC:.c=.o} ${SRC_ASM:.s=.o}


all: ${OUT_EFI}

%.o: %.c
	${CC} ${CFLAGS} -c $^ -o $@

%.o: %.s
	${AS} -f ${AS_FMT} $^ -o $@

${OUT_LD}: ${OBJS}
	${LD} ${LD_FLAGS} ${GNU_EFI_PATH}/crt0-efi-${ARCH}.o ${OBJS} -o $@ -lefi -lgnuefi

${OUT_EFI}: ${OUT_LD}
	objcopy										\
		-j .text								\
		-j .sdata								\
		-j .data								\
		-j .dynamic								\
		-j .dynsym								\
		-j .rel									\
		-j .rela								\
		-j .reloc								\
		--target=efi-app-${ARCH} $^ $@			\
		--subsystem=10

${OUT_IMG}: ${OUT_EFI}
	# todo: size the out img depending on out.efi byte count
	cp ${OUT_EFI} BOOTX64.EFI
	dd if=/dev/zero of=$@ bs=1k count=14400
	mformat -i $@ -f 1440 ::
	mmd -i $@ ::/EFI
	mmd -i $@ ::/EFI/BOOT
	mcopy -i $@ BOOTX64.EFI ::/EFI/BOOT

${OUT_HDD}: ${OUT_IMG}
	mkgpt -o ${OUT_HDD} --image-size 40960 --part ${OUT_IMG} --type system

run_qemu_usb: ${OUT_IMG}
	${QEMU} -L ${QEMU_OVMF_DIR} -drive if=pflash,format=raw,file=${QEMU_OVMF_DIR}/OVMF.fd -usb -usbdevice disk::${OUT_IMG}
run_qemu_hdd: ${OUT_HDD}
	${QEMU} -L ${QEMU_OVMF_DIR} -drive if=pflash,format=raw,file=${QEMU_OVMF_DIR}/OVMF.fd -drive file=${OUT_HDD},format=raw,index=0,media=disk

run_qemu: run_qemu_hdd
run: run_qemu

clean:
	rm -rf ${OUT_IMG} ${OUT_EFI} ${OUT_HDD} ${OUT_LD} ${OBJS} BOOTX64.EFI