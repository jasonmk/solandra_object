# Fixup the thrift library
require "thrift"
module Thrift
  class BinaryProtocol
    def write_string(str)
      write_i32(str.bytesize)
      trans.write(str)
    end
  end
end