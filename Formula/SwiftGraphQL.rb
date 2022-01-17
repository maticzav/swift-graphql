class Swiftgraphql < Formula
  desc "GraphQL code generator and client written in Swift"
  homepage "https://github.com/maticzav/SwiftGraphQL"
  url "https://github.com/maticzav/swift-graphql/archive/2.3.0.tar.gz"
  sha256 "4f2d22e03ca65ce9b3f488bd48fb1b04b29c62f78d054e20e3d12c4f7a92aed8"
  license "MIT"
  head "https://github.com/maticzav/swift-graphql.git"

  depends_on :xcode
  uses_from_macos "libxml2"
  uses_from_macos "swift"

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end
end
