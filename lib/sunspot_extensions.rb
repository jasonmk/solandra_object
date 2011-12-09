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
      
      def merge(search)
        search.query.instance_variable_get(:@sort).instance_variable_get(:@sorts).each { |s| query.add_sort s }
        paginate search.query.page, search.query.per_page
        
        # Remove duplicates, last one wins.
        seen = Hash.new
        
      end  
    end
  end  
end  
