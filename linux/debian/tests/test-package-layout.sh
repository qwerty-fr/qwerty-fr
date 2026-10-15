#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname "$0")/../../.." && pwd -P)
if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is unavailable\n' >&2
  exit 1
fi
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/qwerty-fr-package-test.XXXXXX")

cleanup() {
  case "$temp_dir" in
    "${TMPDIR:-/tmp}"/qwerty-fr-package-test.*)
      if [ ! -d "$temp_dir" ] || [ -L "$temp_dir" ]; then
        printf 'refusing to remove non-directory temporary path: %s\n' "$temp_dir" >&2
        exit 1
      fi
      rm -rf -- "$temp_dir"
      ;;
    *)
      printf 'refusing to remove unexpected temporary path: %s\n' "$temp_dir" >&2
      exit 1
      ;;
  esac
}
trap cleanup EXIT HUP INT TERM

cp -R "$repo_root/linux" "$temp_dir/linux"

docker run --rm \
  --mount type=bind,src="$temp_dir",dst=/work \
  ubuntu:24.04 \
  sh -eu -c '
    export DEBIAN_FRONTEND=noninteractive
    apt-get update >/dev/null
    apt-get install --yes --no-install-recommends dpkg-dev fakeroot lintian make shellcheck unzip zip >/dev/null
    find /work/linux -exec touch {} +

    shellcheck -s sh \
      /work/linux/debian/DEBIAN/preinst \
      /work/linux/debian/DEBIAN/postinst \
      /work/linux/debian/DEBIAN/postrm \
      /work/linux/debian/tests/test-preinst.sh \
      /work/linux/debian/tests/test-package-layout.sh \
      /work/linux/debian/tests/test-integration.sh

    cd /work/linux/debian
    make deb >/dev/null

    set -- ./xkb-qwerty-fr_*_all
    if [ "$#" -ne 1 ] || [ ! -d "$1" ]; then
      printf "expected one package directory, found: %s\n" "$*" >&2
      exit 1
    fi
    build_directory=$1
    printf "stale maintainer script\n" > "$build_directory/DEBIAN/prerm"
    sleep 1
    touch DEBIAN/control
    make deb >/dev/null
    if [ -e "$build_directory/DEBIAN/prerm" ]; then
      printf "incremental rebuild retained a deleted maintainer script\n" >&2
      exit 1
    fi

    set -- ./*.deb
    if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
      printf "expected one Debian package, found: %s\n" "$*" >&2
      exit 1
    fi
    package=$1

    set -- ./*.zip
    if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
      printf "expected one ZIP package, found: %s\n" "$*" >&2
      exit 1
    fi
    zip_package=$1
    zipinfo -1 "$zip_package" > /work/zip-contents
    grep -Fxq etc/xkb/symbols/us /work/zip-contents
    grep -Fxq etc/xkb/rules/evdev.xml /work/zip-contents
    if grep -Eq "^usr/share/X11/xkb(/|$)" /work/zip-contents; then
      printf "ZIP package must not install files in /usr/share/X11/xkb\n" >&2
      exit 1
    fi

    mkdir /work/payload /work/control
    dpkg-deb --extract "$package" /work/payload
    dpkg-deb --control "$package" /work/control

    if find /work/payload/usr/share/X11/xkb -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
      printf "package must not install files in /usr/share/X11/xkb\n" >&2
      exit 1
    fi

    test -f /work/payload/etc/xkb/symbols/us
    test -f /work/payload/etc/xkb/rules/evdev.xml
    test -x /work/control/preinst
    test -x /work/control/postinst
    test -x /work/control/postrm

    depends=$(dpkg-deb --field "$package" Depends)
    case "$depends" in
      *"libxkbcommon0 (>= 1.0.0)"*) ;;
      *) printf "missing minimum libxkbcommon dependency: %s\n" "$depends" >&2; exit 1 ;;
    esac
    case "$depends" in
      *"libxkbregistry0 (>= 1.0.0)"*) ;;
      *) printf "missing minimum libxkbregistry dependency: %s\n" "$depends" >&2; exit 1 ;;
    esac
    case "$depends" in
      *perl*) printf "obsolete Perl dependency remains: %s\n" "$depends" >&2; exit 1 ;;
    esac

    printf "%s\n" \
      /etc/xkb/rules/evdev.xml \
      /etc/xkb/symbols/us > /work/expected-conffiles
    cmp -s /work/expected-conffiles /work/control/conffiles

    for script in prerm triggers; do
      if [ -e "/work/control/$script" ]; then
        printf "package must not ship %s\n" "$script" >&2
        exit 1
      fi
    done

    lintian --fail-on warning,error "$package"
  '
