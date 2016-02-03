CPU := $(shell uname -m)
ifneq ($(CPU), x86_64)
	CPU = x86
endif

ARCH_MIRROR = ftp://ftp.acc.umu.se/mirror/archlinux/iso/latest/
PROOT_MIRROR = https://raw.githubusercontent.com/proot-me/proot-static-build/master/static/proot-$(CPU)
PROOT_CPU = proot-$(CPU)
PROOT_FLAG = -S root.$CPU -b 'root.$(CPU)/:/'
ARCH = archlinux-bootstrap-.*-$(CPU).tar.gz$$ # $$ escapes $
DIST := $(shell curl $(ARCH_MIRROR) --list-only | grep $(ARCH))

BOOTSTRAP = bootstrap

MIRRORLIST := $(BOOTSTRAP)/etc/pacman.d/mirrorlist

.PHONY: init

all:	proot $(BOOTSTRAP) $(DEST)
	cp $(MIRRORLIST) $(MIRRORLIST).bak
	sed -i 's/#Server = http:\/\/ftp.acc.umu.se\/mirror\/archlinux\/$$repo\/os\/$$arch/Server = http:\/\/ftp.acc.umu.se\/mirror\/archlinux\/$$repo\/os\/$$arch/' $(MIRRORLIST)

proot:
	curl -O $(PROOT_MIRROR)
	mv $(PROOT_CPU) proot
	chmod +x proot

$(BOOTSTRAP): archlinux-bootstrap.tar.gz
	mkdir -p $(BOOTSTRAP)
	tar xzvf archlinux-bootstrap.tar.gz -C $(BOOTSTRAP) --strip-components=1

archlinux-bootstrap.tar.gz:
	curl -O $(ARCH_MIRROR)$(DIST)
	mv $(DIST) archlinux-bootstrap.tar.gz

clean:
	chmod 777 -fR $(BOOTSTRAP)
	rm -rf $(BOOTSTRAP)
