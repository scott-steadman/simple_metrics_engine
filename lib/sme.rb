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

  # Log an event.
  #
  # call-seq:
  #   Sme.log(:foo)
  #   Sme.log(:foo, :key => val)
  #   Sme.log(:event => 'foo', :key => val)
  def self.log(*args)
    Sme::Log.create(wrapper_chain.call(args_to_hash(*args)))
  end

  # Log an event just like Sme.log but raises an exception on failure.
  def self.log!(*args)
    Sme::Log.create!(wrapper_chain.call(args_to_hash(*args)))
  end

  # Wrap log calls with handlers.
  #
  # == Example:
  #
  #   # Wrappers can be a class (similar to Rack)
  #   class ControllerWrapper
  #     def initialize(logger)
  #       @logger = logger
  #     end
  #
  #     def call(event_hash)
  #       event_hash[:controller_name] ||= controller_name
  #       @logger.call(event_hash)
  #     end
  #   end
  #
  #   # Wrappers can be methods that take and return a hash.
  #   def user_wrapper(event_hash)
  #     event_hash.merge(:user_id => current_user.id)
  #   end
  #
  #   Sme.wrap!(ControllerWrapper, method(:user_wrapper))
  def self.wrap!(*wrappers)
    wrappers.reverse.each {|wrapper| add_wrapper(wrapper)}
  end

private

  def self.args_to_hash(*args)
    event          = args.shift unless args.first.is_a?(Hash)
    hash           = args.first || {}
    hash[:event] ||= event
    hash
  end

  def self.wrapper_chain
    @wrapper_chain ||= lambda {|event_hash| event_hash}
  end

  def self.add_wrapper(wrapper)
    case wrapper
      when Method
        @wrapper_chain = MethodWrapper.new(wrapper_chain, wrapper)
      when Class
        @wrapper_chain = wrapper.new(wrapper_chain)
      else
        raise ArgumentError, 'Wrapper must be Method or Class'
    end
  end

  class MethodWrapper
    def initialize(wrapper, method)
      @wrapper = wrapper
      @method  = method
    end

    def call(event_hash)
      @wrapper.call(@method.call(event_hash))
    end
  end

end # module Sme
