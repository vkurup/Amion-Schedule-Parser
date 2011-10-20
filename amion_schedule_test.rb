require 'test/unit'
require 'pathname'
require File.expand_path(File.join(File.dirname(__FILE__)), 'amion_schedule')

class TestAmionSchedule < Test::Unit::TestCase
  def test_initialize
    as = AmionSchedule.new
    assert_not_nil(as)
  end
end
