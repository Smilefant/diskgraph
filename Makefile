CC ?= cc
CFLAGS += -D_POSIX_C_SOURCE=199309L -std=c99 -Wall -Wextra
LDFLAGS += -lm

TARGET = diskgraph
MANPAGE = $(TARGET).1
SRC = diskgraph.c
OBJ = $(SRC:.c=.o)

# Installation paths
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man/man1

# Distribution files
DISTFILES = \
	Makefile \
	$(SRC) \
	$(MANPAGE) \
	README.md \
	LICENSE \
	images \
	debian

# Version for Debian packaging
VERSION = 1.2
DEB_RELEASE = 1
PPA = ppa:b-stolk/ppa

.PHONY: all clean install uninstall tarball packageupload

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(TARGET)
	@echo All clean

install: $(TARGET)
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(MANDIR)
	install -m 755 $(TARGET) $(DESTDIR)$(BINDIR)/
	install -m 644 $(MANPAGE) $(DESTDIR)$(MANDIR)/

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)
	rm -f $(DESTDIR)$(MANDIR)/$(MANPAGE)

tarball:
	@echo Creating tarball in parent directory (required for Debian packaging)...
	tar cvzf ../$(TARGET)_$(VERSION).orig.tar.gz $(DISTFILES)

packageupload:
	debuild -S
	debsign ../$(TARGET)_$(VERSION)-$(DEB_RELEASE)_source.changes
	dput --force $(PPA) ../$(TARGET)_$(VERSION)-$(DEB_RELEASE)_source.changes
