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
MAGIC_FILES += c-lang
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
MAGIC_FILES += database
MAGIC_FILES += dataone
MAGIC_FILES += dbpf
#MAGIC_FILES += der
MAGIC_FILES += diamond
MAGIC_FILES += diff
MAGIC_FILES += digital
MAGIC_FILES += dolby
MAGIC_FILES += dump
MAGIC_FILES += dyadic

MAGIC_FILES += ebml
MAGIC_FILES += editors
MAGIC_FILES += efi
MAGIC_FILES += encore
MAGIC_FILES += epoc
MAGIC_FILES += erlang
MAGIC_FILES += esri
MAGIC_FILES += etf

MAGIC_FILES += fcs
MAGIC_FILES += filesystems
MAGIC_FILES += finger
MAGIC_FILES += flash
MAGIC_FILES += flif
MAGIC_FILES += fonts
MAGIC_FILES += fortran
MAGIC_FILES += frame
MAGIC_FILES += freebsd
MAGIC_FILES += fsav
MAGIC_FILES += fusecompress

MAGIC_FILES += games
MAGIC_FILES += gcc
MAGIC_FILES += gconv
MAGIC_FILES += geo
MAGIC_FILES += geos
MAGIC_FILES += gimp
MAGIC_FILES += gnome
MAGIC_FILES += gnu
MAGIC_FILES += gnumeric
MAGIC_FILES += gpt
MAGIC_FILES += gpu
MAGIC_FILES += grace
MAGIC_FILES += graphviz
MAGIC_FILES += gringotts

MAGIC_FILES += hitachi-sh
MAGIC_FILES += hp
MAGIC_FILES += human68k

MAGIC_FILES += ibm370
MAGIC_FILES += icc
MAGIC_FILES += iff
MAGIC_FILES += inform
MAGIC_FILES += intel
MAGIC_FILES += interleaf
MAGIC_FILES += island
MAGIC_FILES += ispell
MAGIC_FILES += isz

MAGIC_FILES += windows
MAGIC_FILES += apple
MAGIC_FILES += jpeg
MAGIC_FILES += images
MAGIC_FILES += msdos
MAGIC_FILES += zfs
MAGIC_FILES += zilog
MAGIC_FILES += zip
MAGIC_FILES += zyxel

# this one goes last because it has spurious matches
MAGIC_FILES += ibm6000

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
