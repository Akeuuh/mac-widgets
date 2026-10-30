cask "mac-widgets" do
  version "0.1.0"
  sha256 "REMPLACER_PAR_LE_SHA256_AFFICHÉ_PAR_scripts/release.sh"

  url "https://github.com/Akeuuh/mac-widgets/releases/download/v#{version}/MacWidgets-#{version}.dmg"
  name "Mac Widgets"
  desc "Widgets macOS pour suivre ses pull requests GitHub"
  homepage "https://github.com/Akeuuh/mac-widgets"

  depends_on macos: ">= :sonoma"

  app "MacWidgets.app"
end
