require 'kakasi/version'

module Kakasi
  case RUBY_ENGINE
  when 'jruby'
    LIBKAKASI = 'kakasi' unless defined?(LIBKAKASI)
    IMPL = :ffi unless defined?(IMPL)
  else
    begin
      require 'kakasi/config'
    rescue LoadError
      require 'rbconfig'
      LIBKAKASI = RbConfig::CONFIG['LIBRUBY_SO'].tap { |so|
        prefix = so[/\A(?:lib|)/]
        suffix = so[/\.(?![0-9]+(?:\.|\z))[^.]+/] or raise 'failed to detect the file extension for dynamic libraries'
        break prefix + 'kakasi' + suffix
      } unless defined?(LIBKAKASI)
      IMPL = :ffi unless defined?(IMPL)
    end
  end

  require 'kakasi/%s' % IMPL

  def kakasi(options, string)
    Lib::kakasi(options, string)
  end
  module_function :kakasi
end
