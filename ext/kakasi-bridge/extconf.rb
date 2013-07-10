$stdout.sync = true

impl = {
  fiddle: ->(mod) {
    require 'fiddle/import'
    mod.extend Fiddle::Importer
    mod.dlload 'libkakasi.so'
    'fiddle'
  },

  dl: ->(mod) {
    require 'dl/import'
    mod.extend DL::Importer
    mod.dlload 'libkakasi.so'
    DL::CPtr.method_defined?(:[]=) or raise "DL::CPtr#[]= is missing"
  },

  ffi: ->(mod) {
    require 'ffi'
    mod.extend FFI::Library
    mod.ffi_lib 'kakasi'
  },
}.find { |impl, code|
  print "checking #{impl}... "
  begin
    Module.new(&code)
  rescue LoadError, StandardError => e
    puts "no (#{e.message})"
    next false
  end
  puts "yes"
  break impl
} or exit false

puts 'creating kakasi/impl that loads kakasi/%s' % impl
File.open('../../lib/kakasi/impl.rb', 'w') { |f|
  f.print <<-'EOF' % impl
require 'kakasi/%s'
  EOF
}

puts 'creating a dummy Makefile'
File.open('Makefile', 'w') { |f|
  f.print <<-'EOF'
all:
install:
  EOF
}
