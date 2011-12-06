module Sme

  # Configure the Simple Metrics Engine
  #
  # call-seq:
  #
  #   Sme.configure do |config|
  #
  #     config.rollup_window = 15.minutes
  #
  #   end
  def self.configure
    yield configuration
  end

  # Returns the current configuration
  def self.configuration
    @configuration ||= Sme::Config.new
  end

end # module Sme
