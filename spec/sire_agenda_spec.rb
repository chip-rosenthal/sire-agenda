require './spec_helper.rb'

describe SireAgenda do

  before(:each) do
    @sire = SireAgenda.new
  end

  describe ".new" do
    it "creates an instance" do
      expect(@sire).to be_instance_of(SireAgenda)
    end
    it "has a baseurl" do
      baseurl = @sire.baseurl
      expect(baseurl).to eq("http://austin.siretechnologies.com/sirepub")
    end
  end

  describe "#url_agenda" do
    it "generates an URL from meeting id" do
      url = @sire.url_agenda("999")
      expect(url).to match(/mtgviewer.aspx\?doctype=AGENDA&meetid=999$/)
    end
  end

  describe "#url_item_backup"
    it "generates an URL from item id" do
      url = @sire.url_item_backup("999")
      expect(url).to match(/agdocs.aspx\?doctype=AGENDA&itemid=999$/)
    end

  describe "#list_meetings" do
    it "processes the RSS feed" do
      source = "./examples/rss.aspx"
      cutoff = Time.parse("2015-01-27T21:37:12-06:00")

      meetings = @sire.list_meetings(:source => source, :cutoff => cutoff)
      expect(meetings.length).to eq(5)
      expect(meetings.keys).to match_array(["652", "657", "665", "666", "690"])

      meeting = meetings["652"]
      expect(meeting).to have_key(:meetid)
      expect(meeting[:meetid]).to eq("652")
      expect(meeting).to have_key(:body)
      expect(meeting[:body]).to eq("Austin City Council")
      expect(meeting).to have_key(:meetdate)
      expect(meeting[:meetdate]).to eq(Time.parse("2015-01-29T10:00:00-06:00"))
      expect(meeting).to have_key(:pubdate)
      expect(meeting[:pubdate]).to eq(Time.parse("2015-01-26T16:06:07-06:00"))
    end
    if ENABLE_NETWORK_OPERATIONS
      it "fetches the RSS feed" do
        meetings = @sire.list_meetings
      expect(meetings).to be_instance_of(Hash)
      expect(meetings).not_to be_empty
      end
    end
  end

  describe "#get_agenda" do
    it "produces a nokogiri document " do
      doc = @sire.get_agenda("./examples/agview.aspx")
      expect(doc).to be_instance_of(Nokogiri::HTML::Document)
    end
    if ENABLE_NETWORK_OPERATIONS
      it "fetches the agenda" do
        doc = @sire.get_agenda("652")
        expect(doc).to be_instance_of(Nokogiri::HTML::Document)
      end
    end
  end

  describe "#parse_agenda" do
    it "parses the agenda"
  end

end
