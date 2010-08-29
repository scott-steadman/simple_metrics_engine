module Sme
  class Config

    attr_accessor :event_separator, :granularity, :report_intervals

    def initialize
      @event_separator = '|'
      @granularity = 1.hour
      @report_intervals = [
        {'1 hour'   =>  1.hour},
        {'1 day'    =>  1.days},
        {'1 week'   =>  1.week},
        {'28 days'  => 28.days},
      ]
    end

    def permission_check(*args, &blk)
      if block_given?
        Sme::MetricsController.prepend_before_filter(:permission_check)
        Sme::MetricsController.send(:define_method, :permission_check, &blk)
      else
        Sme::MetricsController.filter_chain.delete_if { |ii| :permission_check == ii.method }
      end
    end

  end
end # module Sme
