require 'erb'
require 'nokogiri'
require 'dip'
require 'tipr'
require 'spec_helper'
require 'all_tipr_files_spec'

share_examples_for "all representations" do
  before(:each) do

    # need a daitss DIP
    path = File.join '..', 'DIPs', 'FDA0666001'
    @dip = DIP.new path

    # need the rep.xml template
    raw_xml = TIPR.generate_xml('rep.xml.erb', @dip, @type)
    @doc = Nokogiri::XML raw_xml   

    # some additional instance variables to help clean up the code
    @xmlns = { 'xmlns' => 'http://www.loc.gov/METS/' }  
    @rchildren = @doc.root.children.select { |child| child.name != 'text'}
    @divs = @doc.root.xpath('//xmlns:structMap/xmlns:div', @xmlns)
    @files = @doc.root.xpath('//xmlns:fileSec//xmlns:file', @xmlns)
  end

  it_should_behave_like AllTiprFiles
  
  it "should have a fileSec that points to representation descriptors" do
    # Validate each file representation descriptor.
    @files.each do |f|
      f['ID'].should_not be_nil
      f['CHECKSUM'].should_not be_nil
      f['CHECKSUMTYPE'].should == 'SHA-1'
      f.xpath('./xmlns:FLocat', @xmlns).first.should reference_a_file      
    end    
  end  
  
  describe "the struct map" do
    it "should have a file pointer for each file in the filesec" do
      fptrs = @divs.xpath('./xmlns:fptr', @xmlns).map { |fp| fp['FILEID'] }
      @files.each { |f| fptrs.should include(f['ID']) }   
    end
  end
end


describe "the original representation" do
  before(:each) do
    # this is the original representation
    @type = 'ORIG'
  end

  it_should_behave_like "all representations"  
end


describe "the active representation" do
  before(:each) do
    # this is the active representation
    @type = 'ACTIVE'
  end
  
  it_should_behave_like "all representations"
end
