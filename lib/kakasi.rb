require 'kakasi/version'

module Kakasi
  case RUBY_ENGINE
  when 'jruby'
    IMPL = :ffi unless defined?(IMPL)
  else
    begin
      require 'kakasi/config'
    rescue LoadError
      IMPL = :ffi unless defined?(IMPL)
    end
  end

  require 'kakasi/%s' % IMPL

  def kakasi(options, string)
    Lib::kakasi(options, string)
  end
  module_function :kakasi
end
