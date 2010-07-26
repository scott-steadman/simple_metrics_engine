module Sme
  class Config

    # timespan for log rollups
    attr_accessor :granularity

    # event hierarchy separator
    attr_accessor :event_separator

    def initialize
      @granularity = 1.hour
      @event_separator = '|'
    end

  end
end # module Sme
