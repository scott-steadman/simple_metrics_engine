require 'sme/extensions/hash'

class Sme::MetricsController < ApplicationController
  unloadable

  before_filter :set_sme_timezone

  def index
    @metrics = Sme::Rollup.metrics_for(*ranges).to_tree(event_separator)
  end

  def chart
  end

private

  MICRO_SECOND = 0.000001

  helper_method :ranges
  def ranges
    @ranges ||= ranges_from_params || begin
      ranges = []
      current = from.in_time_zone

      interval_count.times do
        case interval
          when 'month', 'months', 28, 28.days, 29, 29.days, 30, 30.days, 31, 31.days
            ranges.push(current.beginning_of_month .. current.end_of_month + MICRO_SECOND)
            current = current.beginning_of_month - 1.day
          when 'week', 'weeks', 7*24, 1.week
            ranges.push((current.beginning_of_week .. current.end_of_week + MICRO_SECOND))
            current -= 1.week
          when 'day', 'days', 24, 1.day
            ranges.push(current.beginning_of_day .. current.end_of_day + MICRO_SECOND)
            current -= 1.day
          else
            ranges.push(current.beginning_of_day .. Sme::Rollup.period_for(current).first)
            current -= 1.day
        end
      end

      ranges
    end
  end

  def ranges_from_params
    return unless params[:ranges]
    params[:ranges].split(',').inject([]) do |ret, range|
      from, to = range.split('..')
      ret << (to.blank? ? to_time(from) : (to_time(from) .. to_time(to)))
    end
  end

  def from
    @from ||= params[:from].blank? ? default_range.first : to_time(params[:from])
  end

  def interval
    @interval ||= params[:interval].blank? ? 'hour' : params[:interval]
  end

  def interval_count
    @interval_count ||= params[:interval_count].blank? ? 4 : params[:interval_count].to_i
  end

  def default_range
    @default_range ||= Sme::Rollup.default_range
  end

  def set_sme_timezone
    Time.zone = sme_timezone || cookies[:sme_timezone] || 'Pacific Time (US & Canada)'
    cookies[:sme_timezone] = Time.zone.name
  end

  def sme_timezone
    params[:sme_timezone] && params[:sme_timezone].to_s
  end

  def to_time(time)
    Sme::Rollup.to_time(time)
  end

  def event_separator
    Sme.configuration.event_separator
  end

end # class Sme::MetricsController
