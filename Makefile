TOOL_NAME = swift-graphql

PREFIX = /usr/local

INSTALL_PATH = $(PREFIX)/bin/$(TOOL_NAME)
SHARE_PATH = $(PREFIX)/share/$(TOOL_NAME)
BUILD_PATH = .build/release/$(TOOL_NAME)
CURRENT_PATH = $(PWD)

# Commands

build:
	swift build --disable-sandbox -c release --product $(TOOL_NAME)

install: build
	mkdir -p $(PREFIX)/bin
	cp -f $(BUILD_PATH) $(INSTALL_PATH)

uninstall:
	rm -f $(INSTALL_PATH)

REPO = https://github.com/maticzav/$(TOOL_NAME)
RELEASE_TAR = $(REPO)/archive/$(VERSION).tar.gz
SHA = $(shell curl -L -s $(RELEASE_TAR) | shasum -a 256 | sed 's/ .*//')

update_podspec:
	sed -i '' "s|\(version .* = '\)\(.*\)\('\)|\1$(VERSION)\3|" SwiftGraphQL.podspec

update_brew_formula:
	sed -i '' 's|\(url ".*/archive/\)\(.*\)\(.tar\)|\1$(VERSION)\3|' Formula/swiftgraphql.rb
	sed -i '' 's|\(sha256 "\)\(.*\)\("\)|\1$(SHA)\3|' Formula/swiftgraphql.rb