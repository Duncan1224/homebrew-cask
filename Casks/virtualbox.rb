cask "virtualbox" do
  version "6.1.34,150636"
  sha256 "a7c8550be90114db9fb3b05611b17a66530b74ac34be04bc5372df4f88abd43e"

  url "https://download.virtualbox.org/virtualbox/#{version.csv.first}/VirtualBox-#{version.csv.first}-#{version.csv.second}-OSX.dmg"
  name "Oracle VirtualBox"
  desc "Virtualizer for x86 hardware"
  homepage "https://www.virtualbox.org/"

  livecheck do
    url "https://www.virtualbox.org/wiki/Downloads"
    strategy :page_match do |page|
      match = page.match(/href=.*?VirtualBox-(\d+(?:\.\d+)+)-(\d+)-OSX.dmg/)
      next if match.blank?

      "#{match[1]},#{match[2]}"
    end
  end

  conflicts_with cask: "homebrew/cask-versions/virtualbox-beta"
  depends_on macos: ">= :high_sierra"
  depends_on arch: :x86_64

  pkg "VirtualBox.pkg",
      choices: [
        {
          "choiceIdentifier" => "choiceVBoxKEXTs",
          "choiceAttribute"  => "selected",
          "attributeSetting" => 1,
        },
        {
          "choiceIdentifier" => "choiceVBox",
          "choiceAttribute"  => "selected",
          "attributeSetting" => 1,
        },
        {
          "choiceIdentifier" => "choiceVBoxCLI",
          "choiceAttribute"  => "selected",
          "attributeSetting" => 1,
        },
        {
          "choiceIdentifier" => "choiceOSXFuseCore",
          "choiceAttribute"  => "selected",
          "attributeSetting" => 0,
        },
      ]

  postflight do
    # If VirtualBox is installed before `/usr/local/lib/pkgconfig` is created by Homebrew, it creates it itself
    # with incorrect permissions that break other packages
    # See https://github.com/Homebrew/homebrew-cask/issues/68730#issuecomment-534363026
    set_ownership "/usr/local/lib/pkgconfig"
  end

  uninstall script:  {
    executable: "VirtualBox_Uninstall.tool",
    args:       ["--unattended"],
    sudo:       true,
  },
            pkgutil: "org.virtualbox.pkg.*",
            delete:  "/usr/local/bin/vboximg-mount"

  zap trash: [
    "/Library/Application Support/VirtualBox",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/org.virtualbox.app.virtualbox*",
    "~/Library/Preferences/org.virtualbox.app.VirtualBox*",
    "~/Library/Saved Application State/org.virtualbox.app.VirtualBox*",
    "~/Library/VirtualBox",
  ],
      rmdir: "~/VirtualBox VMs"

  caveats do
    kext
  end
end
