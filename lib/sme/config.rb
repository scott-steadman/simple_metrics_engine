module Sme
  class Config

    # The seperator used to delimit parts of an event (default = '|').
    #
    # call-seq:
    #   config.event_separator = '/'
    #
    attr_accessor :event_separator

    # Rollup window (default = 1.hour).
    #
    # call-seq:
    #   config.rollup_window = 15.minutes
    #
    attr_accessor :rollup_window

    def initialize
      @event_separator  = '|'
      @rollup_window    = 1.hour
    end

    # Specify the permission check block.
    #
    # call-seq:
    #  config.permission_check { redirect_to login_path and return false unless current_user.admin? }
    #
    def permission_check(&blk)
      if block_given?
        Sme::MetricsController.prepend_before_filter(:permission_check)
        Sme::MetricsController.send(:define_method, :permission_check, &blk)
      else
        Sme::MetricsController.filter_chain.delete_if { |ii| :permission_check == ii.method }
      end
    end

  end
end # module Sme
