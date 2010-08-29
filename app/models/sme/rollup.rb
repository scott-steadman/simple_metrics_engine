# == Schema Information
#
# Table name: sme_rollups
#
#  id         :integer         not null, primary key
#  start_time :datetime        not null
#  end_time   :datetime        not null
#  event      :string(255)     not null
#  value      :float
#  notes      :text
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_sme_rollups_on_start_time_and_end_time_and_event  (start_time,end_time,event) UNIQUE
#

class Sme::Rollup < ActiveRecord::Base
  set_table_name :sme_rollups

  def self.generate_rollups(range=default_range)
    range = range.first.utc .. range.last.utc
    Sme::Log.count(:conditions => {:created_at => range}, :group => :event).each do |event, count|
      conditions = {:start_time => range.first, :end_time => range.last, :event => event}
      if record = first(:conditions => conditions)
        record.update_attributes!(:value => count)
      else
        create!(conditions.merge!(:value => count))
      end
    end
  end

  def self.update_metrics(opts={})
    from = opts[:from] ? opts[:from].to_time : default_range.first
    to   = opts[:to]   ? opts[:to].to_time   : default_range.last

    each_period(from, to) do |period|
      puts "Updating metrics from #{period.first.localtime} to #{period.last.localtime}..." if opts[:verbose]
      generate_rollups(period)
    end
  end

  def self.each_period(from, to, inc=granularity)
    from, to = to, from if to < from

    while from < to do
      yield period_for(from)
      from += inc
    end
  end

  def self.metrics_for(*ranges)
    hash = ranges.last.is_a?(Hash) ? ranges.pop : {}

    if ranges.size > 1
      ranges.flatten.each {|range| metrics_for(range, hash)}
    else
      range = period_for(ranges.first)
      merge_sum(range, hash,
        sum(:value, :conditions => ['start_time >= ? AND end_time <= ?', range.first.utc, range.last.utc], :group => :event)
      )
    end

    hash
  end

  def self.merge_sum(range, to, sum)
    sum.each do |event, value|
      to[event] ||= {}
      to[event].merge!(range => value)
    end
    to
  end

  def self.default_range
    period_for(Time.now.in_time_zone - granularity)
  end

  def self.period_for(time)
    case time
      when Range
        time = time.last .. time.first if time.last < time.first
        (round_down(time.first) .. round_up(time.last))
      else
        time = round_down(time)
        (time .. (time + granularity))
    end
  end

  def self.round_down(time)
    time = time.to_time.to_i # also handily gets rid of usec
    Time.at(on_boundary?(time) ? time : time - (time - granularity) % granularity)
  end

  def self.round_up(time)
    time = time.to_time.to_i # also handily gets rid of usec
    Time.at(on_boundary?(time) ? time : time - time % granularity + granularity)
  end

  def self.on_boundary?(time)
    (0 == (time.to_i % granularity))
  end

  def self.granularity
    Sme.configuration.granularity
  end

end
