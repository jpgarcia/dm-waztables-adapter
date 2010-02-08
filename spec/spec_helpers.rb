Spec::Runner.configure do |config|
  config.mock_with :mocha

  config.before :each do
    class Guitarist
      include DataMapper::Resource

      property :id, String, :key => true
      property :name, String
      property :age, Integer
    end

    class Guitar
      include DataMapper::Resource

      property :id, String, :key => true
      property :brand, String
    end
    DataMapper.setup(:default, { :adapter => 'WAZTables', :name => 'db', :account_name => 'n', :access_key => 'k'})
  end
 
  config.after :each do
    DataMapper::Repository.adapters.delete(:default)
  end
end