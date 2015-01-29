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
      expect(@meeting.agenda_url).to eq("#{@sire.baseurl}/mtgviewer.aspx?doctype=AGENDA&meetid=652")
    end
  end

  describe "#fetch_agenda_doc" do
    if ENABLE_NETWORK_OPERATIONS
      it "fetches the agenda" do
        expect(@meeting.fetch_agenda_doc).to be_instance_of(Nokogiri::HTML::Document)
      end
    end
  end

end


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
      expect(@sire.meeting_feed_url).to eq("#{@sire.baseurl}/rss/rss.aspx")
    end
  end

  describe "#fetch_meeting_feed_doc" do
    if ENABLE_NETWORK_OPERATIONS
      it "fetches the meeting feed" do
        expect(@sire.fetch_meeting_feed_doc).to be_instance_of(Nokogiri::XML::Document)
      end
    end
  end

  describe "#upcoming_meetings" do
    before(:each) do
      @doc = Nokogiri::XML(open("./examples/rss.aspx"))
    end
    it "processes the RSS feed" do
      cutoff = Time.parse("2015-01-27T21:37:12-06:00")
      meetings = @sire.upcoming_meetings(:doc => @doc, :cutoff => cutoff)
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
      expect(@sire.agenda_url(652)).to eq("#{@sire.baseurl}/mtgviewer.aspx?doctype=AGENDA&meetid=652")
    end
  end

  describe "#fetch_agenda_doc" do
    if ENABLE_NETWORK_OPERATIONS
      it "fetches the agenda" do
        expect(@sire.fetch_agenda_doc(652)).to be_instance_of(Nokogiri::HTML::Document)
      end
    end
  end

  describe "#parse_agenda" do
    before(:each) do
      @doc = Nokogiri::HTML(open("./examples/agview.aspx"))
    end

    it "parses the agenda" do
      items = @sire.parse_agenda(@doc)
      expect(items.length).to eq(53)
      expect(items.keys).to match_array((1..53).to_a)

      item = items[10]
      expect(item.id).to eq (38981)
      expect(item.num).to eq (10)
      expect(item.section).to eq ("Purchasing Office")
      expect(item.content).to start_with("<p>Authorize award and execution of a 36-month")

    end
  end

end
