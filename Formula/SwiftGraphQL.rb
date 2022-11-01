class Swiftgraphql < Formula
  desc "Code generator for SwiftGraphQL library"
  homepage "https://swift-graphql.org"
  license "MIT"
  
  url "https://github.com/maticzav/swift-graphql/archive/4.0.3.tar.gz"
  sha256 "89881b7aef34eb95013596072829ae72774008dda3fd1a97ceb5fb5ae1b74fb0"
  
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
