require 'sunspot_rails'
module Sunspot
  module Search
    class StandardSearch
      def clone
        ss = dup
        cloned_query = Marshal.load(Marshal.dump(@query))
        ss.instance_variable_set(:@query, cloned_query)
        ss
      end
      
      
    end
  end  
end  
