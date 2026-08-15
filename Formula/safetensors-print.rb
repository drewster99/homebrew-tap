class SafetensorsPrint < Formula
  include Language::Python::Virtualenv

  desc "Print the header, metadata and data-segment layout of a .safetensors file"
  homepage "https://github.com/drewster99/safetensors-print"
  url "https://github.com/drewster99/safetensors-print/releases/download/v0.1.0/safetensors_print-0.1.0.tar.gz"
  sha256 "6eb0cbb6ef7fc03854fe33cf57c5503609e85cf6075f01444afc8398f57be796"
  license "MIT"

  depends_on "python@3.13"

  # No resource blocks: the package has no runtime dependencies.
  def install
    virtualenv_install_with_resources
  end

  test do
    header = '{"w":{"dtype":"U8","shape":[1],"data_offsets":[0,1]}}'
    # .b throughout: the packed length is a binary string, and concatenating it with a
    # UTF-8 one raises as soon as the length needs a byte above 127.
    (testpath/"m.safetensors").binwrite([header.bytesize].pack("Q<") + header.b + "\0".b)

    output = shell_output("#{bin}/safetensors-print #{testpath}/m.safetensors")
    assert_match "INTEGRITY", output
    assert_match "conforms to the safetensors specification", output

    # A file that cannot be read must exit 3, not merely print something.
    shell_output("#{bin}/safetensors-print #{testpath}/absent.safetensors 2>&1", 3)
  end
end
