CLANG	    = /usr/bin/clang
ARCH	    = -arch armv7
SDK	    = -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk
OS_VER_MIN  = -miphoneos-version-min=5.0
OPTIONS     = -fsyntax-only -x objective-c -std=gnu99
WARNINGS    = -Wreturn-type -Wparentheses -Wswitch -Wno-unused-parameter -Wunused-variable -Wunused-value
INCLUDES    = -I.
FRAMEWORKS  = -F../

test: build-test
	GHUNIT_AUTORUN=1 GHUNIT_AUTOEXIT=1 waxsim -f ipad build/Debug-iphonesimulator/Tests.app; pkill 'iPhone Simulator'

build:
	xcodebuild -project Fauna.xcodeproj -target Fauna -configuration Debug -sdk iphonesimulator build

build-test:
	xcodebuild -project Fauna.xcodeproj -target Tests -configuration Debug -sdk iphonesimulator build

clean:
	rm -rf build && xcodebuild -project Fauna.xcodeproj -target Tests -configuration Debug -sdk iphonesimulator clean

check-syntax:
	$(CLANG) $(OPTIONS) $(ARCH) $(WARNINGS) $(SDK) $(OS_VER_MIN) $(INCLUDES) $(FRAMEWORKS) ${CHK_SOURCES}

.PHONY: clean build build-test test check-syntax
