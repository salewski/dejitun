TARGETS=dejitun
CXXFLAGS=-g
LD=g++
LDFLAGS=-g
RM=rm
GIT=git
GREP=grep
SED=sed
GZIP=gzip
TEST=test
WC=wc
ECHO=echo

all: $(TARGETS)

VER=$(shell $(GREP) '^static const double version' dejitun.cc \
	| $(SED) 's/.*=[^0-9]//' | $(SED) 's/[^.0-9]//g')
dist: dejitun-$(VER).tar.gz

dejitun-%.tar.gz:
	$(GIT) archive --format=tar \
		--prefix=$(shell $(ECHO) $@ | $(SED) 's/\.tar\.gz//')/ \
		v$(shell $(ECHO) $@ | $(SED) 's/.*-//' | $(SED) 's/\.tar\.gz//') \
		| $(GZIP) -9 > $@
dejitun-$(VER).tar.gz:
	$(GIT) archive --format=tar --prefix=dejitun-$(VER)/ v$(VER) \
		| $(GZIP) -9 > $@
tag:
	$(GIT) tag -l | $(GREP) -vq '^v$(VER)' \
		|| ($(ECHO) -e "---\nError: Version $(VER) already exists!\n" \
		&& false)
	$(TEST) $(shell $(GIT) status | $(WC) -l) -lt 3 \
		|| ($(ECHO) -e "---\nError: You have uncommitted changes!\n" \
		&& false)
	$(GIT) log > ChangeLog
	$(GIT) add ChangeLog
	$(GIT) commit -m"Updated ChangeLog"
	$(GIT) tag -s v$(VER)

dejitun: dejitun.o tun.o inet.o util.o
	$(LD) $(LDFLAGS) -o $@ $^

clean:
	$(RM) -f *.o $(TARGETS)
