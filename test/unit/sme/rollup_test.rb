require 'test/test_helper'

module Sme
  class RollupTest < ActiveRecord::TestCase

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
        assert_equal expected.first.to_i, rollup.from.to_i, 'Incorrect rollup start time'
        assert_equal expected.last.to_i, rollup.to.to_i, 'Incorrect rollup end time'
      end
    end

    test 'update_metrics handles multiple periods' do
      create_logs(1.hour.ago, 2.hours.ago, 3.hours.ago, 4.hours.ago)
      assert_difference 'Rollup.count', 8 do
        Rollup.update_metrics(:from => 4.hours.ago, :to => 1.hour.ago)
      end
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

  end # class RollupTest
end # module Sme
