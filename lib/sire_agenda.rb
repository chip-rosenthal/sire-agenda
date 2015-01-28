require 'nokogiri'
require 'open-uri'
require 'date'

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
  def upcoming_meetings(doc, opts = {})
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



  # Parse a meeting agenda.
  #
  # Arguments:
  # * meetid
  # * doc - The agenda in a Nokogiri::HTML::Document
  #
  # Returns a hash on itemid of elements with members:
  #   * :itemid
  #   * :itemno
  #   * :section
  #   * :text
  #
  def parse_agenda(meetid, doc)

    raise "not implemented yet"

    rows = doc.xpath("//tr")
    agenda = {}
    section = nil

    (1 .. rows.length).each do |i|
      cols = rows[i-1].xpath("td")

      next unless cols.length == 2

      field0 = cols[0].inner_text.gsub(/\s+/, " ").strip
      case field0

      when "\u00A0"
        section = cols[1].inner_text.gsub(/\s+/, " ").strip

      when /^(\d+)\./
        itemno = $1

        a = cols[1].xpath(".//a[@name]").first
        m = a["name"].match(/^Item([\d]+)$/)
        itemid = m[1]

        content = cols[1].inner_html.gsub(/\s+/, " ").strip

        agenda[itemid] = {
          :itemid => itemid,
          :itemno => itemno,
          :section => section,
          :content => content,
        }

      else
        throw "unrecognized column: #{field0}"

      end

    end
    agenda
  end

end # class SireAgenda

