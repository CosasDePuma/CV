#!/usr/bin/env python3
import os, sys

try:
    # Read the bootloader
    with open("build/curriculum.bin", "rb") as binfile:
        bootloader      = bytearray(binfile.read())
    print(f"[+] Bootloader read (Len: {len(bootloader)})")
    # Magic Numbers (Bootloader + PDF)
    bootloader_magic    = bytearray(b'\xEB\x44\x25\x50\x44\x46\x2D\x31\x2E\x35')
    # Segment the bootloader
    bootloader_start    = bootloader[2:62]
    bootloader_end      = bootloader[70:]
    bootloader          = bootloader_magic + bootloader_start + bootloader_end
    print(f"[+] Bootloader modified (Len: {len(bootloader)})")
    # Open PDF
    with open("build/compressed.pdf", "rb") as pdf:
        curriculum      = bytearray(pdf.read())
    print(f"[+] Curriculum read (Len: {len(curriculum)})")
    # Remove the magic number from the PDF
    curriculum          = curriculum[8:]
    # Append the bootloader
    curriculum          = bootloader + curriculum
    print(f"[+] Curriculum modified (Len: {len(curriculum)})")
    # Create the new PDF
    with open("dist/curriculum.pdf", "wb") as magic:
        magic.write(curriculum)
    print("[+] All done!")
except:
    print("[!] Something goes wrong!")