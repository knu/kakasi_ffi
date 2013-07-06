require 'ffi'

module Kakasi
  extend FFI::Library

  begin
    ffi_lib 'kakasi'
  rescue LoadError => e
    STDERR.puts e.message
    exit 1
  end

  puts 'found libkakasi'
end

puts 'creating a dummy Makefile'

File.open('Makefile', 'w') { |f|
  f.puts 'all:'
  f.puts 'install:'
}
