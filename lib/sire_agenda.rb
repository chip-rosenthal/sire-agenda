require 'nokogiri'
require 'open-uri'
require 'date'

class String
  def cleanup_agenda_text
    # \u00A0 is Unicode non-breaking space
    encode('utf-8').gsub("\u00A0", " ").gsub(/\s+/, " ").strip
  end
end

class SireAgenda

  BASEURL = "http://austin.siretechnologies.com/sirepub"

  class Meeting

    # numeric id of this meeting
    attr_reader :id

    # group name, like "Austin City Council"
    attr_reader :group

    # meeting time, as a Time instance
    attr_reader :meeting_time

    # last change to the agenda, as a Time instance
    attr_reader :last_changed

    def initialize(id, params = {})
      @id = id
      @group = params[:group]
      @meeting_time = params[:meeting_time]
      @last_changed = params[:last_changed]
    end

    # URL of the document that contains the agenda for this meeting.
    def agenda_url
      "#{BASEURL}/mtgviewer.aspx?doctype=AGENDA&meetid=#{id}"
    end

    # The agenda for this meeting, fetched from the web, as a Nokogiri::HTML::Document
    def fetch_agenda_doc
      Nokogiri::HTML(open(agenda_url))
    end

  end

  class AgendaItem

    # numeric id of this agenda item
    attr_reader :id

    attr_reader :num
    attr_reader :section
    attr_accessor :text

    def item_url
      "#{BASEURL}/sirepub/agdocs.aspx?doctype=AGENDA&itemid=#{id}"
    end

  end

  # Construct a new SireAgenda object.
  #
  def initialize
    # empty
  end

  # URL of the document that contains the RSS feed of all meetings
  def meeting_feed_url
    "#{BASEURL}/rss/rss.aspx"
  end

  # RSS feed of all meetings, fetched from the web, as a Nokogiri::XML::Document
  def fetch_meeting_feed_doc
      Nokogiri::XML(open(meeting_feed_url))
  end

  # Returns a hash of Meeting instances, indexed on id.
  def upcoming_meetings(opts = {})
    doc = opts[:doc] || fetch_meeting_feed_doc
    cutoff = opts[:cutoff] || Time.now

    meetings = {}

    doc.xpath("//item").each do |item|

      # "Austin City Council - 1/13/2011 10:00 AM"
      title = item.xpath("title").inner_text
      m = title.match(/(.*) - (.*)/)
      group = m[1]
      meeting_time = Time.strptime(m[2], "%m/%d/%Y %I:%M %p")

      # Consider only future meetings.
      next unless meeting_time > cutoff

      # There are some weird far future meetings in the feed.
      # Cut off stuff more than a year out.
      next if meeting_time > cutoff + (365*24*60*60)

      # "https://austin.siretechnologies.com/sirepub/mtgviewer.aspx?meetid=576&doctype=AGENDA"
      link = item.xpath("link").inner_text
      m = link.match(/meetid=([\d]+)/)
      meetid = m[1].to_i

      pubdate = Time.parse(item.xpath("pubDate").inner_text)

      meetings[meetid] = SireAgenda::Meeting.new(meetid,
        :group => group,
        :meeting_time => meeting_time,
        :last_changed => pubdate,
      )

    end

    meetings
  end



  def parse_agenda(doc)

    agenda = {}
    did_itemid = {}
    section = nil

    #
    # The agenda is a big table. The rows that interest
    # us have two columns.
    #
    # The rows with section headings have blank first column, and
    # section heading in the second column.
    #
    # The rows with agenda items have the iten number (terminated with
    # a period) in the first column, and the item content in the second
    # column.
    #
    rows = doc.xpath("//tr")
    rows.each do |row|
      cols = row.xpath("td")
      next unless cols.length == 2

      field1 = cols[0].inner_text.cleanup_agenda_text
      case field1

      when ""
        section = cols[1].inner_text.cleanup_agenda_text

      when /^(\d+)\./
        itemno = $1.to_i

        a = cols[1].xpath(".//a[@name]").first
        m = a["name"].match(/^Item([\d]+)$/)
        itemid = m[1].to_i

        content = cols[1].children

        raise "duplicate agenda itemid #{itemid}" if did_itemid.has_key?(itemid)
        did_itemid[itemid] = true

        raise "duplicate agenda itemno #{itemno}" if agenda.has_key?(itemno)
        agenda[itemno] = {
          :itemid => itemid,
          :itemno => itemno,
          :section => section,
          :content => content,
        }

      else
        throw "unrecognized column: \"#{field1}\""

      end

    end
    agenda
  end

end # class SireAgenda

