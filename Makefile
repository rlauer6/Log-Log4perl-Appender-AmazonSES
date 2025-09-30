#-*- mode: makefile; -*-

SHELL := /bin/bash
.SHELLFLAGS := -ec

MODULE_NAME := Log::Log4perl::Appender::AmazonSES
MODULE_PATH := $(subst ::,/,$(MODULE_NAME)).pm

PERL_MODULES = \
    lib/Log/Log4perl/Appender/AmazonSES.pm.in

GPERL_MODULES = $(PERL_MODULES:.pm.in=.pm)

VERSION := $(shell cat VERSION)

TARBALL = $(subst ::,-,$(MODULE_NAME))-$(VERSION).tar.gz

all: $(TARBALL) README.md

%.pm: %.pm.in
	rm -f $@
	sed "s/[@]PACKAGE_VERSION[@]/$(VERSION)/g" $< > $@
	perl -wc -I lib $@
	chmod -w $@

TARBALL_DEPS = \
    $(GPERL_MODULES) \
    requires \
    test-requires \
    README.md

$(TARBALL): buildspec.yml $(TARBALL_DEPS)
	make-cpan-dist.pl -b $<

README.pod: lib/Log/Log4perl/Appender/AmazonSES.pm
	VERSION=$$(cat VERSION); \
	perldoc -u $< | sed 's/[@]PACKAGE_VERSION[@]/$$VERSION/' | perl -npe 's/^=head1/ \@TOC_BACK\@\n\n=head1/' > $@

README.md.in: README.pod
	pod2markdown $< > $@

README.md: README.md.in
	perl -npe 's/^.*\@TOC/\@TOC/g;' $< | \
	perl -0npe 'BEGIN { print qq{\@TOC\@\n---\n}; }'  | \
	  md-utils.pl > $@

clean:
	rm -f README.md README.md.in README.pod
	find lib -name '*.pm' -exec rm -f {} \;
	rm -f *.tar.gz
	rm -f provides extra-files resources

install: $(TARBALL)
	cpanm -n -v -l $$HOME $(TARBALL)


include version.mk
