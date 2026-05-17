# requires rpm-build package installed
RPMBUILD ?= rpmbuild
RM ?= rm
RMFLAGS ?= -rf
INSTALL ?= install

SPEC ?= xkb-qwerty-fr.spec
TOPDIR ?= $(CURDIR)
REPOSOURCEDIR ?= $(TOPDIR)/../..
SOURCEDIR ?= $(TOPDIR)/SOURCES
RPMFILENAME ?= %{NAME}_%{VERSION}_linux.%{ARCH}.rpm

RPMDIR ?= $(TOPDIR)/RPMS
BUILDDIR ?= $(TOPDIR)/BUILD
BUILDROOTDIR ?= $(TOPDIR)/BUILDROOT
SRCRPMDIR ?= $(TOPDIR)/SRPMS
SOURCES := \
	$(SOURCEDIR)/us_qwerty-fr \
	$(SOURCEDIR)/keymap.txt \
	$(SOURCEDIR)/LICENSE \
	$(SOURCEDIR)/qwerty-fr.7 \
	$(SOURCEDIR)/postinst \
	$(SOURCEDIR)/postrm \
	$(SOURCEDIR)/postinst-rpm.pl \
	$(SOURCEDIR)/postrm-rpm.pl

.PHONY: rpm srpm clean

rpm: $(SOURCES)
	$(RPMBUILD) -bb $(SPEC) \
		--define "_sourcedir $(SOURCEDIR)" \
		--define "_rpmfilename $(RPMFILENAME)" \
		--define "_rpmdir $(RPMDIR)" \
		--define "_builddir $(BUILDDIR)" \
		--define "_buildrootdir $(BUILDROOTDIR)" \
		--define "_srcrpmdir $(SRCRPMDIR)"

srpm: $(SOURCES)
	$(RPMBUILD) -bs $(SPEC) \
		--define "_sourcedir $(SOURCEDIR)" \
		--define "_srcrpmdir $(SRCRPMDIR)"

$(SOURCEDIR):
	$(INSTALL) -d $@

$(SOURCEDIR)/us_qwerty-fr: $(REPOSOURCEDIR)/linux/us_qwerty-fr | $(SOURCEDIR)
	$(INSTALL) -Dpm 0644 $< $@

$(SOURCEDIR)/keymap.txt: $(REPOSOURCEDIR)/linux/keymap.txt | $(SOURCEDIR)
	$(INSTALL) -Dpm 0644 $< $@

$(SOURCEDIR)/LICENSE: $(REPOSOURCEDIR)/LICENSE | $(SOURCEDIR)
	$(INSTALL) -Dpm 0644 $< $@

$(SOURCEDIR)/qwerty-fr.7: $(REPOSOURCEDIR)/linux/man/qwerty-fr.7 | $(SOURCEDIR)
	$(INSTALL) -Dpm 0644 $< $@

$(SOURCEDIR)/postinst: $(REPOSOURCEDIR)/linux/rpm/RPM/postinst | $(SOURCEDIR)
	$(INSTALL) -Dpm 0755 $< $@

$(SOURCEDIR)/postrm: $(REPOSOURCEDIR)/linux/rpm/RPM/postrm | $(SOURCEDIR)
	$(INSTALL) -Dpm 0755 $< $@

$(SOURCEDIR)/postinst-rpm.pl: $(REPOSOURCEDIR)/linux/rpm/RPM/postinst-rpm.pl | $(SOURCEDIR)
	$(INSTALL) -Dpm 0755 $< $@

$(SOURCEDIR)/postrm-rpm.pl: $(REPOSOURCEDIR)/linux/rpm/RPM/postrm-rpm.pl | $(SOURCEDIR)
	$(INSTALL) -Dpm 0755 $< $@

clean:
	$(RM) $(RMFLAGS) $(RPMDIR) $(BUILDDIR) $(BUILDROOTDIR) $(SRCRPMDIR) $(SOURCEDIR)
