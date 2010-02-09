Windows Azure Tables adapter for DataMapper
===========================================

This ruby gem will allow you to interact with the __Windows Azure Table Service API__ taking advantage of 
the DataMapper simplicity.

This adapter leverages the gem created by [Johnny Halife](http://blogs.southworks.net/jhalife/ "Johnny Halife") 
in which I contribute with Table services and some improvements on the core service.

You will find more information about this gem on ([waz-storage.heroku.com](http://waz-storage.heroku.com// "Windows Azure Storage library"))

**Note**: This gem is being developed, If you want to contribute you can fork this repo or giving feedback by email to [juanpablogarcia@gmail.com](mailto:juanpablogarcia@gmail.com "Juan Pablo Garcia Dalolla")

Gem Dependencies
----------------

- Windows Azure Storage library 1.0.0 ([waz-storage](http://waz-storage.heroku.com/ "Windows Azure Storage library"))

Getting started
---------------

	sudo gem install dm-waztables-adapter --source http://gemcutter.org

Usage
-----

	require 'dm-waztables-adapter'
	
	# set up a DataMapper with your Windwows Azure account 
	DataMapper.setup(:default, { :adapter => 'WAZTables', :account_name => 'name', :access_key => 'your_access_key' })

	# define a new model
	class Guitarist
		include DataMapper::Resource

		property :id, String, :key => true
		property :name, String
		property :age, Integer
	end

	# set up database table on Windows Azure for a specific model
	Guitarist.auto_migrate! # (destructive)
	Guitarist.auto_upgrade! # (safe)

	# set up database table on Windows Azure for all defined models
	Datamapper.auto_migrate! # (destructive)
	Datamapper.auto_upgrade! # (safe)
	
	# play with DataMapper as usual
	Guitarist.create(:id => '1', :name => 'Ritchie Blackmore', :age => 65)

	yngwie = Guitarist.new(:id => '2', :name => 'Yngwio Malmsteen', :age => 46)
	yngwie.name = "Yngwie Malmsteen"
	yngwie.save

	# retrieving a unique record by its id
	ritchie = Guitarist.get('1')
	ritchie.age # => 65

	# updating records
	ritchie.age = 66
	ritchie.save

	# retrieving all guitarists
		Guitarist.all.length # => 2

	# performing queries
		older_guitar_players = Guitarist.all( { :age.gte => 50 } )

	# deleting records
	older_guitar_players.destroy!

TODO
----

- Allow users to define the model partition key by using :partition_key => true option on the property.
- Allow users to set the partition key as an additional attribute of the model with a lambda as default value.
- Allow users to set the partition key as a method on the model.
- Implement “in” operator in queries
- Implement “order” query option
- Retrieve more than 1000 fields using Windows Azure :continuation_token

Known Issues
------------

- Like statements are not working since Microsoft service API is throwing a NotImplemented exception when 
using *startswith* and *endswith* filters ([more information here](http://msdn.microsoft.com/en-us/library/dd541448.aspx))
- There’s no way to tell thru the entity which is the partition key of our entity, so there’s no out-of-the-box load 
balancing support (for mor info on the tables model that a look at [http://msdn.microsoft.com/en-us/library/dd179338.aspx](http://msdn.microsoft.com/en-us/library/dd179338.aspx))