require 'test/unit'
require 'active_support/backtrace_cleaner'
require 'active_support/test_case'

if $stdout.tty?
  require 'redgreen'
end

class BacktraceFilter < ActiveSupport::BacktraceCleaner
  def initialize
    super
    customize
  end

  def customize
    add_filter { |line| line.sub('./', '/') }
    add_filter { |line| line.sub(%r{^.*vendor/gems/ruby/1\.8/gems/(\w+)-([0-9.]+)/}, '\1 (\2) ') }
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
