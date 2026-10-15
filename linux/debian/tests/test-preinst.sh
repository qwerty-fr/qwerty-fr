#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname "$0")/../../.." && pwd -P)
preinst="$repo_root/linux/debian/DEBIAN/preinst"
postinst="$repo_root/linux/debian/DEBIAN/postinst"
postrm="$repo_root/linux/debian/DEBIAN/postrm"
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/qwerty-fr-maintscript-test.XXXXXX")

cleanup() {
  case "$temp_dir" in
    "${TMPDIR:-/tmp}"/qwerty-fr-maintscript-test.*)
      rm -rf -- "$temp_dir"
      ;;
    *)
      printf 'refusing to remove unexpected temporary path: %s\n' "$temp_dir" >&2
      exit 1
      ;;
  esac
}
trap cleanup EXIT HUP INT TERM

for script in "$preinst" "$postinst" "$postrm"; do
  if [ ! -f "$script" ]; then
    printf 'missing maintainer script: %s\n' "$script" >&2
    exit 1
  fi
done

root="$temp_dir/root"
xkb_root="$root/usr/share/X11/xkb"
symbols="$xkb_root/symbols"
rules="$xkb_root/rules"
state_dir="$root/var/lib/xkb-qwerty-fr/upgrade-state"

reset_root() {
  rm -rf -- "$root"
  mkdir -p "$symbols" "$rules"
}

write_normal_legacy_state() {
  cp "$temp_dir/vendor-us" "$symbols/us.qwerty-fr"
  cp "$temp_dir/qwerty-fr" "$symbols/us_qwerty-fr"
  cat "$symbols/us.qwerty-fr" "$symbols/us_qwerty-fr" > "$symbols/us"
}

run_preinst_upgrade() {
  DPKG_ROOT="$root" sh "$preinst" upgrade 0.7.3 0.7.4
}

run_preinst_install() {
  DPKG_ROOT="$root" sh "$preinst" install 0.7.3 0.7.4
}

run_postinst() {
  DPKG_ROOT="$root" sh "$postinst" configure 0.7.3
}

run_postrm() {
  DPKG_ROOT="$root" sh "$postrm" "$@"
}

assert_legacy_files_removed() {
  test ! -e "$symbols/us.qwerty-fr"
  test ! -e "$symbols/us_qwerty-fr"
}

assert_legacy_temporaries_removed() {
  for path in \
    "$rules/evdev.extras.xml.qwerty-fr" \
    "$rules/evdev.xml.qwerty-fr" \
    "$rules/base.extras.xml.qwerty-fr" \
    "$rules/base.xml.qwerty-fr" \
    "$xkb_root/base.xml.qwerty-fr"
  do
    test ! -e "$path"
    test ! -L "$path"
  done
}

write_legacy_temporaries() {
  printf 'temporary registry data\n' > "$rules/evdev.extras.xml.qwerty-fr"
  printf 'temporary registry data\n' > "$rules/evdev.xml.qwerty-fr"
  printf 'temporary registry data\n' > "$rules/base.extras.xml.qwerty-fr"
  printf 'temporary registry data\n' > "$rules/base.xml.qwerty-fr"
  printf 'temporary registry data\n' > "$xkb_root/base.xml.qwerty-fr"
}

assert_state_exists() {
  test -d "$state_dir"
  test -f "$state_dir/active"
  test -f "$state_dir/applied"
}

printf 'vendor data\n' > "$temp_dir/vendor-us"
printf 'qwerty-fr data\n' > "$temp_dir/qwerty-fr"

reset_root
write_normal_legacy_state
write_legacy_temporaries
cat "$symbols/us_qwerty-fr" >> "$symbols/us"
printf 'unrelated\n' > "$symbols/custom"
run_preinst_upgrade
cmp -s "$temp_dir/vendor-us" "$symbols/us"
assert_legacy_files_removed
assert_legacy_temporaries_removed
assert_state_exists
test -f "$symbols/custom"
run_preinst_upgrade
cmp -s "$temp_dir/vendor-us" "$symbols/us"
assert_legacy_files_removed
assert_state_exists
run_postinst
test ! -e "$state_dir"

reset_root
write_legacy_temporaries
run_preinst_install
assert_legacy_temporaries_removed
test ! -e "$state_dir"

reset_root
write_normal_legacy_state
run_preinst_upgrade
mkdir -p "$root/usr/share/xkeyboard-config-2"
mv "$root/usr/share/X11/xkb/symbols" "$root/usr/share/xkeyboard-config-2/symbols"
rmdir "$rules"
rmdir "$root/usr/share/X11/xkb"
ln -s ../xkeyboard-config-2 "$root/usr/share/X11/xkb"
printf 'new vendor data\n' > "$temp_dir/new-vendor-us"
cp "$temp_dir/new-vendor-us" "$symbols/us"
run_preinst_upgrade
cmp -s "$temp_dir/new-vendor-us" "$symbols/us"
assert_legacy_files_removed
assert_state_exists

reset_root
cp "$temp_dir/vendor-us" "$symbols/us.qwerty-fr"
cp "$temp_dir/qwerty-fr" "$symbols/us_qwerty-fr"
printf 'vendor data\nlocal change\nqwerty-fr data\n' > "$symbols/us"
printf 'vendor data\nlocal change\n' > "$temp_dir/vendor-plus-local"
run_preinst_upgrade
cmp -s "$temp_dir/vendor-plus-local" "$symbols/us"
assert_legacy_files_removed
assert_state_exists

reset_root
cp "$temp_dir/vendor-us" "$symbols/us.qwerty-fr"
printf 'vendor data\nqwerty-fr data\n' > "$symbols/us"
cp "$symbols/us" "$temp_dir/ambiguous-us"
run_preinst_upgrade
cmp -s "$temp_dir/vendor-us" "$symbols/us"
assert_legacy_files_removed
assert_state_exists
test -f "$state_dir/recovery"
cmp -s "$temp_dir/ambiguous-us" "$state_dir/recovery"
run_postinst
set -- "$root"/var/backups/xkb-qwerty-fr/us.before-migration.*
test "$#" -eq 1
test -f "$1"
cmp -s "$temp_dir/ambiguous-us" "$1"
test -f "$1"

reset_root
cp "$temp_dir/vendor-us" "$symbols/us.qwerty-fr"
run_preinst_upgrade
cmp -s "$temp_dir/vendor-us" "$symbols/us"
assert_legacy_files_removed
assert_state_exists

reset_root
cp "$temp_dir/qwerty-fr" "$symbols/us_qwerty-fr"
printf 'vendor data\nqwerty-fr data\n' > "$symbols/us"
run_preinst_upgrade
cmp -s "$temp_dir/vendor-us" "$symbols/us"
assert_legacy_files_removed
assert_state_exists

reset_root
printf 'vendor data\n' > "$symbols/us"
run_preinst_install
cmp -s "$temp_dir/vendor-us" "$symbols/us"
assert_legacy_files_removed
test ! -e "$state_dir"

reset_root
write_normal_legacy_state
run_preinst_upgrade
cmp -s "$temp_dir/vendor-us" "$symbols/us"
assert_legacy_files_removed
assert_state_exists
run_postrm abort-upgrade 0.7.3 0.7.4
cmp -s "$temp_dir/vendor-us" "$symbols/us"
cmp -s "$temp_dir/vendor-us" "$symbols/us.qwerty-fr"
cmp -s "$temp_dir/qwerty-fr" "$symbols/us_qwerty-fr"
test ! -e "$state_dir"
cat "$symbols/us.qwerty-fr" "$symbols/us_qwerty-fr" > "$temp_dir/old-postinst-result"
printf 'vendor data\nqwerty-fr data\n' > "$temp_dir/expected-old-state"
cmp -s "$temp_dir/expected-old-state" "$temp_dir/old-postinst-result"

reset_root
write_normal_legacy_state
printf 'local prefix\n' > "$symbols/us"
cat "$temp_dir/qwerty-fr" >> "$symbols/us"
cp "$symbols/us" "$temp_dir/install-target"
cp "$symbols/us.qwerty-fr" "$temp_dir/install-backup"
cp "$symbols/us_qwerty-fr" "$temp_dir/install-fragment"
run_preinst_install
assert_legacy_files_removed
assert_state_exists
run_postrm abort-install 0.7.3 0.7.4
cmp -s "$temp_dir/install-target" "$symbols/us"
cmp -s "$temp_dir/install-backup" "$symbols/us.qwerty-fr"
cmp -s "$temp_dir/install-fragment" "$symbols/us_qwerty-fr"
test ! -e "$state_dir"

reset_root
write_normal_legacy_state
run_preinst_upgrade
if run_postrm failed-upgrade 0.7.3 0.7.4 2>/dev/null; then
  printf 'failed-upgrade unexpectedly continued after the old postrm failed\n' >&2
  exit 1
fi
cmp -s "$temp_dir/vendor-us" "$symbols/us"
assert_legacy_files_removed
assert_state_exists
run_postrm abort-upgrade 0.7.3 0.7.4
cmp -s "$temp_dir/vendor-us" "$symbols/us"
cmp -s "$temp_dir/vendor-us" "$symbols/us.qwerty-fr"
cmp -s "$temp_dir/qwerty-fr" "$symbols/us_qwerty-fr"
test ! -e "$state_dir"

reset_root
if run_postrm failed-upgrade 0.7.3 0.7.4 2>/dev/null; then
  printf 'failed-upgrade unexpectedly succeeded without migration state\n' >&2
  exit 1
fi

reset_root
write_normal_legacy_state
run_postrm abort-upgrade 0.7.3 0.7.4
cmp -s "$temp_dir/vendor-us" "$symbols/us"
cmp -s "$temp_dir/vendor-us" "$symbols/us.qwerty-fr"
cmp -s "$temp_dir/qwerty-fr" "$symbols/us_qwerty-fr"

reset_root
write_normal_legacy_state
printf 'outside data\n' > "$temp_dir/outside-us"
rm -f "$symbols/us"
ln -s "$temp_dir/outside-us" "$symbols/us"
if run_preinst_upgrade 2>/dev/null; then
  printf 'migration unexpectedly followed a symbolic link\n' >&2
  exit 1
fi
test -L "$symbols/us"
test -f "$symbols/us.qwerty-fr"
test -f "$symbols/us_qwerty-fr"
printf 'outside data\n' > "$temp_dir/expected-outside-us"
cmp -s "$temp_dir/expected-outside-us" "$temp_dir/outside-us"
