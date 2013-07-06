# -*- coding: utf-8 -*-
require 'kakasi/version'

module Kakasi
  INTERNAL_ENCODING = Encoding::CP932

  module Lib
    @mutex = Mutex.new
    @options = nil

    begin
      require 'fiddle/import'
      extend Fiddle::Importer
      include Fiddle
      Pointer = Fiddle::Pointer
      SIZEOF_VOIDP = Fiddle::SIZEOF_VOIDP
    rescue LoadError
      require 'dl/import'
      extend DL::Importer
      Pointer = DL::CPtr
      SIZEOF_VOIDP = DL::SIZEOF_VOIDP
    end

    case SIZEOF_VOIDP
    when 4
      PackPointers = 'L*'
    when 8
      PackPointers = 'Q*'
    else
      raise 'Unsupported pointer size: %u' % SIZEOF_VOIDP
    end

    dlload 'libkakasi.so'

    extern 'int kakasi_getopt_argv(int, char **)'
    extern 'char *kakasi_do(char *)'
    extern 'int kakasi_close_kanwadict()'
    extern 'int kakasi_free(char *)'

    def kakasi(options, string)
      @mutex.synchronize {
        if options != @options
          kakasi_close_kanwadict() if @options

          args = ['kakasi', *options.split]

          argc = args.size
          argv = Pointer.malloc(argc * SIZEOF_VOIDP)
          argv[0, argv.size] = args.map { |x|
            Pointer[x].to_i
          }.pack(PackPointers)

          kakasi_getopt_argv(argc, argv).zero? or
            raise "failed to initialize kakasi"

          @options = options.dup
        end

        encoding = string.encoding
        result = ''.force_encoding(INTERNAL_ENCODING)
        string.encode(INTERNAL_ENCODING).split(/(\0+)/).each { |str, nul|
          buf = kakasi_do(str)
          result << buf.to_s.force_encoding(INTERNAL_ENCODING)
          kakasi_free(buf)
          result << nul if nul
        }
        result.encode(encoding)
      }
    end
    module_function :kakasi
  end

  def kakasi(options, string)
    Lib::kakasi(options, string)
  end
  module_function :kakasi
end
