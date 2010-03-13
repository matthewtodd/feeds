require 'test_helper'

class SystemTest < ActiveSupport::TestCase
  test 'running the application generates an atom feed' do
    system 'feeds'
    assert_feed_valid('public/feeds.atom')
  end

  private

  def assert_feed_valid(path)
    assert_file_exists(path)
  end

  def assert_file_exists(path)
    assert File.exist?(path), "A file named #{path} should exist"
  end
end
