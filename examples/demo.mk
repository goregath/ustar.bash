# A demo makefile to pack release of ustar.bash

blank :=
define eol

$(blank)
endef

DD := dd
GIT := git
GZIP := gzip
STAT := stat
TAR := tar
USTAR := ./ustar.bash

ustaropt = \
	$(foreach o,\
		$(foreach v,gid group link major minor mode mtime name prefix size type uid user,\
			$(if $($(v)),$(v))),-o $(o)=$($(o)))

%.gz: %
	gzip -kf $<

%.tar:
	$(foreach chunk,$|,\
		$(DD) if=$(chunk) of=$@ ibs=512 conv=sync,notrunc oflag=append status=none $(eol))
	$(TAR) -tvf $@

%/:
	mkdir -p $@

tmp/ustar/%: | tmp/ustar/
	$(USTAR) $(ustaropt) -- "$(strip $(path))" "$(data)" > $@

tmp/ustar/%: type   := file
tmp/ustar/%: mtime  := $(shell $(GIT) log -1 --pretty="format:%ct" ustar.bash || echo "now")
tmp/ustar/%: user   := root
tmp/ustar/%: group  := root
tmp/ustar/%: size    = $(if $<,$(shell $(STAT) -Lc%s -- $<),0)
tmp/ustar/%: prefix := ustar.bash-$(shell $(GIT) rev-parse --short HEAD || echo "latest")

tmp/ustar/README: data := A demo archive with ustar.bash and make
tmp/ustar/README: mode := 0644
tmp/ustar/README: name := README

tmp/ustar/lib-ustar: ustar.bash
tmp/ustar/lib-ustar: mode := 0755
tmp/ustar/lib-ustar: name := lib/ustar.bash

tmp/ustar/bin-ustar: type := symlink
tmp/ustar/bin-ustar: mode := 0777
tmp/ustar/bin-ustar: name := bin/ustar-dump
tmp/ustar/bin-ustar: link := ../lib/ustar.bash

demo.tar: | tmp/ustar/README
demo.tar: | tmp/ustar/lib-ustar ustar.bash 
demo.tar: | tmp/ustar/bin-ustar

.PHONY: all clean

all: demo.tar.gz

clean:
	rm -rf -- demo.tar demo.tar.gz tmp/
