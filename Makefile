SRC_FILES = src/main.rkt src/allmagic.rkt
#SRC_FILES += magic/images.rkt

MAGIC_FILES = elf
MAGIC_FILES += aout
MAGIC_FILES += acorn
MAGIC_FILES += adi
MAGIC_FILES += adventure
MAGIC_FILES += alliant
MAGIC_FILES += allegro
MAGIC_FILES += amanda
MAGIC_FILES += amigaos
MAGIC_FILES += android
MAGIC_FILES += animation
MAGIC_FILES += apache
MAGIC_FILES += apl
MAGIC_FILES += application
MAGIC_FILES += applix
MAGIC_FILES += apt
MAGIC_FILES += archive
MAGIC_FILES += assembler
MAGIC_FILES += asterix
MAGIC_FILES += att3b
#MAGIC_FILES += audio
MAGIC_FILES += windows
MAGIC_FILES += apple
MAGIC_FILES += jpeg
MAGIC_FILES += images
MAGIC_FILES += msdos
MAGIC_FILES += zfs
MAGIC_FILES += zilog
MAGIC_FILES += zip
MAGIC_FILES += zyxel

EXE = id
DIST_DIR = identify
MAGIC = src/allmagic.rkt

.PHONY = compmagic

all: dist

$(EXE): $(SRC_FILES)
	raco make -v src/main.rkt
	raco exe -v -o $(EXE) src/main.rkt

dist: $(EXE)
	raco distribute $(DIST_DIR) $(EXE)

compmagic:
	echo "#lang magic" > $(MAGIC)
	cd magic && cat $(MAGIC_FILES) >> ../$(MAGIC)

clean:
	rm -rf src/compiled/
	rm -rf magic/compiled/
	rm -f $(EXE)
#       rm -f $(MAGIC)
	rm -rf $(DIST_DIR)
