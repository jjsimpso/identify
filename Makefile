SRC_FILES = src/main.rkt src/allmagic.rkt
#SRC_FILES += magic/images.rkt

MAGIC_FILES = elf
MAGIC_FILES += msdos
MAGIC_FILES += windows
#MAGIC_FILES += apple
MAGIC_FILES += jpeg
MAGIC_FILES += images

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
