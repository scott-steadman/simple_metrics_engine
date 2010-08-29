require 'test/test_helper'


class Sme::MetricsControllerTest < ActionController::TestCase

  USEC = Sme::MetricsController::MICRO_SECOND

  setup do
    Time.zone = 'Eastern Time (US & Canada)'
  end

  test 'index with no parameters' do
    from = Time.zone.parse('2010-05-20 12:59:00')
    create_rollups(from .. from + 1.day)
    ranges = [
      '2010-05-21 12:59:00',                        # hourly
      '2010-05-21 12:00:00 .. 2010-05-21 13:00:00', # hourly
      '2010-05-21 00:00:00 .. 2010-05-22 00:00:00', # daily
      '2010-05-17 00:00:00 .. 2010-05-24 00:00:00', # weekly
      '2010-05-01 00:00:00 .. 2010-06-01 00:00:00', # monthly
    ]

    get :index, :sme_timezone => Time.zone.name, :ranges => ranges.join(',')

    assert_select 'select[id=interval]' do
      assert_select 'option[value=day]'
      assert_select 'option[value=week]'
      assert_select 'option[value=month]'
    end

    assert_select 'select[id=interval_count]' do
      assert_select 'option[value=4]'
      assert_select 'option[value=20]'
    end

    assert_select 'table>tr' do
      assert_select 'th', 'May 21 12:59',     'time header missing'
      assert_select 'th', 'May 21 13:00',     'time header missing'
      assert_select 'th', 'May 21',           'day header missing'
      assert_select 'th', 'May 17 - May 24',  'week header missing'
      assert_select 'th', 'May',              'month header missing'
    end

    assert_select 'table>tr>td[colspan=6]>b', 'one', 'headers should have colspan'
    assert_select 'table>tr>td[align=right]', '12', 'missing data'
  end

  test 'interval' do
    assert_equal 'hour', @controller.send(:interval), 'interval should default to "hour"'
    reset_controller
    @controller.params[:interval] = 'day'
    assert_equal 'day', @controller.send(:interval)
  end

  test 'ranges' do
    from = '2010-05-21 12:59:00 -04:00'
    {
      nil      => [to_time('2010-05-21 00:00:00') .. to_time('2010-05-21 12:00:00')],
      'hour'   => [to_time('2010-05-21 00:00:00') .. to_time('2010-05-21 12:00:00')],
      'day'    => [to_time('2010-05-21 00:00:00') .. to_time('2010-05-22 00:00:00')],
      'week'   => [to_time('2010-05-17 00:00:00') .. to_time('2010-05-24 00:00:00')],
      'month'  => [to_time('2010-05-01 00:00:00') .. to_time('2010-06-01 00:00:00')],
    }.each do |interval, expected|
      reset_controller
      @controller.params[:sme_timezone] = Time.zone.name
      @controller.params[:from] = from
      @controller.params[:interval] = interval
      @controller.params[:interval_count] = 1
      assert_equal expected, @controller.send(:ranges), "Invalid result for #{interval}"
    end
  end

  test 'ranges_from_params' do
    now = Time.zone.now
    {
      nil                                       => nil,
      now.to_s                                  => [now],
      "#{Date.yesterday} .. #{Date.today}"      => [to_time(Date.yesterday.to_s) .. to_time(Date.today.to_s)],
      "#{now},#{Date.yesterday}..#{Date.today}" => [now.to_s, to_time(Date.yesterday.to_s) .. to_time(Date.today.to_s)],
    }.each do |param, expected|
      @controller.params[:sme_timezone] = Time.zone.name
      @controller.params[:ranges] = param
      assert_equal expected.to_s, @controller.send(:ranges_from_params).to_s, "Incorrect parsing of: #{param}"
    end
  end

  test 'from' do
    assert_equal Sme::Rollup.default_range.first, @controller.send(:from)
    reset_controller
    time_str = '2010-05-21 12:59:00'
    @controller.params[:from] = time_str
    assert_equal to_time(time_str), @controller.send(:from)
  end

  test 'configured before_filter' do
    Sme.configure do |config|
      config.permission_check {redirect_to '/foo' and return false }
    end

    get :index

    assert_redirected_to '/foo'

    Sme.configure do |config|
      config.permission_check
    end

    get :index
    assert_response :success
  end

private

  def create_rollups(*times)
    return times.flatten.each {|time| create_rollups(time)} if times.size > 1

    time = times.first
    if time.is_a?(Range)
      Sme::Rollup.each_period(time.first, time.last) do |period|
        create_rollups(midpoint(period))
      end
    else
      ['one|one|one', 'one|one|two', 'one|two|one', 'one|two|two', 'two|one', 'two|two'].each do |event|
        Sme::Rollup.create!(:start_time => round_down(time).utc, :end_time => round_up(time).utc, :event => event, :value => 1)
      end
    end
  end

  def round_down(time)
    Sme::Rollup.round_down(time)
  end

  def round_up(time)
    Sme::Rollup.round_up(time)
  end

  def to_time(time)
    Sme::Rollup.to_time(time)
  end

  def midpoint(period)
    Time.at((period.first.to_i + period.last.to_i)/2)
  end

  def reset_controller
    @controller = nil
    setup_controller_request_and_response
  end

end # class Sme::MetricsControllerTest
