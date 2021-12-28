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
MAGIC_FILES += audio

MAGIC_FILES += basis
MAGIC_FILES += beetle
MAGIC_FILES += ber
MAGIC_FILES += bflt
MAGIC_FILES += bhl
MAGIC_FILES += bioinformatics
MAGIC_FILES += blackberry
MAGIC_FILES += blcr
MAGIC_FILES += blender
MAGIC_FILES += blit
MAGIC_FILES += bout
MAGIC_FILES += bsdi
MAGIC_FILES += bsi
MAGIC_FILES += btsnoop

MAGIC_FILES += c64
MAGIC_FILES += cad
MAGIC_FILES += cafebabe
MAGIC_FILES += cbor
MAGIC_FILES += cddb
MAGIC_FILES += chord
MAGIC_FILES += cisco
MAGIC_FILES += citrus
#MAGIC_FILES += c-lang
MAGIC_FILES += clarion
MAGIC_FILES += claris
MAGIC_FILES += clipper
MAGIC_FILES += coff
MAGIC_FILES += commands
MAGIC_FILES += communications
MAGIC_FILES += compress
#MAGIC_FILES += console
MAGIC_FILES += convex
MAGIC_FILES += coverage
MAGIC_FILES += cracklib
MAGIC_FILES += ctags
MAGIC_FILES += ctf
MAGIC_FILES += cubemap
MAGIC_FILES += cups

MAGIC_FILES += dact
#MAGIC_FILES += database
MAGIC_FILES += dataone
MAGIC_FILES += dbpf
#MAGIC_FILES += der
MAGIC_FILES += diamond
MAGIC_FILES += diff
MAGIC_FILES += digital
MAGIC_FILES += dolby
MAGIC_FILES += dump
MAGIC_FILES += dyadic

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
