$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')

require 'lib/dm-waztables-adapter'

describe "WAZTables adapter functional tests" do
  it "should satisfy my expectations" do
    DataMapper.setup(:default, { :adapter => 'WAZTables',
                                 :account_name => ENV['AZURE_ACCOUNT_NAME_JPGD'],
                                 :access_key => ENV['AZURE_ACCESS_KEY_JPGD']})

    # define a new model
    class Guitarist
     include DataMapper::Resource

     property :id, String, :key => true
     property :name, String
     property :age, Integer
    end

    Guitarist.auto_upgrade!
    Guitarist.all.destroy!

    Guitarist.all.length.should == 0

    # creating a new record
    Guitarist.create(:id => '1', :name => 'Ritchie Blackmore', :age => 65)

    # creating a new record
    yngwie = Guitarist.new(:id => '2', :name => 'Yngwio Malmsteen', :age => 46)
    yngwie.name = "Yngwie Malmsteen"
    yngwie.save
    
    # retrieving a unique record by its id
    ritchie = Guitarist.get('1')
    ritchie.age.should == 65
    ritchie.name.should == "Ritchie Blackmore"

    # updating records
    ritchie.age = 66
    ritchie.save

    # retrieving all guitarists
    guitar_players = Guitarist.all
    guitar_players.length.should == 2
    guitar_players.first.name.should == "Ritchie Blackmore"
    guitar_players.first.age.should == 66
    guitar_players.last.name.should == "Yngwie Malmsteen"
    guitar_players.last.age.should == 46
        
    # performing queries
    older_guitar_players = Guitarist.all({ :age.gte => 50 })
    older_guitar_players.length.should == 1

    # deleting records
    older_guitar_players.destroy!
    Guitarist.all.length.should == 1
  end
end