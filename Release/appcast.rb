require 'rexml/document'
require 'date'

# Code from CocoaPods-app's Rakefile
version = `./release.sh version`.delete!("\n")
build = `./release.sh build`.delete!("\n")
deployment_target = "10.10"
xml_file = "appcast.xml"
app_file = "TVShows-#{version}.dmg"
signature = `./sign_update #{app_file} ../Resources/dsa_priv.pem`
release_notes = "https://github.com/ilucas/TVShows/releases/tag/v#{version}"
download_url = "https://github.com/ilucas/TVShows/releases/download/v#{version}/#{app_file}"

description = <<-CODE
<ul><li> 
<p>For a full list of changes, <a href="#{release_notes}">Click here</a>.</p>
</li></ul> 
CODE

doc = REXML::Document.new(File.read(xml_file))
channel = doc.elements['/rss/channel']

# Add a new item to the Appcast feed
item = channel.add_element('item')
item.add_element("title").add_text("Version #{version}")
item.add_element("sparkle:minimumSystemVersion").add_text(deployment_target)
#item.add_element("sparkle:releaseNotesLink").add_text(release_notes)
item.add_element("description").add_text(REXML::CData.new(description))
item.add_element("pubDate").add_text(DateTime.now.strftime("%a, %d %h %Y %H:%M:%S %z"))

# Add the enclosure to the item 
enclosure = item.add_element("enclosure")
enclosure.attributes["type"] = "application/octet-stream"
enclosure.attributes["sparkle:shortVersionString"] = version
enclosure.attributes["sparkle:version"] = build
enclosure.attributes["sparkle:dsaSignature"] = signature
enclosure.attributes["length"] = File.size(app_file)
enclosure.attributes["url"] = download_url

# Write it out
formatter = REXML::Formatters::Pretty.new(2)
formatter.compact = true
new_xml = ""
formatter.write(doc, new_xml)
File.open(xml_file, 'w') { |file| file.write new_xml }
