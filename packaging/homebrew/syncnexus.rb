# Homebrew Cask for Sync-Nexus. Lives in a personal tap (a GitHub repo named  homebrew-syncnexus,  file  Casks/syncnexus.rb).
# Fill sha256 (and version, which Scripts/bump-version.sh keeps in step) from the output of Scripts/package.sh.
cask "syncnexus" do
  version "1.6.0"
  sha256 "REPLACE_WITH_SHA256_FROM_package.sh"

  url "https://github.com/hauchiehlin-ops/SyncNexus/releases/download/v#{version}/SyncNexus-#{version}.zip"
  name "Sync-Nexus"
  desc "Keeps local, iCloud, Google Drive and external-disk folders in sync"
  homepage "https://github.com/hauchiehlin-ops/SyncNexus"

  depends_on macos: ">= :sonoma"

  app "SyncNexus.app"

  # The app is not notarized (no paid Apple Developer account), so the download quarantine flag would make
  # Gatekeeper refuse the first launch. Removing it here is the usual practice for personal taps.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/SyncNexus.app"]
  end

  uninstall quit: "com.syncnexus.app"

  zap trash: [
    "~/Library/Application Support/SyncNexus",
    "~/Library/Logs/SyncNexus",
    "~/Library/Preferences/com.syncnexus.app.plist",
  ]
end
