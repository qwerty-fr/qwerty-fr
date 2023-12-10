Run the following on a Mac (tested on macOS Monterey 12.1):

```shell
find ../bundle -name ".DS_Store" -type f -print -delete
pkgbuild --version 0.73 --root ../bundle --scripts scripts --identifier qwerty-fr.org.pkg --install-location /Library/Keyboard\ Layouts/ qwerty-fr.pkg
productbuild --distribution distribution.xml qwerty-fr-distribution.pkg
codesign -s - qwerty-fr-distribution.pkg
```

# FAQ

## Why not just create a DMG instead?

1. Users wouldn't be able to conveniently install the package to their home `~/Library/Keyboard Layouts/` directory if they need to (no admin rights for example). Even though DMG volumes can contain symbolic links and aliases, those need to be fully resolved paths. As such, you can't create a symbolic link/alias that contains `~`. Thanks to the `domains` option of a distribution PKG, we can add an extra step to ask the user if they want to install it for themselves or for everyone.

2. We couldn't have a `postinstall` script to guide the user through selecting the new keyboard layout.

3. We couldn't conveniently push the user to restart their computer (not doing so causes issues with the keyboard layout).
