SRC_FILES = src/main.rkt
SRC_FILES += magic/images.rkt

EXE = id
DIST_DIR = identify

all: dist

$(EXE): $(SRC_FILES)
	raco make -v src/main.rkt
	raco exe -v -o $(EXE) src/main.rkt

dist: $(EXE)
	raco distribute $(DIST_DIR) $(EXE)

clean:
	rm -rf src/compiled/
	rm -rf magic/compiled/
	rm -f $(EXE)
	rm -rf $(DIST_DIR)
