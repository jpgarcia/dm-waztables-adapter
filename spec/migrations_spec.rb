require 'rubygems'
require 'spec'
require 'mocha'

require 'spec/spec_helpers'
require 'lib/dm-waztables-adapter'

describe "DataMapper Migrations for Model level behavior" do
  it "should remove an existing Azure Table and create a new one" do
    WAZ::Tables::Table.expects(:find).with('guitarists').returns(nil)    
    WAZ::Tables::Table.expects(:destroy!).never()
    WAZ::Tables::Table.expects(:create).with('guitarists').returns(mock())    
    Guitarist.auto_migrate!
  end

  it "should just create a new Azure Table" do
    mock_table = WAZ::Tables::Table.new(:name => 'guitarists', :url => 'url')
    mock_table.expects(:destroy!)
    WAZ::Tables::Table.expects(:find).with('guitarists').returns(mock_table)
    WAZ::Tables::Table.expects(:create).with('guitarists').returns(mock())    
    Guitarist.auto_migrate!
  end
  
  it "should create a new Azure Table only if it doesn't exist" do
    WAZ::Tables::Table.expects(:find).with('guitarists').returns(nil)
    WAZ::Tables::Table.expects(:destroy!).never()
    WAZ::Tables::Table.expects(:create).with('guitarists').returns(mock())    
    Guitarist.auto_upgrade!
  end
  
  it "should create a new Azure Table when it doesn't exist" do
    WAZ::Tables::Table.expects(:find).with('guitarists').returns(mock())
    WAZ::Tables::Table.expects(:destroy!).never()    
    WAZ::Tables::Table.expects(:create).with('guitarists').never()
    Guitarist.auto_upgrade!
  end
end

describe "DataMapper Migrations for Repository level behavior" do
  it "should remove existing Azure Tables and create new ones" do
    WAZ::Tables::Table.expects(:find).with('guitarists').returns(nil)
    WAZ::Tables::Table.expects(:destroy!).never()
    WAZ::Tables::Table.expects(:create).with('guitarists').returns(mock())

    mock_table = WAZ::Tables::Table.new(:name => 'guitars', :url => 'url')
    mock_table.expects(:destroy!)
    WAZ::Tables::Table.expects(:find).with('guitars').returns(mock_table)
    WAZ::Tables::Table.expects(:create).with('guitars').returns(mock())
    DataMapper.auto_migrate!
  end
  
  it "should create only if a Table doesn't exist" do
    WAZ::Tables::Table.expects(:find).with('guitarists').returns(nil)
    WAZ::Tables::Table.expects(:destroy!).never()
    WAZ::Tables::Table.expects(:create).with('guitarists').returns(mock())

    WAZ::Tables::Table.expects(:find).with('guitars').returns(mock())
    WAZ::Tables::Table.expects(:destroy!).never()
    WAZ::Tables::Table.expects(:create).never()
    DataMapper.auto_upgrade!
  end
end