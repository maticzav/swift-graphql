TOOL_NAME = swift-graphql

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(TOOL_NAME)
SHARE_PATH = $(PREFIX)/share/$(TOOL_NAME)
BUILD_PATH = .build/release/$(TOOL_NAME)
CURRENT_PATH = $(PWD)
REPO = https://github.com/maticzav/$(TOOL_NAME)
RELEASE_TAR = $(REPO)/archive/$(VERSION).tar.gz
SHA = $(shell curl -L -s $(RELEASE_TAR) | shasum -a 256 | sed 's/ .*//')

build:
	swift build --disable-sandbox -c release

install: build
	mkdir -p $(PREFIX)/bin
	cp -f $(BUILD_PATH) $(INSTALL_PATH)

uninstall:
	rm -f $(INSTALL_PATH)

format:
	swiftformat .

update_brew:
	sed -i '' 's|\(url ".*/archive/\)\(.*\)\(.tar\)|\1$(VERSION)\3|' Formula/swiftgraphql.rb
	sed -i '' 's|\(sha256 "\)\(.*\)\("\)|\1$(SHA)\3|' Formula/swiftgraphql.rb

	git add .
	git commit -m "Update HomeBrew Formula to $(VERSION)"