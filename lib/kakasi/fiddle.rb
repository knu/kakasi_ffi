module Kakasi
  module Lib
    require 'fiddle/import' unless defined?(Fiddle::Importer)

    extend Fiddle::Importer
    include Fiddle

    case SIZEOF_VOIDP
    when 4
      PackPointers = 'L*'
    when 8
      PackPointers = 'Q*'
    else
      raise 'Unsupported pointer size: %u' % SIZEOF_VOIDP
    end

    require 'kakasi/platform'

    try_load { |lib|
      dlload lib
    }

    extern 'int kakasi_getopt_argv(int, char **)'
    extern 'char *kakasi_do(char *)'
    extern 'int kakasi_close_kanwadict()'
    extern 'int kakasi_free(char *)'

    INTERNAL_ENCODING = Encoding::CP932

    @mutex = Mutex.new
    @options = nil

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
end
