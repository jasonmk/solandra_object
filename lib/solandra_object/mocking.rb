require 'cassandra/mock'
module SolandraObject
  module Mocking
    extend ActiveSupport::Concern
    module ClassMethods
      def use_mock!(really=true)
        if really
          self.connection_class = Cassandra::Mock
        else
          self.connection_class = Cassandra
        end
      end
    end
  end
end
