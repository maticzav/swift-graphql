class Swiftgraphql < Formula
  desc "Code generator for SwiftGraphQL library"
  homepage "https://swift-graphql.org"
  license "MIT"
  
  url "https://github.com/maticzav/swift-graphql/archive/4.0.4.tar.gz"
  sha256 "8a3cd5a630d446e52bad30a46bc1f741b964af1514beee804a1aa250a47cca3c"
  
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
