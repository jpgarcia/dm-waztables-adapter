module DataMapper
  module WAZTables
    module Migrations
      def self.included(base)
        DataMapper.extend(DataMapper::Migrations::SingletonMethods)
        [ :Repository, :Model ].each do |name|
          DataMapper.const_get(name).send(:include, DataMapper::Migrations.const_get(name))
        end
      end
 
      def storage_exists?(storage_name)
        WAZ::Tables::Table.find(storage_name)
      end
 
      def create_model_storage(model)
        WAZ::Tables::Table.create(model.storage_name)
      end
 
      def upgrade_model_storage(model)
        WAZ::Tables::Table.create(model.storage_name) unless self.storage_exists?(model.storage_name)
      end
 
      def destroy_model_storage(model)
        return unless (model_storage = self.storage_exists?(model.storage_name))
        model_storage.destroy!
      end
    end
  end
end
 
DataMapper::WAZTables.send(:include, DataMapper::WAZTables::Migrations)
DataMapper::WAZTables::Adapter.send(:include, DataMapper::WAZTables::Migrations)