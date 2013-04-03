test: build
	GHUNIT_AUTORUN=1 GHUNIT_AUTOEXIT=1 waxsim -f ipad build/Debug-iphonesimulator/Tests.app; pkill 'iPhone Simulator'

build:
	xcodebuild -project Fauna.xcodeproj -target Tests -configuration Debug -sdk iphonesimulator build

clean:
	rm -rf build && xcodebuild -project Fauna.xcodeproj -target Tests -configuration Debug -sdk iphonesimulator clean

.PHONY: clean build test
