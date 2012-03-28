require 'sunspot'
module SolrNoEscape
  def escape(str)
    str # We are purposely not escaping since we want people to be able to do
        # advanced queries that otherwise wouldn't work.
  end
end

module Sunspot
  module Query
    class FunctionQuery
      include SolrNoEscape
    end
  end
end

module Sunspot
  module Query
    module Restriction
      class Base
        include SolrNoEscape
      end
    end
  end
end

