require 'mkmf'
require 'rbconfig'

$stdout.sync = true

dir_config('kakasi')

module KakasiExtConf
  default_impl = {
    fiddle: ->{
      require 'fiddle/import'
      extend Fiddle::Importer
    },

    dl: ->{
      require 'dl/import'
      DL::CPtr.method_defined?(:[]=) or raise "DL::CPtr#[]= is missing"
      extend DL::Importer
    },

    ffi: ->{
      if defined?(Rubinius)
        FFI = Rubinius::FFI
      else
        require 'ffi'
      end
      extend FFI::Library
    },
  }.find { |impl, code|
    print "checking #{impl}... "
    begin
      code.call
    rescue LoadError, StandardError => e
      puts "no (#{e.message})"
      next false
    end
    puts "yes"
    break impl
  } or exit false

  print 'checking for kakasi... '

  require '../../lib/kakasi/platform.rb'

  begin
    libkakasi = Kakasi::Lib.try_load($LIBPATH) { |lib|
      case default_impl
      when :fiddle, :dl
        dlload lib
      when :ffi
        ffi_lib lib
      else
        raise LoadError, 'NOTREACHED'
      end
    }
    puts libkakasi
  rescue LoadError
    puts 'failed -- libkakasi is not found'
    exit false
  end

  '../../lib/kakasi/config.rb'.tap { |rb|
    puts 'creating %s' % rb
    File.open(File.expand_path(rb, File.dirname(__FILE__)), 'wt') { |f|
      f.print <<-'EOF' % [$LIBPATH.inspect, default_impl.inspect]
module Kakasi
  LIBPATH = %s unless defined?(LIBPATH)
  IMPL = %s unless defined?(IMPL)
end
      EOF
    }
  }
end

'Makefile'.tap { |mf|
  puts 'creating %s' % mf
  File.open(mf, 'w') { |f|
    f.print <<-'EOF'
all:
install:
    EOF
  }
}
