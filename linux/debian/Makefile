BUILD=fakeroot dpkg-deb --build
RM=rm
LINTIAN=lintian
GZ=gzip -9
CP=cp
MV=mv

PKG=xkb-qwerty-fr
VER=0.5
ARCH=all

PKG_NAME=$(PKG)_$(VER)_$(ARCH)
PACKAGE=$(PKG_NAME).deb

.PHONY: deb
deb: $(PACKAGE)

$(PACKAGE): $(PKG_NAME)/usr/share/man/man7/qwerty-fr.7.gz $(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/changelog.gz $(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/copyright $(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/keymap.txt $(PKG_NAME)/usr/share/X11/xkb/symbols/us_qwerty-fr
	$(BUILD) $(PKG_NAME)

$(PKG_NAME)/usr/share/man/man7/qwerty-fr.7.gz: ../man/qwerty-fr.7
	$(CP) $< man.tmp &&
	$(GZ) man.tmp &&
	$(MV) man.tmp.gz $@

$(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/changelog.gz: changelog
	$(CP) $< changelog.tmp &&
	$(GZ) changelog.tmp &&
	$(MV) changelog.tmp.gz $@

$(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/copyright: ../copyright
	$(CP) @< $@

$(PKG_NAME)/usr/share/doc/xkb-qwerty-fr/keymap.txt: ../keymap.txt
	$(CP) @< $@

$(PKG_NAME)/usr/share/X11/xkb/symbols/us_qwerty-fr: ../us_qwerty-fr
	$(CP) @< $@

.PHONY: clean
clean:
	$(RM) $(PACKAGE)

.PHONY: lintian
lintian: $(PACKAGE)
	$(LINTIAN) $(PACKAGE)

.PHONY: test-trigger.deb
test-trigger.deb:
	$(BUILD) test-trigger

