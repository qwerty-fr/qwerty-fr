# Maintainer: Niluge_KiWi <kiwiiii@gmail.com>
# Contributor: cantabile <cantabile dot desu at gmail dot com>
# created by cantabile <cantabile dot desu at gmail dot com>

pkgname=xkb-qwerty-fr
pkgver=0.5
pkgrel=2
pkgdesc="French qwerty keymap - provides a keymap for french users of qwerty keyboard. All French characters are directly accessible with AltGr and smartly mapped."
arch=('any')
url="http://marin.jb.free.fr/qwerty-fr/"
license=('GPL2')
depends=('xkeyboard-config')
makedepends=('binutils')
install=${pkgname}.install
source=("http://marin.jb.free.fr/qwerty-fr/${pkgname}_${pkgver}_all.deb")
md5sums=('cefc7f02f2a23633d1160c32caa6c132')

build() {
  cd "$srcdir"

  ar -xv ${pkgname}_${pkgver}_all.deb
  
  tar xvf data.tar.gz
}

package() {
  cd "$srcdir"

  install -D -m 644 usr/share/X11/xkb/symbols/us_qwerty-fr ${pkgdir}/usr/share/X11/xkb/symbols/us_qwerty-fr

  install -D -m 644 usr/share/doc/xkb-qwerty-fr/changelog.gz ${pkgdir}/usr/share/doc/xkb-qwerty-fr/changelog.gz
  install -D -m 644 usr/share/doc/xkb-qwerty-fr/copyright ${pkgdir}/usr/share/doc/xkb-qwerty-fr/copyright
  install -D -m 644 usr/share/doc/xkb-qwerty-fr/keymap.txt ${pkgdir}/usr/share/doc/xkb-qwerty-fr/keymap.txt

  install -D -m 644 usr/share/man/man7/qwerty-fr.7.gz ${pkgdir}/usr/share/man/man7/qwerty-fr.7.gz
}
