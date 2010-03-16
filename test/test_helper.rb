require 'test/unit'
require 'active_support'
require 'active_support/test_case'

if $stdout.tty?
  require 'redgreen'
end

# ---------------------------------------------------------------------------
# We'll be needing this
# ---------------------------------------------------------------------------
ATOM_RELAX_NG_SCHEMA = Pathname.new('test/data/atom.rng').expand_path

# ---------------------------------------------------------------------------
# Add our bin to the PATH so tests can run `feeds`
# ---------------------------------------------------------------------------
class Path
  def initialize(string=ENV['PATH'])
    @elements = string.split(File::PATH_SEPARATOR)
  end

  def prepend_relative(path, from=__FILE__)
    @elements.unshift File.expand_path(path, from)
    self
  end

  def clean!
    @elements.map! { |path| File.expand_path(path) }
    @elements.uniq!
    self
  end

  def to_s
    @elements.join(File::PATH_SEPARATOR)
  end
end

path = Path.new(ENV['PATH'])
path.prepend_relative('../../bin')
path.clean!
ENV['PATH'] = path.to_s


# ---------------------------------------------------------------------------
# Run tests in separate temp directories
# ---------------------------------------------------------------------------
require 'tempfile'

module TemporaryTestDirectories
  def self.included(klass)
    klass.send :alias_method, :test_without_temporary_directory, :test
    klass.send :alias_method, :test, :test_with_temporary_directory
  end

  def test_with_temporary_directory(name, &block)
    test_without_temporary_directory(name) do
      Dir.mktmpdir { |tmpdir| Dir.chdir(tmpdir) { send(name) } }
    end

    define_method(name, &block)
  end
end

ActiveSupport::Testing::Declarative.module_eval do
  include TemporaryTestDirectories
end

# ---------------------------------------------------------------------------
# Clean up the backtraces a little bit
# ---------------------------------------------------------------------------
class BacktraceFilter < ActiveSupport::BacktraceCleaner
  def initialize
    super
    customize
  end

  def customize
    add_filter   { |line| line.sub('./test/', '') }
    add_filter   { |line| line.sub(%r{^.*/gems/(\w+)-([0-9.]+)/}, '\1 (\2) ') }
    add_silencer { |line| line =~ /#{Config::CONFIG['rubylibdir']}/ }
    add_silencer { |line| line =~ /active_support/ }
    add_silencer { |line| line =~ /test_helper/ }
  end

  module TestUnitEnhancements
    def self.included(klass)
      klass.send :alias_method, :filter_backtrace_without_enhancements, :filter_backtrace
      klass.send :alias_method, :filter_backtrace, :filter_backtrace_with_enhancements
    end

    def filter_backtrace_with_enhancements(backtrace, prefix=nil)
      backtrace = filter_backtrace_without_enhancements(backtrace, prefix)
      backtrace = backtrace.first.split("\n") if backtrace.size == 1
      BacktraceFilter.new.clean(backtrace)
    end
  end
end

Test::Unit::Util::BacktraceFilter.module_eval do
  include BacktraceFilter::TestUnitEnhancements
end
