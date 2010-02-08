module DataMapper
  module WAZTables
    class Adapter < DataMapper::Adapters::AbstractAdapter
      # @api semipublic
      def initialize(name, options = {})
        super
        WAZ::Storage::Base.establish_connection!(:account_name => options[:account_name], :access_key => options[:access_key])
      end

      # @api semipublic      
      def create(resources)
        service = WAZ::Tables::Table.service_instance
        resources.each do |resource|
          entity = {:row_key => resource.key.first}
          entity.merge!({:partition_key => resource.model.storage_name})
          resource.attributes.each { |a| entity.merge!({ a[0].to_sym => a[1] }) }
          service.insert_entity(resource.model.storage_name, entity)
        end
        resources.size
      end

      # @api semipublic
      def read(query)
        service = WAZ::Tables::Table.service_instance
        operator_mapping = {:gt => 'gt', :lt => 'lt', :gte => 'ge', :lte => 'le', :not => 'ne', :eql => 'eq'}

        conditions = query.conditions.map do |c|
          unless (c.class.name.eql?('Array'))
            case c.slug
              when :not then 
                "(#{c.operand.to_s.gsub(%r{=}, operator_mapping[c.slug]).gsub(%r{"}, "'")})"              
              when :like then
                # 
                name, value = c.subject.name, c.value.delete('%')
                (c.value =~ /^%/) ? "endswith(#{name}, '#{value}')" : ((c.value =~ /%$/) ? "startswith(#{name}, '#{value}')" : "(#{name} eq '#{value}')")
              when :regexp then
              else 
                "(#{c.subject.name} #{operator_mapping[c.slug]} #{c.value.class.name =~ /Fixnum|Float|Bignum/ ? c.value : "'#{c.value}'"})"
            end
          else
            query.conditions
          end
        end

        query_options = {:expression => conditions.sort.compact.join(' and ')}
        query_options.merge!({:top => query.limit}) if query.limit

        result = service.query(query.model.storage_name, query_options)

        records = result.map do |item|
          record = {}
          item.each { |k,v| record.merge!( { k.to_s => v } ) }
          record
        end
        
        query.filter_records(records)
      end

      # @api semipublic
      def update(attributes, resources)
        service = WAZ::Tables::Table.service_instance
        resources.each do |resource|
          entity = service.get_entity(resource.model.storage_name, resource.model.storage_name, resource.id)
          attributes.each do |attribute|
            entity[attribute[0].name] = attribute[1]
          end
          entity = service.update_entity(resource.model.storage_name, entity)
        end
        resources.size
      end

      # @api semipublic
      def delete(resources)
        service = WAZ::Tables::Table.service_instance
        resources.each do |resource|
          service.delete_entity(resource.model.storage_name, resource.model.storage_name, resource.id)
        end
        resources.size
      end
    end
  end
  
  Adapters::WAZTablesAdapter = DataMapper::WAZTables::Adapter
  Adapters.const_added(:WAZTablesAdapter)        
end