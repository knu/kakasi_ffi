require 'kakasi/version'

module Kakasi
  case RUBY_ENGINE
  when 'jruby'
    LIBPATH = [].freeze
    IMPL = :ffi unless defined?(::Kakasi::IMPL)
  else
    begin
      require 'kakasi/config'
    rescue LoadError
      LIBPATH = [].freeze
      IMPL = :ffi unless defined?(::Kakasi::IMPL)
    end
  end

  require 'kakasi/%s' % IMPL

  def kakasi(options, string)
    Lib::kakasi(options, string)
  end
  module_function :kakasi
end
