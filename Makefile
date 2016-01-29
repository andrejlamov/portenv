CPU=$(shell uname -m)

ARCH_MIRROR=ftp://ftp.acc.umu.se/mirror/archlinux/iso/latest/
PROOT_MIRROR=https://raw.githubusercontent.com/proot-me/proot-static-build/master/static/proot-$(CPU)

PROOT=proot-$(CPU)
PROOT_FLAG=-S root.$CPU -b 'root.$(CPU)/:/'
ARCH=archlinux-bootstrap-.*-$(CPU).tar.gz$$ # $$ escapes $

DEST=os

MIRRORLIST=$(DEST)/etc/pacman.d/mirrorlist

.PHONY: init

all:	archlinux-bootstrap.tar.gz proot os
	cp $(MIRRORLIST) $(MIRRORLIST).bak
	$(shell sed -i 's/#Server = http:\/\/ftp.acc.umu.se\/mirror\/archlinux\/$$repo\/os\/$$arch/Server = http:\/\/ftp.acc.umu.se\/mirror\/archlinux\/$$repo\/os\/$$arch/' $(MIRRORLIST))
	mkdir -p $(DEST)/other
	rm -rf $(DEST)/other/proot $(DEST)/other/sudo
	ln -fs $(shell readlink -f proot) $(DEST)/other/proot
	ln -fs $(shell readlink -f sudo)  $(DEST)/other/sudo
	ln -fs $(shell readlink -f other.sh) $(DEST)/etc/profile.d/
	./root ./init

archlinux-bootstrap.tar.gz:
	$(eval DIST = $(shell curl $(ARCH_MIRROR) --list-only | grep $(ARCH)))
	curl -O $(ARCH_MIRROR)$(DIST)
	mv $(DIST) archlinux-bootstrap.tar.gz
os:
	mkdir -p $(DEST)
	tar xzvf archlinux-bootstrap.tar.gz -C $(DEST) --strip-components=1

proot:
	curl -O $(PROOT_MIRROR)
	mv $(PROOT) proot
	chmod +x proot

clean:
	$(shell chmod 777 -fR $(DEST))
	rm -rf archlinux-bootstrap*.tar.gz proot* $(DEST)
