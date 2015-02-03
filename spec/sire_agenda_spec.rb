require './spec_helper.rb'

describe SireAgenda::Meeting do

  before(:each) do
    @sire = SireAgenda.new
    @meeting = SireAgenda::Meeting.new(652,
      :group => "Austin City Council",
      :meeting_time => Time.parse("2015-01-01T00:00:00-06:00"),
      :last_changed => Time.parse("2015-01-01T00:00:00-06:00"),
      :sire => @sire,
    )
  end

  describe ".new" do
    it "creates an instance" do
      expect(@meeting).to be_instance_of(SireAgenda::Meeting)
    end
    it "has an id" do
      expect(@meeting.id).to eq(652)
    end
  end

  describe "#agenda_url" do
    it "produces agenda_url for the meeting" do
      @url = @meeting.agenda_url
      expect(@url).to eq("#{@sire.baseurl}/agview.aspx?agviewdoctype=AGENDA&agviewmeetid=652")
    end
  end

end # SireAgenda::Meeting

describe SireAgenda::AgendaItem # TODO

describe SireAgenda::AgendaItemBackup # TODO

describe SireAgenda do

  before(:each) do
    @sire = SireAgenda.new
  end

  describe ".new" do
    it "creates an instance" do
      expect(@sire).to be_instance_of(SireAgenda)
    end
  end

  describe "#meeting_feed_url" do
    it "produces URL for the meeting feed" do
      @url = @sire.meeting_feed_url
      expect(@url).to eq("#{@sire.baseurl}/rss/rss.aspx")
    end
  end

  describe "#upcoming_meetings" do
    before(:each) do
      @content = open("./examples/rss.aspx")
    end
    it "processes the RSS feed" do
      cutoff = Time.parse("2015-01-27T21:37:12-06:00")
      meetings = @sire.upcoming_meetings(@content, :cutoff => cutoff)
      expect(meetings.length).to eq(5)
      expect(meetings.keys).to match_array([652, 657, 665, 666, 690])

      meeting = meetings[652]
      expect(meeting.id).to eq(652)
      expect(meeting.group).to eq("Austin City Council")
      expect(meeting.meeting_time).to eq(Time.parse("2015-01-29T10:00:00-06:00"))
      expect(meeting.last_changed).to eq(Time.parse("2015-01-26T16:06:07-06:00"))
    end
  end

  describe "#agenda_url" do
    it "produces agenda_url for the meeting" do
      @url = @sire.agenda_url(652)
      expect(@url).to eq("#{@sire.baseurl}/agview.aspx?agviewdoctype=AGENDA&agviewmeetid=652")
    end
  end

  describe "#parse_agenda" do
    before(:each) do
      @content = open("./examples/agview.aspx")
    end

    it "parses the agenda" do
      items = @sire.parse_agenda(@content)
      expect(items.length).to eq(53)
      expect(items.keys).to match_array((1..53).to_a)

      item = items[10]
      expect(item.id).to eq (38981)
      expect(item.num).to eq (10)
      expect(item.section).to eq ("Purchasing Office")
      expect(item.content).to start_with("<p>Authorize award and execution of a 36-month")

    end
  end

  describe "#item_detail_url" do
    it "produces detail_url for the agenda item" do
      @url = @sire.item_detail_url(40268)
      expect(@url).to eq("#{@sire.baseurl}/agdocs.aspx?doctype=agenda&itemid=40268")
    end
  end

  describe "#extract_item_backup" do
    it "extracts backup items from agenda item doc" do
      @content = open("./examples/agdocs-40268.aspx")
      @backup = @sire.extract_item_backup(@content)
      expect(@backup).to be_array_of(SireAgenda::AgendaItemBackup)
      expect(@backup.length).to eq(4)
      expect(@backup.map {|b| b.id}).to match_array([940453, 940453, 940453, 940453])
    end
  end

  describe "#item_backup_url" do
    it "produces url for the agenda item backup document" do
      @url = @sire.item_backup_url(940453)
      expect(@url).to eq("#{@sire.baseurl}/view.aspx?cabinet=published_meetings&fileid=940453")
    end
  end

end # SireAgenda
