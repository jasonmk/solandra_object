module SolandraObject
  module Tasks
    class Keyspace
      def self.parse(hash)
        ks = Cassandra::Keyspace.new.with_fields hash
        ks.cf_defs = []
        hash['cf_defs'].each do |cf|
          ks.cf_defs << Cassandra::ColumnFamily.new.with_fields(cf)
        end
        ks
      end

      def exists?(name)
        connection.keyspaces.include? name.to_s
      end

      def create(name, options = {})
        opts = { :name => name.to_s,
                 :strategy_class => 'org.apache.cassandra.locator.SimpleStrategy',
                 :replication_factor => 1,
                 :cf_defs => [] }.merge(options)

        ks = Cassandra::Keyspace.new.with_fields(opts)
        connection.add_keyspace ks
      end

      def drop(name)
        connection.drop_keyspace name.to_s
      end

      def set(name)
        connection.keyspace = name.to_s
      end

      def get
        connection.keyspace
      end

      def clear
        return puts 'Cannot clear system keyspace' if connection.keyspace == 'system'

        connection.clear_keyspace!
      end

      def schema_dump
        connection.schema
      end

      def schema_load(schema)
        connection.schema.cf_defs.each do |cf|
          connection.drop_column_family cf.name
        end

        keyspace = get
        schema.cf_defs.each do |cf|
          cf.keyspace = keyspace
          connection.add_column_family cf
        end
      end

      private

        def connection
          unless @connection
            c = SolandraObject::Base.connection
            @connection = Cassandra.new('system', c.servers, c.thrift_client_options)
          end
          @connection
        end
    end
  end
end

class Cassandra
  class Keyspace
    def with_fields(options)
      struct_fields.collect { |f| f[1][:name] }.each do |f|
        send("#{f}=", options[f.to_sym] || options[f.to_s])
      end
      self
    end
  end
end
