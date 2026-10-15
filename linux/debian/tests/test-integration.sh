#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname "$0")/../../.." && pwd -P)
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/qwerty-fr-integration-test.XXXXXX")

cleanup() {
  case "$temp_dir" in
    "${TMPDIR:-/tmp}"/qwerty-fr-integration-test.*)
      rm -rf -- "$temp_dir"
      ;;
    *)
      printf 'refusing to remove unexpected temporary path: %s\n' "$temp_dir" >&2
      exit 1
      ;;
  esac
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$temp_dir/current" "$temp_dir/v0.7.3" "$temp_dir/packages"
cp -R "$repo_root/linux" "$temp_dir/current/linux"
git -C "$repo_root" archive --format=tar v0.7.3 linux | tar -xf - -C "$temp_dir/v0.7.3"

docker run --rm \
  --mount type=bind,src="$temp_dir",dst=/work \
  ubuntu:24.04 \
  sh -eu -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update >/dev/null
    apt-get install --yes --no-install-recommends bash dpkg-dev fakeroot make zip >/dev/null

    cd /work/v0.7.3/linux/debian
    make SHELL=/bin/bash clean deb >/dev/null
    cp ./*.deb /work/packages/v0.7.3.deb

    dpkg-deb --raw-extract /work/packages/v0.7.3.deb /work/old-postrm-failure
    printf "\nexit 42\n" >> /work/old-postrm-failure/DEBIAN/postrm
    fakeroot dpkg-deb --build /work/old-postrm-failure /work/packages/old-postrm-failure.deb >/dev/null

    cd /work/current/linux/debian
    make clean deb >/dev/null
    cp ./*.deb /work/packages/current.deb

    dpkg-deb --raw-extract /work/packages/current.deb /work/preinst-failure
    printf "\nexit 42\n" >> /work/preinst-failure/DEBIAN/preinst
    fakeroot dpkg-deb --build /work/preinst-failure /work/packages/preinst-failure.deb >/dev/null

    dpkg-deb --raw-extract /work/packages/current.deb /work/unpack-failure
    mkdir -p /work/unpack-failure/usr/share/X11
    printf "intentional directory conflict\n" > /work/unpack-failure/usr/share/X11/xkb
    fakeroot dpkg-deb --build /work/unpack-failure /work/packages/unpack-failure.deb >/dev/null
  '

docker run --rm \
  --mount type=bind,src="$temp_dir/packages",dst=/packages \
  ubuntu:26.04 \
  sh -eu -c '
    apt-get update >/dev/null
    cd /packages
    apt-get download xkb-data >/dev/null
    set -- xkb-data_*.deb
    if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
      printf "expected one xkb-data package, found: %s\n" "$*" >&2
      exit 1
    fi
    mv "$1" xkb-data-2.46.deb
  '

for release in 22.04 24.04 26.04; do
  printf '=== clean install on Ubuntu %s ===\n' "$release"
  docker run --rm \
    --mount type=bind,src="$temp_dir/packages",dst=/packages,readonly \
    "ubuntu:$release" \
    sh -eu -c '
      export DEBIAN_FRONTEND=noninteractive
      apt-get update >/dev/null
      apt-get install --yes --no-install-recommends libxkbcommon-tools libxkbregistry0 xkb-data >/dev/null

      vendor_us_before=$(sha256sum /usr/share/X11/xkb/symbols/us | cut -d" " -f1)
      vendor_xml_before=$(sha256sum /usr/share/X11/xkb/rules/evdev.xml | cut -d" " -f1)

      dpkg -i /packages/current.deb >/dev/null
      test "$(dpkg-query -W -f="\${db:Status-Status}" xkb-qwerty-fr)" = "installed"
      test ! -e /usr/share/X11/xkb/symbols/us.qwerty-fr
      test ! -e /usr/share/X11/xkb/symbols/us_qwerty-fr
      test "$vendor_us_before" = "$(sha256sum /usr/share/X11/xkb/symbols/us | cut -d" " -f1)"
      test "$vendor_xml_before" = "$(sha256sum /usr/share/X11/xkb/rules/evdev.xml | cut -d" " -f1)"
      xkbcli compile-keymap --layout us --variant qwerty-fr >/dev/null
      xkbcli compile-keymap --layout us >/dev/null
      xkbcli compile-keymap --layout us --variant dvorak >/dev/null
      xkbcli list | grep -Fq qwerty-fr
      xkbcli list | grep -Fq dvorak

      dpkg --purge xkb-qwerty-fr >/dev/null
      if xkbcli compile-keymap --layout us --variant qwerty-fr >/dev/null 2>&1; then
        printf "qwerty-fr still compiles after purge\n" >&2
        exit 1
      fi
      xkbcli compile-keymap --layout us >/dev/null
      xkbcli compile-keymap --layout us --variant dvorak >/dev/null
      test "$vendor_us_before" = "$(sha256sum /usr/share/X11/xkb/symbols/us | cut -d" " -f1)"
      test "$vendor_xml_before" = "$(sha256sum /usr/share/X11/xkb/rules/evdev.xml | cut -d" " -f1)"
      test ! -e /etc/xkb/symbols/us
      test ! -e /etc/xkb/rules/evdev.xml
    '
done

printf '%s\n' '=== reproduce the xkb-data 2.46 failure ==='
docker run --rm \
  --mount type=bind,src="$temp_dir/packages",dst=/packages,readonly \
  ubuntu:24.04 \
  sh -eu -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update >/dev/null
    apt-get install --yes --no-install-recommends perl xkb-data >/dev/null
    dpkg -i /packages/v0.7.3.deb >/dev/null
    if dpkg -i /packages/xkb-data-2.46.deb >/tmp/xkb-data-upgrade.log 2>&1; then
      printf "legacy package unexpectedly allowed the xkb-data transition\n" >&2
      exit 1
    fi
    grep -Fq /usr/share/X11/xkb/symbols/us.qwerty-fr /tmp/xkb-data-upgrade.log
    grep -Fq /usr/share/X11/xkb/symbols/us_qwerty-fr /tmp/xkb-data-upgrade.log
  '

printf '%s\n' '=== upgrade from 0.7.3 and transition xkb-data ==='
docker run --rm \
  --mount type=bind,src="$temp_dir/packages",dst=/packages,readonly \
  ubuntu:24.04 \
  sh -eu -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update >/dev/null
    apt-get install --yes --no-install-recommends libxkbcommon-tools libxkbregistry0 perl xkb-data >/dev/null

    vendor_us_before=$(sha256sum /usr/share/X11/xkb/symbols/us | cut -d" " -f1)
    dpkg -i /packages/v0.7.3.deb >/dev/null
    test -f /usr/share/X11/xkb/symbols/us.qwerty-fr
    test -f /usr/share/X11/xkb/symbols/us_qwerty-fr
    printf "interrupted legacy registry update\n" > /usr/share/X11/xkb/rules/evdev.xml.qwerty-fr
    xkbcli compile-keymap --layout us --variant qwerty-fr > /tmp/qwerty-fr-0.7.3.xkb

    dpkg -i /packages/current.deb >/dev/null
    test ! -e /usr/share/X11/xkb/symbols/us.qwerty-fr
    test ! -e /usr/share/X11/xkb/symbols/us_qwerty-fr
    test ! -e /usr/share/X11/xkb/rules/evdev.xml.qwerty-fr
    test "$vendor_us_before" = "$(sha256sum /usr/share/X11/xkb/symbols/us | cut -d" " -f1)"
    ! grep -Fq qwerty-fr /usr/share/X11/xkb/rules/evdev.xml
    xkbcli compile-keymap --layout us --variant qwerty-fr > /tmp/qwerty-fr-current.xkb
    cmp -s /tmp/qwerty-fr-0.7.3.xkb /tmp/qwerty-fr-current.xkb
    xkbcli compile-keymap --layout us --variant dvorak >/dev/null
    xkbcli list | grep -Fq qwerty-fr
    xkbcli list | grep -Fq dvorak

    dpkg -i /packages/xkb-data-2.46.deb >/dev/null
    test -L /usr/share/X11/xkb
    xkbcli compile-keymap --layout us --variant qwerty-fr >/dev/null
    xkbcli compile-keymap --layout us >/dev/null
    xkbcli compile-keymap --layout us --variant dvorak >/dev/null
    xkbcli list | grep -Fq qwerty-fr
    xkbcli list | grep -Fq dvorak
  '

printf '%s\n' '=== batched unpack before package configuration ==='
docker run --rm \
  --mount type=bind,src="$temp_dir/packages",dst=/packages,readonly \
  ubuntu:24.04 \
  sh -eu -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update >/dev/null
    apt-get install --yes --no-install-recommends libxkbcommon-tools libxkbregistry0 perl xkb-data >/dev/null
    dpkg -i /packages/v0.7.3.deb >/dev/null

    dpkg --unpack /packages/current.deb /packages/xkb-data-2.46.deb >/dev/null
    test ! -e /usr/share/X11/xkb/symbols/us.qwerty-fr
    test ! -e /usr/share/X11/xkb/symbols/us_qwerty-fr
    test -d /var/lib/xkb-qwerty-fr/upgrade-state

    test -f /usr/share/xkeyboard-config-2/symbols/us
    test -d /usr/share/X11/xkb
    test ! -L /usr/share/X11/xkb
    test ! -e /usr/share/X11/xkb/symbols/us
    vendor_us_after_transition=$(sha256sum /usr/share/xkeyboard-config-2/symbols/us | cut -d" " -f1)
    dpkg --unpack /packages/current.deb >/dev/null
    test "$vendor_us_after_transition" = "$(sha256sum /usr/share/xkeyboard-config-2/symbols/us | cut -d" " -f1)"
    test -d /usr/share/X11/xkb
    test ! -L /usr/share/X11/xkb
    test ! -e /usr/share/X11/xkb/symbols/us
    test -d /var/lib/xkb-qwerty-fr/upgrade-state

    dpkg --configure xkb-data >/dev/null
    test -L /usr/share/X11/xkb
    dpkg --configure xkb-qwerty-fr >/dev/null
    test ! -e /var/lib/xkb-qwerty-fr/upgrade-state
    xkbcli compile-keymap --layout us --variant qwerty-fr >/dev/null
    xkbcli compile-keymap --layout us --variant dvorak >/dev/null
    xkbcli list | grep -Fq qwerty-fr
  '

for failure_package in preinst-failure unpack-failure; do
  printf '=== unwind %s upgrade ===\n' "$failure_package"
  docker run --rm \
    --mount type=bind,src="$temp_dir/packages",dst=/packages,readonly \
    ubuntu:24.04 \
    sh -eu -c '
      export DEBIAN_FRONTEND=noninteractive
      failure_package=$1
      apt-get update >/dev/null
      apt-get install --yes --no-install-recommends libxkbcommon-tools perl xkb-data >/dev/null
      dpkg -i /packages/v0.7.3.deb >/dev/null

      if dpkg -i "/packages/$failure_package.deb" >/tmp/failed-upgrade.log 2>&1; then
        printf "intentional %s package unexpectedly installed\n" "$failure_package" >&2
        exit 1
      fi

      test "$(dpkg-query -W -f="\${Version}" xkb-qwerty-fr)" = 0.7.3
      test "$(dpkg-query -W -f="\${db:Status-Status}" xkb-qwerty-fr)" = installed
      test -f /usr/share/X11/xkb/symbols/us.qwerty-fr
      test -f /usr/share/X11/xkb/symbols/us_qwerty-fr
      cat \
        /usr/share/X11/xkb/symbols/us.qwerty-fr \
        /usr/share/X11/xkb/symbols/us_qwerty-fr \
        | cmp -s - /usr/share/X11/xkb/symbols/us
      test ! -e /var/lib/xkb-qwerty-fr/upgrade-state
      test ! -e /etc/xkb/symbols/us
      test ! -e /etc/xkb/rules/evdev.xml
      xkbcli compile-keymap --layout us --variant qwerty-fr >/dev/null
    ' sh "$failure_package"
done

printf '%s\n' '=== unwind old postrm failure ==='
docker run --rm \
  --mount type=bind,src="$temp_dir/packages",dst=/packages,readonly \
  ubuntu:24.04 \
  sh -eu -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update >/dev/null
    apt-get install --yes --no-install-recommends libxkbcommon-tools perl xkb-data >/dev/null
    dpkg -i /packages/old-postrm-failure.deb >/dev/null

    if dpkg -i /packages/current.deb >/tmp/failed-upgrade.log 2>&1; then
      printf "upgrade unexpectedly continued after the old postrm failed\n" >&2
      exit 1
    fi

    test "$(dpkg-query -W -f="\${Version}" xkb-qwerty-fr)" = 0.7.3
    test "$(dpkg-query -W -f="\${db:Status-Status}" xkb-qwerty-fr)" = installed
    test -f /usr/share/X11/xkb/symbols/us.qwerty-fr
    test -f /usr/share/X11/xkb/symbols/us_qwerty-fr
    cat \
      /usr/share/X11/xkb/symbols/us.qwerty-fr \
      /usr/share/X11/xkb/symbols/us_qwerty-fr \
      | cmp -s - /usr/share/X11/xkb/symbols/us
    test ! -e /var/lib/xkb-qwerty-fr/upgrade-state
    test ! -e /etc/xkb/symbols/us
    test ! -e /etc/xkb/rules/evdev.xml
    xkbcli compile-keymap --layout us --variant qwerty-fr >/dev/null
  '
