require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__)), 'amion_schedule')

class TestAmionSchedule < Test::Unit::TestCase
  # def test_bad_password_returns_error
  #   exception = assert_raise(RuntimeError) {
  #     get_one_file("badpwd")
  #   }
  #   assert_equal "Invalid AMION password.", exception.message
  # end

  # def test_good_password_does_not_return_error
  #   as = get_one_file("DRH Hospitalist")
  #   assert_not_equal "Invalid password.", as
  # end

  def setup
    @kurup = ["Kurup", "248", "13", "Hospitalist 2       (5-1)   7a-7p", "278", "35", "10-31-11", "0700", "1900"]
    @flex = ["Wozniak", "433", "325", "Hospitalist 7          7a-7p", "283", "40", "10-31-11", "0700", "1900"]
    @day_admit = ["Johnson", "236", "1", "9050 Day Admit Shift 12p-9p", "289", "45", "10-31-11", "1200", "2100"]
  end

  def test_date_parse_is_correct
    assert_equal Date.parse('2011-10-31'), parse_date(@kurup)
  end

  def test_name_parse_is_correct
    assert_equal "Kurup", parse_name(@kurup)
  end

  def test_shift_parse_is_correct
    assert_equal "Day Shift", parse_shift(@kurup)
    assert_equal "Flex", parse_shift(@flex)
    assert_equal "12-9", parse_shift(@day_admit)
  end

  def test_service_parse_is_correct
    assert_equal "5-1", parse_service(@kurup)
    assert_equal nil, parse_service(@flex)
  end

  def test_one_day_schedule_is_correct
    s = make_schedule(CSV.read("test.csv").slice(6..-1))
    date = Date.parse("2011/10/14")
    ds = one_day_schedule(s, date)
    kurup = ds.index{ |h| h[:name] == "Kurup"}

    assert_equal 1, ds[kurup][:day], "Day is correct"
    assert_equal 5, ds[kurup][:stretch], "Stretch is correct"
    assert_equal "Day Shift", ds[kurup][:shift], "Shift is correct"
    assert_equal "5-2", ds[kurup][:service], "service is correct"
  end
end
