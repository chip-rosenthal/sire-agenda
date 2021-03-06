require 'nokogiri'
require 'open-uri'
require 'date'

class NilClass
  def empty?
    true
  end
end

class String
  def cleanup_whitespace
    # \u00A0 is Unicode non-breaking space
    encode('utf-8').gsub("\u00A0", " ").gsub(/\s+/, " ").strip
  end
end

# Class for interacting with a remote Sire agenda management system.
#
class SireAgenda

  DEFAULT_BASEURL = "http://austin.siretechnologies.com/sirepub"

  attr_accessor :baseurl

  def initialize(opts = {})
    @baseurl = opts[:baseurl] || DEFAULT_BASEURL
  end

  # URL of the document that contains the RSS feed of all meetings.
  #
  def meeting_feed_url
    "#{@baseurl}/rss/rss.aspx"
  end


  # Returns a hash of Meeting instances, indexed on id.
  #
  def upcoming_meetings(content, opts = {})
    cutoff = opts[:cutoff] || Time.now

    doc = Nokogiri::XML(content)

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
        :sire => self,
      )

    end

    meetings
  end


  # URL of the HTML agenda document for a given meeting id.
  #
  def agenda_url(id)
    "#{@baseurl}/agview.aspx?agviewdoctype=AGENDA&agviewmeetid=#{id}"
  end


  # Parse an HTML agenda document to a hash of SireAgenda::AgendaItem
  # instances, indexed by agenda item number.
  #
  def parse_agenda(content)

    doc = Nokogiri::HTML(content)

    agenda = {}
    did_itemid = {}
    section = nil

    # The agenda is a big table. The rows that interest
    # us have two columns.
    #
    rows = doc.xpath("//tr")
    rows.each do |row|

      cols = row.xpath("td")
      next unless cols.length == 2

      field1 = cols[0].inner_text.cleanup_whitespace
      case field1

      # The rows with section headings have blank first column, and
      # section heading in the second column.
      when ""
        section = cols[1].inner_text.cleanup_whitespace

      # The rows with agenda items have the iten number (terminated with
      # a period) in the first column, and the item content in the second
      # column.
      when /^(\d+)\.$/
        itemno = $1.to_i

        a = cols[1].xpath(".//a[@name]").first
        m = a["name"].match(/^Item([\d]+)$/)
        itemid = m[1].to_i

        # The content of the agenda item, as de-shitified HTML text.
        #
        # Transformations made:
        #   * Strip out <a> and <span> tags.
        #   * Remove attributes of <p> tags.
        #
        content = cols[1].inner_html \
          .cleanup_whitespace \
          .gsub(/<(a|span) [^>]+>/, "") \
          .gsub(/<\/(a|span)>/, "") \
          .gsub(/<(p) [^>]+>/, "<\\1>")

        raise "section title missing or empty" if section.empty?

        raise "duplicate agenda itemid #{itemid}" if did_itemid.has_key?(itemid)
        did_itemid[itemid] = true

        raise "duplicate agenda itemno #{itemno}" if agenda.has_key?(itemno)
        agenda[itemno] = SireAgenda::AgendaItem.new(itemid,
          :num => itemno,
          :section => section,
          :content => content,
          :sire => self,
        )

      # Not sure what this row is. Be conservative and fail
      # so we can fix it.
      else
        raise "unrecognized column: \"#{field1}\""

      end

    end
    agenda
  end


  # URL of the HTML agenda item detail document for a given agenda item id.
  #
  def item_detail_url(id)
    "#{@baseurl}/agdocs.aspx?doctype=agenda&itemid=#{id}"
  end

  def extract_item_backup(content)
    doc = Nokogiri::HTML(content)
    backup = []
    doc.xpath("//table[@id=\"tblMaterials\"]//td[@class=\"tabledata\"]").each do |cell|
      m = cell.xpath("//a").first["href"].match(/fileid=([\d]+)/)
      id = m[1].to_i
      description = cell.inner_text.cleanup_whitespace
      backup << SireAgenda::AgendaItemBackup.new(id,
        :description => description,
        :sire => self,
      )
    end
    backup
  end

  # URL of an agenda item backup document for a given backup item id.
  #
  def item_backup_url(id)
    "#{@baseurl}/view.aspx?cabinet=published_meetings&fileid=#{id}"
  end

  # A meeting that has an agenda associated with it.
  #
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
      @group = params[:group] or raise "parameter \":group\" not defined"
      @meeting_time = params[:meeting_time] or raise "parameter \":meeting_time\" not defined"
      @last_changed = params[:last_changed] or raise "parameter \":last_changed\" not defined"
      @sire = params[:sire] or raise "parameter \":sire\" not defined"
    end

    # URL of the document that contains the agenda for this meeting.
    def agenda_url
      @sire.agenda_url(id)
    end

    # The agenda for this meeting, fetched from the web, as a Nokogiri::HTML::Document
    def fetch_agenda_doc
      Nokogiri::HTML(open(agenda_url))
    end

  end


  # An item on a meeting agenda.
  #
  class AgendaItem

    # Numeric id of this agenda item. This id is unique across
    # all agenda items for all meetings.
    attr_reader :id

    # Numeric item number. This is used for ordering items in a given meeting.
    attr_reader :num

    # Name of the section this agenda item is in, like."Purchasing"
    attr_reader :section

    # Content of the agenda item, as a cleaned up HTML string.
    attr_reader :content

    def initialize(id, params = {})
      @id = id
      @num = params[:num] or raise "parameter \":num\" not defined"
      @section = params[:section] or raise "parameter \":section\" not defined"
      @content = params[:content] or raise "parameter \":content\" not defined"
      @sire = params[:sire] or raise "parameter \":sire\" not defined"
    end

    def url
      @sire.agenda_item_url(id)
    end

  end

  class AgendaItemBackup

    attr_reader :id

    attr_reader :description

    def initialize(id, params = {})
      @id = id
      @description = params[:description] or raise "parameter \":description\" not defined"
      @sire = params[:sire] or raise "parameter \":sire\" not defined"
    end

  end # class AgendaItemBackup

end # class SireAgenda
