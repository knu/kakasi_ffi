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
      require 'ffi'
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

  libkakasi = Enumerator.new { |y|
    libfilename = RbConfig::CONFIG['LIBRUBY_SO'].tap { |so|
      prefix = so[/\A(?:lib|)/]
      suffix = so[/\.(?![0-9]+(?:\.|\z))[^.]+/] or raise 'failed to detect the file extension for dynamic libraries'
      break prefix + 'kakasi' + suffix
    }

    $LIBPATH.each { |dir|
      y << File.join(dir, libfilename)
    }
    y << 'kakasi'
    y << 'libkakasi'
    y << libfilename
  }.find { |lib|
    begin
      case default_impl
      when :fiddle, :dl
        dlload lib
      when :ffi
        ffi_lib lib
      else
        next false
      end
      puts lib
      true
    rescue LoadError, StandardError
      false
    end
  } or
    begin
      puts 'FAILED!'
      exit false
    end

  '../../lib/kakasi/config.rb'.tap { |rb|
    puts 'creating %s' % rb
    File.open(File.expand_path(rb, File.dirname(__FILE__)), 'wt') { |f|
      f.print <<-'EOF' % [libkakasi.inspect, default_impl.inspect]
module Kakasi
  LIBKAKASI = %s unless defined?(LIBKAKASI)
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
