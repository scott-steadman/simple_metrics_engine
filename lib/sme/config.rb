module Sme
  class Config

    attr_accessor :granularity

    attr_accessor :event_separator

    attr_accessor :report_intervals

    def initialize
      @granularity = 1.hour
      @event_separator = '|'
      @report_intervals = [
        {'1 hour'   =>  1.hour},
        {'1 day'    =>  1.days},
        {'1 week'   =>  1.week},
        {'28 days'  => 28.days},
      ]
    end

  end
end # module Sme
