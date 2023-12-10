cask "qwerty-fr" do
  version "0.7.3"
  sha256 "7c8213994ae08323ab95837c586bb0863f77a334ec744ce8762332e7af345b70"

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
    "/System/Library/Caches/com.apple.IntlDataCache.le*",
  ]

  caveats do
    reboot
  end
end
