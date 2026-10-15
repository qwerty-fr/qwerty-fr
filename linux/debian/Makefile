BUILD=fakeroot dpkg-deb --build
RM=rm -rf
LINTIAN=lintian
GZ=gzip -nf9
CP=cp
MV=mv -f
MKD=mkdir -p
CONTROL_FILES=$(wildcard DEBIAN/*)
MAINTAINER_SCRIPTS=preinst postinst postrm

PKG=xkb-qwerty-fr
VER=0.7.4
ARCH=all

PKG_NAME=$(PKG)_$(VER)_$(ARCH)
PACKAGE=$(PKG_NAME).deb

.PHONY: deb
deb: $(PACKAGE)

$(PACKAGE): $(PKG_NAME)/DEBIAN $(PKG_NAME)/usr/share/man/man7/qwerty-fr.7.gz $(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/changelog.gz $(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/copyright $(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/keymap.txt $(PKG_NAME)/etc/xkb/symbols/us $(PKG_NAME)/etc/xkb/rules/evdev.xml $(PKG_NAME).zip
	$(BUILD) $(PKG_NAME)

.PHONY: zip
zip: $(PKG_NAME).zip

$(PKG_NAME).zip: $(PKG_NAME)/usr/share/man/man7/qwerty-fr.7.gz $(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/changelog.gz $(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/copyright $(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/keymap.txt $(PKG_NAME)/etc/xkb/symbols/us $(PKG_NAME)/etc/xkb/rules/evdev.xml
	rm -f $(PKG_NAME).zip &&\
	cd $(PKG_NAME) &&\
	zip -r ../$@ etc usr -x \*.DS_Store \*__MACOSX \*DEBIAN &&\
	cd -

$(PKG_NAME)/DEBIAN: DEBIAN $(CONTROL_FILES)
	$(RM) $@ &&\
	$(MKD) $(@D) &&\
	$(CP) -r DEBIAN $(PKG_NAME)/ &&\
	chmod 0755 $(addprefix $(PKG_NAME)/DEBIAN/,$(MAINTAINER_SCRIPTS))

$(PKG_NAME)/usr/share/man/man7/qwerty-fr.7.gz: ../man/qwerty-fr.7
	$(MKD) $(@D) &&\
	$(CP) $< man.tmp &&\
	$(GZ) man.tmp &&\
	$(MV) man.tmp.gz $@

$(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/changelog.gz: changelog
	$(MKD) $(@D) &&\
	$(CP) $< changelog.tmp &&\
	$(GZ) changelog.tmp &&\
	$(MV) changelog.tmp.gz $@

$(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/copyright: ../copyright
	$(MKD) $(@D) &&\
	$(CP) $< $@

$(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/keymap.txt: ../keymap.txt
	$(MKD) $(@D) &&\
	$(CP) $< $@

$(PKG_NAME)/etc/xkb/symbols/us: ../us_qwerty-fr
	$(MKD) $(@D) &&\
	printf '%s\n' 'default partial alphanumeric_keys' 'xkb_symbols { include "us(basic)" };' > $@ &&\
	cat $< >> $@

$(PKG_NAME)/etc/xkb/rules/evdev.xml: xkb/rules/evdev.xml
	$(MKD) $(@D) &&\
	$(CP) $< $@

.PHONY: clean
clean:
	$(RM) $(PKG_NAME) $(PACKAGE)
	$(RM) $(PKG_NAME).zip

.PHONY: lintian
lintian: $(PACKAGE)
	$(LINTIAN) $(PACKAGE)

.PHONY: test
test:
	sh tests/test-preinst.sh
	sh tests/test-package-layout.sh

.PHONY: test-integration
test-integration:
	sh tests/test-integration.sh

