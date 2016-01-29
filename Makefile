CPU := $(shell uname -m)

ARCH_MIRROR = ftp://ftp.acc.umu.se/mirror/archlinux/iso/latest/
PROOT_MIRROR = https://raw.githubusercontent.com/proot-me/proot-static-build/master/static/proot-$(CPU)

PROOT_CPU = proot-$(CPU)
PROOT_FLAG = -S root.$CPU -b 'root.$(CPU)/:/'
ARCH = archlinux-bootstrap-.*-$(CPU).tar.gz$$ # $$ escapes $
DIST := $(shell curl $(ARCH_MIRROR) --list-only | grep $(ARCH))
DEST = os

MIRRORLIST := $(DEST)/etc/pacman.d/mirrorlist

PROOT := $(shell readlink -f proot)
SUDO  := $(shell readlink -f sudo)
OTHER := $(shell readlink -f other)

.PHONY: init

all:	proot $(DEST)
	cp $(MIRRORLIST) $(MIRRORLIST).bak
	sed -i 's/#Server = http:\/\/ftp.acc.umu.se\/mirror\/archlinux\/$$repo\/os\/$$arch/Server = http:\/\/ftp.acc.umu.se\/mirror\/archlinux\/$$repo\/os\/$$arch/' $(MIRRORLIST)
	mkdir -p $(DEST)/other
	rm -rf $(DEST)/other/proot $(DEST)/other/sudo
	ln -fs $(PROOT) $(DEST)/other/proot
	ln -fs $(SUDO)  $(DEST)/other/sudo
	ln -fs $(OTHER) $(DEST)/etc/profile.d/
	@echo "*** now run ./init as root"
proot:
	curl -O $(PROOT_MIRROR)
	mv $(PROOT_CPU) proot
	chmod +x proot

$(DEST): archlinux-bootstrap.tar.gz
	mkdir -p $(DEST)
	tar xzvf archlinux-bootstrap.tar.gz -C $(DEST) --strip-components=1

archlinux-bootstrap.tar.gz:
	curl -O $(ARCH_MIRROR)$(DIST)
	mv $(ARCH_MIRROR)$(DIST) archlinux-bootstrap.tar.gz

clean:
	chmod 777 -fR $(DEST)
	rm -rf $(DEST)
