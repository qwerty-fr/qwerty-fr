cask "qwerty-fr" do
  version "0.7"
  sha256 "34bc8c8f764798ed7e48a3f2404319e09a6d8bfcbef350b25df32387a3199bfa"

  url "https://github.com/qwerty-fr/qwerty-fr/releases/download/v#{version}/qwerty-fr_#{version}_mac.zip",
      verified: "github.com/qwerty-fr/qwerty-fr/"
  name "qwerty-fr keyboard layout"
  desc "QWERTY-based layout. Type EU languages, greek, math, currencies, & more!"
  homepage "https://qwerty-fr.org/"

  depends_on macos: ">= :sierra"

  artifact "qwerty-fr.bundle", target: "/Library/Keyboard Layouts/qwerty-fr.bundle"

  postflight do
    # clear the layout cache before new layouts are recognized
    system_command "/bin/rm",
                   args: ["-f", "--", "/System/Library/Caches/com.apple.IntlDataCache.le*"],
                   sudo: true
  end

  uninstall delete: [
    "/Library/Keyboard Layouts/qwerty-fr.bundle/",
    "/Library/Caches/com.apple.IntlDataCache*",
    "/System/Library/Caches/com.apple.IntlDataCache.le*",
    "/private/var/folders/*/*/-Caches-/com.apple.IntlDataCache.le*",
  ]

  caveats do
    reboot
  end
end
