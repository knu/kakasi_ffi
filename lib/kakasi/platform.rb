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

    def self.map_library_name(name)
      "#{LIBPREFIX}#{name}.#{LIBSUFFIX}"
    end

    def self.try_load(libpath = (::Kakasi::LIBPATH if defined?(::Kakasi::LIBPATH)))
      basename = map_library_name('kakasi')
      if libpath
        libpath.each { |dir|
          begin
            filename = File.join(dir, basename)
            yield filename
            return filename
          rescue
            next
          end
        }
        raise LoadError, 'Cannot load libkakasi'
      else
        yield basename
        return basename
      end
    end
  end
end
