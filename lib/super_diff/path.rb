module SuperDiff
  # :stopdoc:
  LIBPATH = File.expand_path("../../", __FILE__) + File::SEPARATOR
  PATH = File.dirname(LIBPATH) + File::SEPARATOR
  # :startdoc:

  # Returns the library path for the module. If any arguments are given, they
  # will be joined to the end of the library path using `File.join`.
  #
  def self.libpath( *args, &block )
    rv =  args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
    if block
      begin
        $LOAD_PATH.unshift LIBPATH
        rv = block.call
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Returns the path for the module. If any arguments are given, they will be
  # joined to the end of the path using `File.join`.
  #
  def self.path( *args, &block )
    rv = args.empty? ? PATH : ::File.join(PATH, args.flatten)
    if block
      begin
        $LOAD_PATH.unshift PATH
        rv = block.call
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end
end