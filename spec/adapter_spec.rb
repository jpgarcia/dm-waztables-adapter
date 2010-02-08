$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')

require 'rubygems'
require 'spec'
require 'mocha'

require 'spec/spec_helpers'
require 'lib/dm-waztables-adapter'

describe "DataMapper adapter for Windows Azure Tables behavior" do
  it "should setup datamapper with WAZTables adapter" do
    WAZ::Storage::Base.expects(:establish_connection!).with({:account_name => 'account_name', :access_key => 'access_key'})
    DataMapper.setup(:default, { :adapter => 'WAZTables',
                                 :account_name => 'account_name',
                                 :access_key => 'access_key'})

    Guitarist.repository.adapter.options[:adapter].should == 'WAZTables'
  end
  
  it "should insert a new resource" do
    mock_service = mock()
    mock_entity = {:row_key => '1', :partition_key => 'guitarists', :id => '1', :name => 'Jimi Hendrix', :age => nil}
    mock_service.expects(:insert_entity).with('guitarists', mock_entity)
    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)
    guitarist = Guitarist.create({:id => '1', :name => 'Jimi Hendrix'})
    guitarist.should_not be_nil
  end
  
  it "should update a resource" do
    mock_service = mock()
    original = {:row_key => '2', :partition_key => 'guitarists', :id => '2', :name => 'some_name', :age => 23}    
    updated = {:row_key => '2', :partition_key => 'guitarists', :id => '2', :name => 'Joe Satriani', :age => 33}    
    mock_service.expects(:get_entity).with('guitarists', 'guitarists', '2').returns(original)
    mock_service.expects(:update_entity).with('guitarists', updated).returns(updated)
    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)

    mock_guitarist = Guitarist.new({:id => '2', :name => 'some_name', :age => 23})
    mock_guitarist.stubs(:saved?).returns(true)
    
    Guitarist.stubs(:get).with('2').returns(mock_guitarist)

    guitarist = Guitarist.get('2')
    guitarist.name = 'Joe Satriani'
    guitarist.age = 33
    guitarist.save
  end
  
  it "should delete a resource" do
    mock_service = mock()
    mock_service.expects(:delete_entity).with('guitarists', 'guitarists', '3')
    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)

    mock_guitarist = Guitarist.new({:id => '3', :name => 'Eric Clapton', :age => 23})
    mock_guitarist.stubs(:saved?).returns(true)
    
    Guitarist.stubs(:get).with('3').returns(mock_guitarist)    
    
    guitarist = Guitarist.get('3')
    guitarist.destroy
  end
  
  it "should get only one record when calling get with a given id" do
    mock_service = mock()
    mock_result = [{ :id => '4', :name => 'Zakk Wylde', :age => 43 }]
    mock_service.expects(:query).with('guitarists', {:expression => "(id eq '4')", :top => 1}).returns(mock_result)
    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)

    guitarist = Guitarist.get('4')
    guitarist.id.should == '4'
    guitarist.name.should == 'Zakk Wylde'
    guitarist.age.should == 43
  end
    
  it "should parse all conditions as well" do
    mock_service = mock()
    mock_result = [ { :id => '5', :name => 'Mark Knopfler', :age => 62 } ]
    expected_expression = "(age ge 20) and (age gt 19) and (age le 70) and (age lt 71) and (name eq 'Mark Knopfler') and (name ne 'Mar Knofler')"
    mock_service.expects(:query).with('guitarists', {:expression => expected_expression}).returns(mock_result)
    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)
    guitarists = Guitarist.all({ :age.gte => 20, :age.lte => 70, :age.gt => 19, :age.lt => 71, :name => 'Mark Knopfler', :name.not => 'Mar Knofler'})
    guitarists.length.should == 1
    
    guitarists.first.id.should == '5'
    guitarists.first.name.should == 'Mark Knopfler'
    guitarists.first.age.should == 62
  end
  
  it "should query with startswith filters when using like" do
    mock_service = mock()
    mock_result = [ { :id => '6', :name => 'Glenn Tipton', :age => 62 } ]
    mock_service.expects(:query).with('guitarists', { :expression => "startswith(name, 'Glen')" }).returns(mock_result)

    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)
    Guitarist.all({ :name.like => 'Glen%' }).length.should == 1
  end
  
  it "should query with endswith filters when using like" do
    mock_service = mock()
    mock_result = [ { :id => '6', :name => 'Glenn Tipton', :age => 62 } ]
    mock_service.expects(:query).with('guitarists', { :expression => "endswith(name, 'Tipton')" }).returns(mock_result)

    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)
    Guitarist.all({ :name.like => '%Tipton' }).length.should == 1
  end
  
  it "should query with eq when using like without % sign" do
    mock_service = mock()
    mock_result = [ { :id => '6', :name => 'Glenn Tipton', :age => 62 } ]
    mock_service.expects(:query).with('guitarists', { :expression => "(name eq 'Glenn Tipton')" }).returns(mock_result)
    
    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)
    Guitarist.all({ :name.like => 'Glenn Tipton' }).length.should == 1
  end

  it "should include top option when providing :limit option" do
    mock_service = mock()
    mock_result = [ { :id => '6', :name => 'Glenn Tipton', :age => 62 }, { :id => '2', :name => 'K. K. Downing', :age => 58 } ]
    mock_service.expects(:query).with('guitarists', { :expression => "(age ge 58)", :top => 10 }).returns(mock_result)

    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)
    Guitarist.all({ :age.gte => 58, :limit => 10 }).length.should == 2
  end
  
  it "should recieve a raw query using :conditions option" do
    mock_service = mock()
    mock_result = [ { :id => '6', :name => 'Glenn Tipton', :age => 62 }, { :id => '2', :name => 'K. K. Downing', :age => 58 } ]
    mock_service.expects(:query).with('guitarists', { :expression => "((age ge 50) and (age lt 100))" }).returns(mock_result)

    WAZ::Tables::Table.expects(:service_instance).returns(mock_service)
    Guitarist.all({ :conditions => ['(age ge 50) and (age lt 100)'] }).length.should == 2
  end
end