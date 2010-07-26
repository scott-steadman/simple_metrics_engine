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

    from, to = to, from if to < from

    while from < to do
      period = period_for(from)
      puts "Updating metrics from #{period.first} to #{period.last}..." if opts[:verbose]
      generate_rollups(period)
      from += granularity
    end

  end

private

  def self.default_range
    period_for(Time.now - granularity)
  end

  def self.period_for(time)
    from = time - (time.to_i - granularity) % granularity
    (from.utc .. (from + granularity).utc)
  end

  def self.granularity
    Sme.configuration.granularity
  end

end
