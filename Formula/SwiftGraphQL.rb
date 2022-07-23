class SwiftGraphQL < Formula
  desc "Code generator for SwiftGraphQL library"
  homepage "https://swift-graphql.org"
  license "MIT"
  
  url "https://github.com/maticzav/swift-graphql/archive/2.3.0.tar.gz"
  sha256 "4f2d22e03ca65ce9b3f488bd48fb1b04b29c62f78d054e20e3d12c4f7a92aed8"
  
  head "https://github.com/maticzav/swift-graphql.git"

  depends_on :xcode
  uses_from_macos "libxml2"
  uses_from_macos "swift"

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  def test
    system "true"
  end
end
