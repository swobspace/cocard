# app/views/notes/index.xml.builder
xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "Cocard - Aktuelle Notizen"
    xml.description "Cocard: Monitoring Telematik"
    xml.link notes_url

    @notes.each do |note|
      xml.item do
        xml.title note.notable
        xml.description note.message.to_plain_text
        xml.pubDate note.created_at.to_formatted_s(:rfc822)
        xml.link note_url(note)
        xml.guid note_url(note)
      end
    end
  end
end
