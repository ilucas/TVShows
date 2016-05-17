#!/bin/sh

APPNAME=TVShows
info_plist=../$APPNAME/Info.plist

print_version() {
	/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$info_plist"
}

print_build() {
	/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$info_plist"
}

release() {
	ruby appcast.rb
	git add appcast.xml
	#git commit -m "v$(./release.sh version)"
}

print_usage() {
  echo "Usage: $(basename "$0") release     Update appcast.xml"
  echo "       $(basename "$0") version     Print app version"
  echo "       $(basename "$0") build       Print app build"
}

main() {
	case "$1" in
		version)
			print_version
			;;
		release)
			release
			;;
		build)
			print_build
			;;
		*)
			print_usage
			exit 1
			;;
	esac
}

main "$@"
