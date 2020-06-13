# ==================================
# 	ENVIRONMENT
# ==================================

CC=nasm
SRC=src
DIST=dist
BUILD=build
PDF=pdfinfo
TEX=xelatex
LD=src/ld.py
AUTHOR=Kike Fontan
VENV=qemu-system-i386

# ==================================
# 	Rules
# ==================================

.PHONY: all build clean test

all: build

# Link the bootloader to the PDF
build: $(DIST)/curriculum.pdf

# Remove the generated files
clean:
	@rm $(DIST)/* $(BUILD)/* 

# Open the bootloader
test: $(DIST)/curriculum.pdf
	$(PDF) $< 2>/dev/null
	$(VENV) -drive format=raw,file=$<

# ==================================
# 	Targets
# ==================================

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

# Generate the polymorphic PDF
$(DIST)/curriculum.pdf: $(BUILD)/curriculum.bin $(BUILD)/compressed.pdf
	$(LD)
	sed -i 's/Creator \(.*\)/Creator \($(AUTHOR)\)/g' $@