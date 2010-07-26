module Sme

  # Configure the Simple Metrics Engine
  #
  # call-seq:
  #
  #   Sme.configure do |config|
  #
  #     config.granularity = 15.minutes
  #
  #   end
  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Sme::Config.new
  end

end # module Sme
