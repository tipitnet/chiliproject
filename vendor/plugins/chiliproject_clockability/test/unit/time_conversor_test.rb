require File.expand_path('../../test_helper', __FILE__)

  class TimeConversorTest < ActiveSupport::TestCase

    def test_extract_hour_should_return_hour_component_when_no_minutes

      assert_equal(1, Clockability::TimeConversor.extract_hours(1))

    end

    def test_extract_hour_should_return_hour_component_when_minutes_provided

      assert_equal(1, Clockability::TimeConversor.extract_hours(1.5))

    end

    def test_extract_hour_should_return_hour_component_when_hour_is_zero

      assert_equal(0, Clockability::TimeConversor.extract_hours(0.5))

    end

    def test_extract_minutes_should_return_0_when_hour_dot_0

      assert_equal(0, Clockability::TimeConversor.extract_minutes(1))

    end

    def test_extract_minutes_should_return_30_when_hour_dot_5

      assert_equal(30, Clockability::TimeConversor.extract_minutes(1.5))

    end

    def test_extract_minutes_should_return_45_when_hour_dot_7

      assert_equal(45, Clockability::TimeConversor.extract_minutes(1.7))

    end

    def test_extract_minutes_should_return_15_when_hour_dot_3

      assert_equal(15, Clockability::TimeConversor.extract_minutes(1.3))

    end

    def test_extract_minutes_should_return_0_when_hour_dot_1

      assert_equal(0, Clockability::TimeConversor.extract_minutes(1.1))

    end

    def test_extract_minutes_should_return_15_when_hour_is_zero_dot_1

      assert_equal(15, Clockability::TimeConversor.extract_minutes(0.1))

    end
  end