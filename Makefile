SRC_FILES = src/main.rkt
#SRC_FILES += magic/images.rkt
MAGIC_FILES = elf images

EXE = id
DIST_DIR = identify
MAGIC = src/allmagic.rkt

.PHONY = compmagic

all: dist

$(EXE): compmagic $(SRC_FILES)
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
	rm -f $(MAGIC)
	rm -rf $(DIST_DIR)
