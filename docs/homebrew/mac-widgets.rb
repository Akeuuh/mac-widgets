cask "mac-widgets" do
  version "0.1.0"
  sha256 "e31b63c86d879101f91b6bfd8b161739c947fc0cade7393bc63321487d562807"

  url "https://github.com/Akeuuh/mac-widgets/releases/download/v#{version}/MacWidgets-#{version}.dmg"
  name "Mac Widgets"
  desc "Native macOS widgets to follow GitHub pull requests at a glance"
  homepage "https://github.com/Akeuuh/mac-widgets"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "MacWidgets.app"

  zap trash: [
    "~/Library/Containers/io.github.akeuuh.MacWidgets",
    "~/Library/Containers/io.github.akeuuh.MacWidgets.Widget",
  ]
end
