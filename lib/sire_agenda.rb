require 'nokogiri'
require 'open-uri'
require 'date'

class SireAgenda

  attr_accessor :baseurl

  # Construct a new SireAgenda object.
  #
  # Options:
  # * :baseurl - default is "http://austin.siretechnologies.com/sirepub"
  #
  def initialize(opts = {})
    @baseurl = opts[:baseurl] || "http://austin.siretechnologies.com/sirepub"
  end

  # URL for the agenda of a given meeting
  #
  # Parameters:
  # * meetid
  #
  # Returns string with URL of webpage with agenda for that meeting.
  #
  def url_agenda(meetid)
    "#{@baseurl}/mtgviewer.aspx?doctype=AGENDA&meetid=#{meetid}"
  end


  # URL for a given agenda item and its backup
  #
  # Parameters:
  # * itemid
  #
  # Returns string with URL of webpage with agenda item.
  #
  def url_item_backup(itemid)
    "#{@baseurl}/sirepub/agdocs.aspx?doctype=AGENDA&itemid=#{itemid}"
  end


  # Read the RSS feed and return all the upcoming meetings.
  #
  # Options:
  #  * :source
  #  * :cutoff
  #
  # Returns a hash on meetid of elements with members:
  #  * :meetid
  #  * :group
  #  * :meetdate
  #  * :pubdate
  #
  def list_meetings(opts = {})
    source = opts[:source] || "#{@baseurl}/rss/rss.aspx"
    cutoff = opts[:cutoff] || Time.now

    doc = Nokogiri::XML(open(source))
    meetings = {}

    doc.xpath("//item").each do |item|

      # "Austin City Council - 1/13/2011 10:00 AM"
      title = item.xpath("title").inner_text
      m = title.match(/(.*) - (.*)/)
      group = m[1]
      meetdate = Time.strptime(m[2], "%m/%d/%Y %I:%M %p")

      # Consider only future meetings.
      next unless meetdate > cutoff

      # There are some weird far future meetings in the feed.
      # Cut off stuff more than a year out.
      next if meetdate > cutoff + (365*24*60*60)

      # "https://austin.siretechnologies.com/sirepub/mtgviewer.aspx?meetid=576&doctype=AGENDA"
      link = item.xpath("link").inner_text
      m = link.match(/meetid=([\d]+)/)
      meetid = m[1].to_i

      pubdate = Time.parse(item.xpath("pubDate").inner_text)

      meetings[meetid] = {
        :meetid => meetid,
        :group => group,
        :meetdate => meetdate,
        :pubdate => pubdate,
      }

    end

    meetings
  end


  # Retrieve the agenda for a given meeting.
  #
  # Parameters:
  # * meetid -- Either a meeting id number or path to retrieved agenda file.
  #
  # The retrieved agenda, in a Nokogiri::HTML::Document
  #
  def get_agenda(meetid)
    if meetid.instance_of?(String) && File.exist?(meetid)
      Nokogiri::HTML(open(meetid))
    else
      Nokogiri::HTML(open(url_agenda(meetid)))
    end
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

