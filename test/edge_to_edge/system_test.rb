require 'test_helper'
require 'open3'

class SystemTest < ActiveSupport::TestCase
  test 'running the application generates an atom feed' do
    system 'feeds'
    assert_feed_valid('public/feeds.atom')
  end

  private

  def assert_feed_valid(path)
    Open3.popen3('xmllint', '--relaxng', ATOM_RELAX_NG_SCHEMA, path) do |_, stdout, stderr|
      errors = stderr.readlines
      assert errors.empty?, errors.join
    end
  end
end
