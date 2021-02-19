# QWERTY-fr

Keyboard layout based on the QWERTY layout with extra symbols and diacritics so that typing both in French and English is easy and fast. It is also easy to learn!

![Keyboard layout screenshot](qwerty-fr-keymap.png)

## Philosophy overview

This layout is entirely compatible with the QWERTY layout. All the keys of the QWERTY layout are kept in the same location. This means that anyone using a QWERTY layout can type on the QWERTY-fr layout without even knowing that they are not typing on a QWERTY layout.

In order to type special characters with diacritics, there are a few simple rules to know. <kbd>AltGr</kbd> corresponds to <kbd>Option ⌥</kbd> on macOS, and <kbd>Ctrl</kbd> <kbd>Alt</kbd> on Windows (useful if you don't have the <kbd>AltGr</kbd> key):

| Diacritic                              | How to type it                                                                                        |
|----------------------------------------|-------------------------------------------------------------------------------------------------------|
| Grave accent <code>`</code>            | Press <kbd>AltGr</kbd> + corresponding letter (works for letters e, u, i, o and a).                   |
| Acute accent <code>´</code>            | Press <kbd>AltGr</kbd> + key left the corresponding letter (works for the letter e).                  |
| Circumflex <code>^</code>              | Press <kbd>AltGr</kbd> + key above the corresponding letter (works for letters e, y, u, i, o and a).  |
| Diaeresis <code>¨</code>               | Press <kbd>AltGr</kbd> + key below the corresponding letter (works for letters e, y, u, i, o and a). |
| Cedilla <code>¸</code>                 | Press <kbd>AltGr</kbd> + corresponding letter (works for the letter c).                               |
| Ligature <code>œ</code>/<code>æ</code> | Press <kbd>AltGr</kbd> + key right the corresponding letter (works for letters o and a).              |


**Note**: You can combine all of those with <kbd>Shift ⇧</kbd> and <kbd>Caps Lock</kbd>. So for example:
- <kbd>AltGr</kbd> <kbd>Shift ⇧</kbd> <kbd>C</kbd> outputs `Ç`.
- <kbd>AltGr</kbd> <kbd>Shift ⇧</kbd> <kbd>W</kbd> outputs `É`.

These two letters are impossible to type with an AZERTY layout. But with QWERTY-fr they are easy to type!


**Note 2**: You can type a [non-breaking space](https://en.wikipedia.org/wiki/Non-breaking_space) by pressing <kbd>AltGr</kbd> <kbd>Space</kbd>. And a [narrow non-breaking space (fr)](https://fr.wikipedia.org/wiki/Espace_fine_ins%C3%A9cable) by pressing <kbd>AltGr</kbd> <kbd>Shift ⇧</kbd> <kbd>Space</kbd>. Learn about when you should use them when typing French [here (fr)](https://typographisme.net/post/Les-espaces-typographiques-et-le-web).

## Installation

This keyboard layout is available Windows, Mac, and Linux.

### Windows

Download the [QWERTY-fr layout](http://marin.jb.free.fr/qwerty-fr/win-qwerty-fr.zip), extract it, and run **setup.exe**.

### Mac

Download the [QWERTY-fr layout](http://marin.jb.free.fr/qwerty-fr/qwerty-fr_mac.tgz) and extract **qwerty-fr.bundle** to :
- `/Library/Keyboard Layouts/` to install for all users.
- `~/Library/Keyboard Layouts/` for user-local installation.

You'll need to restart macOS before using it or otherwise you'll encounter bugs.

**Protip**: On Apple keyboards the right <kbd>Option ⌥</kbd> key is often hard to access. You can use [Karabiner-Elements](https://pqrs.org/osx/karabiner/) to switch the right <kbd>Option ⌥</kbd> key with the right <kbd>Commmand ⌘</kbd> key. This makes it easier to type characters!

### Linux

#### Ubuntu / Debian

Download the [DEB file](http://marin.jb.free.fr/qwerty-fr/xkb-qwerty-fr_0.5_all.deb) and install it.

**Note**: On Ubuntu and other GNOME-based distributions, you need to [disable the Compose key functionality](https://askubuntu.com/a/1028964) or typing characters with <kbd>AltGr</kbd> won't work at all.

#### Archlinux

There is a user package for this: https://aur.archlinux.org/packages/xkb-qwerty-fr/
Use your favorite AUR helper to install it. Or in the directory containing the `PKGBUILD` file, run `makepkg -si`.

# Contributing

The easiest way to contribute to this project is to spread the word!

If you want to contribute by fixing issues with the layout, adding new keys, etc. we use the following software to edit the layouts:
- **Windows**: [Microsoft Keyboard Layout Creator](https://www.microsoft.com/en-us/download/details.aspx?id=102134).
- **Mac**: [Ukelele](https://software.sil.org/ukelele/).
- **Linux**: manually editing files.
