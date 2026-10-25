class Transcribe < Formula
  desc "Transcribe audio and video files using on-device speech recognition"
  homepage "https://github.com/drewster99/macos-transcribe"
  url "https://github.com/drewster99/macos-transcribe/releases/download/v0.1.1/transcribe-0.1.1-macos-arm64.tar.gz"
  sha256 "56f9709436ded596947ab959b936dee8be9f35125e16d85a8249916cc82e9add"
  license "MIT"
  # Stated explicitly: the asset name carries the platform and architecture, so Homebrew cannot
  # infer the version from the URL.
  version "0.1.1"

  # The on-device speech models are Apple silicon only, and SpeechAnalyzer requires macOS 26.
  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "transcribe"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/transcribe --version")

    # Every supported locale is a BCP-47 tag, so the listing must name at least one.
    assert_match(/[a-z]{2}-[A-Z]{2}/, shell_output("#{bin}/transcribe --list-locales"))

    # A missing file must exit 66, not merely print something.
    shell_output("#{bin}/transcribe #{testpath}/absent.m4a 2>&1", 66)

    # A file that is not media must be rejected as unusable input rather than transcribed.
    (testpath/"notes.mp4").write("this is not a video")
    shell_output("#{bin}/transcribe #{testpath}/notes.mp4 2>&1", 65)
  end
end
