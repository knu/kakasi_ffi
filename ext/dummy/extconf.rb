module Kakasi
  begin
    require 'fiddle/import'
    extend Fiddle::Importer
    DLError = Fiddle::DLError
  rescue LoadError
    require 'dl/import'
    extend DL::Importer
    DLError = DL::DLError
  end

  begin
    dlload 'libkakasi.so'
  rescue DLError => e
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
