# -*- coding: utf-8 -*-
require 'kakasi/version'
require 'ffi'

module Kakasi
  INTERNAL_ENCODING = Encoding::CP932

  module Lib
    @mutex = Mutex.new
    @options = nil

    extend FFI::Library
    ffi_lib 'kakasi'

    attach_function 'kakasi_getopt_argv', [:int, :pointer], :int
    attach_function 'kakasi_do', [:string], :pointer
    attach_function 'kakasi_close_kanwadict', [], :int
    attach_function 'kakasi_free', [:pointer], :int

    def kakasi(options, string)
      @mutex.synchronize {
        if options != @options
          kakasi_close_kanwadict() if @options

          args = ['kakasi', *options.split]

          argc = args.size
          argv = FFI::MemoryPointer.new(:pointer, argc).
            write_array_of_pointer(args.map { |arg|
              FFI::MemoryPointer.from_string(arg)
            })

          kakasi_getopt_argv(argc, argv).zero? or
            raise "failed to initialize kakasi"

          @options = options.dup
        end

        encoding = string.encoding
        result = ''.force_encoding(INTERNAL_ENCODING)
        string.encode(INTERNAL_ENCODING).split(/(\0+)/).each { |str, nul|
          buf = kakasi_do(str)
          result << buf.get_string(0).force_encoding(INTERNAL_ENCODING)
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
