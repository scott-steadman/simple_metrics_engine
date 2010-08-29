module Sme::MetricsHelper

  def range_header(range)
    if monthly_range?(range)
      range.first.to_s(:monthly_header)
    elsif weekly_range?(range)
      "#{range.first.to_s(:weekly_header)} - #{range.last.to_s(:weekly_header)}"
    elsif daily_range?(range)
      range.first.to_s(:daily_header)
    elsif range.is_a?(Range)
      range.last.to_s(:granular_header)
    else
      range.to_s(:granular_header)
    end
  end

  def number_with_delimiter(number, *args)
    return '0' if number.nil?
    number = number.to_i if number.to_i == number
    super(number, *args)
  end

  def leader(parents)
    "\\#{'-' * parents.size}" if parents.size > 0
  end

private

  def monthly_range?(range)
    return false unless range.is_a?(Range)
    range.first == range.first.beginning_of_month and range.last >= range.first.end_of_month
  end

  def weekly_range?(range)
    return false unless range.is_a?(Range)
    range.first == range.first.beginning_of_week and range.last >= range.first.end_of_week
  end

  def daily_range?(range)
    return false unless range.is_a?(Range)
    range.first == range.first.beginning_of_day and range.last >= range.first.end_of_day
  end

end
