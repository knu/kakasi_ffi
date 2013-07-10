require 'kakasi/version'
begin
  require 'kakasi/impl'
rescue LoadError
  require 'kakasi/ffi'
end

module Kakasi
  def kakasi(options, string)
    Lib::kakasi(options, string)
  end
  module_function :kakasi
end
