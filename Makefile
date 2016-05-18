APPNAME = TVShows

dependences:
	pod install

.PHONY: clean
clean: 
	cd Release && rm -rf $(APPNAME)* && make clean

.PHONY: distclean
distclean:
	xcodebuild clean -workspace $(APPNAME).xcworkspace -scheme $(APPNAME) -configuration Release

.PHONY: build
build: 
	xcodebuild -workspace $(APPNAME).xcworkspace -scheme $(APPNAME) -configuration Release

.PHONY: archive
archive: clean
	xcodebuild archive -workspace $(APPNAME).xcworkspace -scheme $(APPNAME) -archivePath Release/$(APPNAME).xcarchive
	xcodebuild -exportArchive -archivePath Release/$(APPNAME).xcarchive -exportFormat App -exportPath Release/$(APPNAME)

.PHONY: dist
dist: archive
	cd Release && make

.PHONY: release
release: dist
	cd Release && ./release.sh release

install: archive
	cp -pPR Release/$(APPNAME).app /Applications
