require 'colored'

MiniTest::Unit.class_eval do
  def status(io=@@out)
    format = "%d tests, %d assertions, %s, %s, %s"
    io.puts format % [test_count, assertion_count, "#{failures} failures".red, "#{errors} errors".red, "#{skips} skips".yellow]
  end
  
  def puke(klass, meth, e)
    case e
    when MiniTest::Skip then
      @skips += 1
      report = "Skipped:\n#{meth}(#{klass}) [#{location e}]:\n#{e.message}\n".yellow
      msg = "S".red
    when MiniTest::Assertion then
      @failures += 1
      report = "Failure:\n#{meth}(#{klass}) [#{location e}]:\n#{e.message}\n".red
      msg = "F".red
    else
      @errors += 1
      bt = MiniTest::filter_backtrace(e.backtrace).join("\n    ")
      report = "Error:\n#{meth}(#{klass}):\n#{e.class}: #{e.message}\n    #{bt}\n".red
      msg = "E".red
    end
    @report << report
    msg
  end
  
  def run args = []
    options = process_args args

    @verbose = options[:verbose]

    filter = options[:filter] || '/./'
    filter = Regexp.new $1 if filter and filter =~ /\/(.*)\//

    seed = options[:seed]
    unless seed then
      srand
      seed = srand % 0xFFFF
    end

    srand seed

    #@@out.puts "Loaded suite #{$0.sub(/\.rb$/, '')}\nStarted".bold.black
    #@@out.puts

    start = Time.now
    run_test_suites filter

    #@@out.puts "\n\n"
    #@@out.puts "Finished in #{'%.6f' % (Time.now - start)} seconds.".bold.black

    @report.each_with_index do |msg, i|
      @@out.puts "\n%3d) %s" % [i + 1, msg]
    end

    @@out.puts

    status

    @@out.puts

    help = ["--seed", seed]
    help.push "--verbose" if @verbose
    help.push("--name", options[:filter].inspect) if options[:filter]

    #@@out.puts "Test run options: #{help.join(" ")}"

    return failures + errors if @test_count > 0 # or return nil...
  rescue Interrupt
    abort 'Interrupted'
  end
  
  # Have to supply this for some reason...
  def run_test_suites filter = /./
    @test_count, @assertion_count = 0, 0
    old_sync, @@out.sync = @@out.sync, true if @@out.respond_to? :sync=
    TestCase.test_suites.each do |suite|
      suite.test_methods.grep(filter).each do |test|
        inst = suite.new test
        inst._assertions = 0
        @@out.print "#{suite}##{test}: " if @verbose

        @start_time = Time.now
        result = inst.run(self)

        @@out.print "%.2f s: " % (Time.now - @start_time) if @verbose
        @@out.print result
        @@out.puts if @verbose
        @test_count += 1
        @assertion_count += inst._assertions
      end
    end
    @@out.sync = old_sync if @@out.respond_to? :sync=
    [@test_count, @assertion_count]
  end
end

MiniTest::Unit::TestCase.class_eval do
  def run(runner)
    trap 'INFO' do
      warn '%s#%s %.2fs' % [self.class, self.__name__,
        (Time.now - runner.start_time)]
      runner.status $stderr
    end if SUPPORTS_INFO_SIGNAL

    result = '.'.green
    begin
      @passed = nil
      self.setup
      self.__send__ self.__name__
      @passed = true
    rescue *PASSTHROUGH_EXCEPTIONS
      raise
    rescue Exception => e
      @passed = false
      result = runner.puke(self.class, self.__name__, e)
    ensure
      begin
        self.teardown
      rescue *PASSTHROUGH_EXCEPTIONS
        raise
      rescue Exception => e
        result = runner.puke(self.class, self.__name__, e)
      end
      trap 'INFO', 'DEFAULT' if SUPPORTS_INFO_SIGNAL
    end
    result
  end
end