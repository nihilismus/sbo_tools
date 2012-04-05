PREFIX = /usr/local

override SOURCES = $(wildcard src/*.sh)
override BINARIES = $(notdir $(SOURCES))

all: install

install:
	@echo Installing scripts into ${PREFIX}/bin
	@mkdir -p ${PREFIX}/bin
	$(foreach file,$(BINARIES),\
		install -m 755 src/$(file) ${PREFIX}/bin/$(file:%.sh=%); \
	)
	@echo Done.

uninstall:
	@echo Removing scripts from ${PREFIX}/bin
	$(foreach file,$(BINARIES),\
		rm -f ${PREFIX}/bin/$(file:%.sh=%); \
	)
	@echo Done.

.PHONY: all install uninstall
