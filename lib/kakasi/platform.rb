module Kakasi
  module Lib
    if defined?(::FFI::Platform)
      LIBPREFIX = ::FFI::Platform::LIBPREFIX
      LIBSUFFIX = ::FFI::Platform::LIBSUFFIX
    else
      LIBPREFIX =
        case RbConfig::CONFIG['host_os']
        when /mingw|mswin/i
          ''.freeze
        when /cygwin/i
          'cyg'.freeze
        else
          'lib'.freeze
        end

      LIBSUFFIX =
        case RbConfig::CONFIG['host_os']
        when /darwin/i
          'dylib'.freeze
        when /mingw|mswin|cygwin/i
          'dll'.freeze
        else
          'so'.freeze
        end
    end

    DEFLIBPATH =
      begin
        [RbConfig::CONFIG['libir']] |
          case RbConfig::CONFIG['host_os']
          when /mingw|mswin/i
            []
          else
            %w[/lib /usr/lib]
          end
      end.freeze

    def self.map_library_name(name)
      "#{LIBPREFIX}#{name}.#{LIBSUFFIX}"
    end

    def self.try_load(libpath = LIBPATH)
      basename = map_library_name('kakasi')
      (libpath | DEFLIBPATH).each { |dir|
        begin
          filename = File.join(dir, basename)
          yield filename
          return filename
        rescue LoadError, StandardError
          next
        end
      }

      yield basename
      return basename
    end
  end
end
