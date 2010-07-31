require 'test/test_helper'

module Sme
  class RollupTest < ActiveRecord::TestCase

    test 'period_for with time' do
      expected = '2010-05-21 12:00:00'.to_time .. '2010-05-21 13:00:00'.to_time
      assert_equal expected, Rollup.period_for('2010-05-21 12:59:00'.to_time)
    end

    test 'period_for with string' do
      expected = '2010-05-21 12:00:00'.to_time .. '2010-05-21 13:00:00'.to_time
      assert_equal expected, Rollup.period_for('2010-05-21 12:59:00')
    end

    test 'period_for with range' do
      expected = '2010-05-21 12:00:00'.to_time .. '2010-05-21 15:00:00'.to_time
      assert_equal expected, Rollup.period_for('2010-05-21 12:59:00' .. '2010-05-21 14:59:00')
    end

    test 'generate_rollups creates entries' do
      create_logs(1.hour.ago, 2.hours.ago)
      assert_difference 'Rollup.count', 2 do
        Rollup.generate_rollups
      end
    end

    test 'generate_rollups updates entries' do
      create_logs(1.hour.ago, 2.hours.ago)
      Rollup.generate_rollups
      create_logs(1.hour.ago, 2.hours.ago)
      assert_no_difference 'Rollup.count' do
        Rollup.generate_rollups
      end
    end

    test 'update_metrics default period' do
      create_logs(1.hour.ago, 2.hours.ago, 3.hours.ago, 4.hours.ago)
      assert_difference 'Rollup.count', 2 do
        Rollup.update_metrics
      end
      expected = Rollup.period_for(1.hour.ago)
      Rollup.find_each do |rollup|
        assert_equal expected.first.to_i, rollup.start_time.to_i, 'Incorrect rollup start time'
        assert_equal expected.last.to_i, rollup.end_time.to_i, 'Incorrect rollup end time'
      end
    end

    test 'update_metrics handles multiple periods' do
      create_logs(1.hour.ago, 2.hours.ago, 3.hours.ago, 4.hours.ago)
      assert_difference 'Rollup.count', 8 do
        Rollup.update_metrics(:from => 4.hours.ago, :to => 1.hour.ago)
      end
    end

    test 'period_for' do
      expected = Time.parse('2010-05-21 12:00:00 UTC') .. Time.parse('2010-05-21 13:00:00 UTC')
      assert_equal expected, Rollup.period_for('2010-05-21 12:50:00 UTC'), 'period_for should handle String parameter'
      assert_equal expected, Rollup.period_for(Time.parse('2010-05-21 12:50:00 UTC')), 'period_for should handle Time parameter'
      assert_equal expected, Rollup.period_for('2010-05-21 12:30:00 UTC' .. '2010-05-21 12:50:00 UTC'), 'period_for should handle String Range less than granularity'
      assert_equal expected, Rollup.period_for(Time.parse('2010-05-21 12:30:00 UTC') .. Time.parse('2010-05-21 12:50:00 UTC')), 'period_for should handle Time Range less than granularity'

      expected = Time.parse('2010-05-21 11:00:00 UTC') .. Time.parse('2010-05-21 13:00:00 UTC')
      assert_equal expected, Rollup.period_for('2010-05-21 11:30:00 UTC' .. '2010-05-21 12:50:00 UTC'), 'period_for should handle String Range greater than granularity'
      assert_equal expected, Rollup.period_for(Time.parse('2010-05-21 11:30:00 UTC') .. Time.parse('2010-05-21 12:50:00 UTC')), 'period_for should handle Time Range greater than granularity'
    end

    test 'round_down' do
      assert_equal Time.parse('2010-05-21 12:00:00'), Rollup.round_down(Time.parse('2010-05-21 12:59:00'))
      assert_equal Time.parse('2010-05-21 12:00:00'), Rollup.round_down(Time.parse('2010-05-21 12:00:00')), 'round should be identical if value on boundary'
    end

    test 'round_up' do
      assert_equal Time.parse('2010-05-21 13:00:00'), Rollup.round_up(Time.parse('2010-05-21 12:59:00'))
      assert_equal Time.parse('2010-05-21 13:00:00'), Rollup.round_up(Time.parse('2010-05-21 13:00:00')), 'round should be identical if value on boundary'
    end

    test 'metrics_for' do
      create_logs(1.hour.ago, 2.hours.ago, 3.hours.ago, 4.hours.ago)
      Rollup.update_metrics(:from => 4.hours.ago, :to => 1.hour.ago)
      expected = {
        'user|visit' => {
          round_down(2.hours.ago) .. round_up(1.hours.ago) => 4,
          round_down(3.hours.ago) .. round_up(3.hours.ago) => 2,
        },
        'user|conversion' => {
          round_down(2.hours.ago) .. round_up(1.hours.ago) => 2,
          round_down(3.hours.ago) .. round_up(3.hours.ago) => 1,
        },
      }

      assert_hash expected, Rollup.metrics_for(1.hour.ago .. 2.hours.ago, 3.hours.ago)
    end

  private

    def create_logs(*times)
      times = [Time.now] if times.empty?
      times.each do |time|
        time = time.localtime
        Log.create!(:event => %w[user visit].join(sep), :created_at => time)
        Log.create!(:event => "user|visit", :created_at => time)
        Log.create!(:event => "user#{sep}conversion", :user_id => 1, :created_at => time)
      end
    end

    def sep
      @sep = Sme.configuration.event_separator
    end

    def period_for(range)
      Rollup.period_for(range)
    end

    def round_down(time)
      Rollup.round_down(time)
    end

    def round_up(time)
      Rollup.round_up(time)
    end

  end # class RollupTest
end # module Sme
