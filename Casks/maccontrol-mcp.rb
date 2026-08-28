cask "maccontrol-mcp" do
  version "0.2.45"
  sha256 "ecda36486a8848509f1d1dca97b8cca5d06e297aeea2efaf1fed33130e19bfd3"

  url "https://github.com/drewster99/drews-mac-control-mcp/releases/download/v#{version}/MacControlMCP-#{version}.zip"
  name "MacControlMCP"
  desc "MCP server for driving apps and the iOS Simulator via Accessibility"
  homepage "https://github.com/drewster99/drews-mac-control-mcp"

  depends_on macos: :sonoma

  app "MacControlMCP.app"

  # Opening the app once is what registers the host LaunchAgent via SMAppService and raises the
  # permission prompts; nothing works until that has happened.
  postflight do
    system_command "/usr/bin/open", args: ["--background", "#{appdir}/MacControlMCP.app"]
  end

  # early_script runs while the bundle still exists, which is the only moment the registration can
  # be removed: deleting the app does not clear its Background Task Management record, leaving a
  # login item pointing at nothing that only the user can find and remove.
  uninstall early_script: {
              executable: "MacControlMCP.app/Contents/MacOS/MacControlMCP",
              args:       ["--unregister-and-exit"],
            },
            launchctl:    "com.nuclearcyborg.maccontrol.host",
            quit:         "com.nuclearcyborg.maccontrol"

  zap trash: [
    "~/Library/Logs/MacControlMCP",
    "~/Library/Preferences/com.nuclearcyborg.maccontrol.plist",
  ]

  caveats <<~EOS
    Grant Accessibility — and Screen Recording for screenshots — to MacControlMCP in
    System Settings > Privacy & Security, then point your MCP client at the relay:

      claude mcp add --scope user maccontrol #{appdir}/MacControlMCP.app/Contents/Helpers/MacControlRelay

      codex mcp add maccontrol -- #{appdir}/MacControlMCP.app/Contents/Helpers/MacControlRelay
  EOS
end
