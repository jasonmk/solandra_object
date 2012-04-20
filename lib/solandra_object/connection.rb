module SolandraObject
  module Connection
    extend ActiveSupport::Concern
    
    included do
      class_attribute :connection
    end

    module ClassMethods
      DEFAULT_OPTIONS = {
        :servers => "127.0.0.1:9160",
        :thrift => {}
      }
      def establish_connection(spec)
        spec.reverse_merge!(DEFAULT_OPTIONS)
        self.connection = CassandraCQL::Database.new(spec[:servers], :keyspace => spec[:keyspace])
      end
    end
  end
end
