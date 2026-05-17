# WinGet manifests

This directory contains the Windows Package Manager manifests for QWERTY-fr.
They are laid out like the `microsoft/winget-pkgs` community repository so they
can be copied or submitted directly.

The initial manifest points to the `v0.7.3` Windows release ZIP, but its
`PackageVersion` is `1.0.3.40` because that is the version reported by the MSI
installers in Windows Apps & Features. WinGet uses the installed application
version for detection and upgrades, so using the release tag `0.7.3` here would
make WinGet compare against the wrong installed version.

## Publish to WinGet

1. Copy `manifests/q/qwerty-fr/qwerty-fr/1.0.3.40/` into a fork of
   `microsoft/winget-pkgs` at the same path.
2. Open a pull request against `microsoft/winget-pkgs`.
3. After the package is accepted, users can install QWERTY-fr with:

   ```powershell
   winget install --id qwerty-fr.qwerty-fr
   ```

## Updating for a new Windows release

1. Download the new `qwerty-fr_X.X.X_windows.zip` release asset.
2. Inspect the MSI properties:

   ```sh
   unzip qwerty-fr_X.X.X_windows.zip
   msiinfo export qwertyfr_amd64.msi Property
   msiinfo export qwertyfr_i386.msi Property
   shasum -a 256 qwerty-fr_X.X.X_windows.zip
   ```

3. Update `PackageVersion`, `InstallerUrl`, `InstallerSha256`, `ReleaseDate`,
   `ProductCode`, `UpgradeCode`, `DisplayVersion`, and nested MSI paths if they
   changed.
4. Validate the manifests before submitting them.
