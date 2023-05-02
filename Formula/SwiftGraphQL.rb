class Swiftgraphql < Formula
  desc "Code generator for SwiftGraphQL library"
  homepage "https://swift-graphql.org"
  license "MIT"
  
  url "https://github.com/maticzav/swift-graphql/archive/5.0.0.tar.gz"
  sha256 "e45ee788afb13116174e31270f145d8fdde1361eef07ebd09e047adb08c05406"
  
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
