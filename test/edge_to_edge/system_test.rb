require 'test_helper'

class SystemTest < ActiveSupport::TestCase
  test 'running the application generates an atom feed' do
    system 'feeds'
    assert_feed_valid('public/feeds.atom')
  end

  private

  def assert_feed_valid(path)
    assert_success "xmllint --relaxng #{ATOM_RELAX_NG_SCHEMA} #{path}"
  end

  def assert_success(command)
    output = ''

    IO.popen "#{command} 2>&1" do |io|
      output = io.read
    end

    assert_equal 0, $?.exitstatus, output
  end
end
