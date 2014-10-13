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
        [RbConfig::CONFIG['libdir']] |
          case RbConfig::CONFIG['host_os']
          when /mingw|mswin/i
            []
          else
            %w[/lib /usr/lib]
          end
      end.freeze

    class << self
      def try_load(libpath = LIBPATH)
        basename = map_library_name('kakasi')
        (libpath | DEFLIBPATH).each { |dir|
          filename = File.join(dir, basename)
          begin
            yield filename
          rescue LoadError
            next
          rescue
            next
          end
          return filename
        }

        begin
          yield basename
        rescue LoadError
          raise
        rescue
          raise LoadError, $!.message
        end

        return basename
      end

      private

      def map_library_name(name)
        "#{LIBPREFIX}#{name}.#{LIBSUFFIX}"
      end
    end
  end
end
