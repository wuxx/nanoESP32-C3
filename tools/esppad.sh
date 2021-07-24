#!/bin/bash

if  [ ${#1} -eq 0 ] || 
    [ ${#2} -eq 0 ] || 
    [ ${#3} -eq 0 ] || 
    [ ${#4} -eq 0 ] ; then
    echo "usage: $0 bootloader.bin partition-table.bin app.bin flash_image.bin"
    exit 0
fi

((BOOTLOADER_ADDR=0x0000))
((PTABLE_ADDR=0x8000))
((APPIMAGE_ADDR=0x10000))


BOOTLOADER_FILE=$1
PTABLE_FILE=$2
APPIMAGE_FILE=$3

OFILE=$4

BOOTLOADER_SECTION_SIZE=$(($PTABLE_ADDR - $BOOTLOADER_ADDR))
PTABLE_SECTION_SIZE=$(($PTABLE_ADDR - $BOOTLOADER_ADDR))

truncate -s $BOOTLOADER_SECTION_SIZE $BOOTLOADER_FILE
truncate -s $PTABLE_SECTION_SIZE     $PTABLE_FILE

cat $BOOTLOADER_FILE $PTABLE_FILE $APPIMAGE_FILE > $OFILE

#
#
