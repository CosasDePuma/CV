.PHONY: all build clean test

CC=nasm
SRC=src
DIST=dist
BUILD=build
TEX=xelatex
VENV=qemu-system-i386
LD=src/ld.py

all: build

# Link the bootloader to the PDF
build: $(BUILD)/curriculum.bin $(BUILD)/compressed.pdf
	$(LD)

# Remove the generated files
clean:
	@rm $(DIST)/* $(BUILD)/* 

# Open the bootloader
test: $(DIST)/curriculum.pdf
	$(VENV) -drive format=raw,file=$<

# Compile the PDF
$(BUILD)/curriculum.pdf: $(SRC)/tex/curriculum.tex $(SRC)/tex/style.cls
	@cd $(SRC)/tex && \
		$(TEX) --output-dir ../../$(BUILD) curriculum.tex

# Uncompress the PDF
$(BUILD)/compressed.pdf: $(BUILD)/curriculum.pdf
	qpdf --stream-data=uncompress --object-streams=disable $< $@

# Compile the bootloader
$(BUILD)/curriculum.bin: $(SRC)/asm/curriculum.asm
	$(CC) -f bin -o $@ $<