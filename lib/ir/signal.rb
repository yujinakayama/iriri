module IR
  class Signal
    DURATION_MARGIN_OF_ERROR = 0.2

    attr_reader :on, :duration
    alias_method :on?, :on

    def initialize(on, duration)
      @on, @duration = on, duration
    end

    def ==(other)
      return false unless on? == other.on?
      lower_margin = other.duration * (1 - DURATION_MARGIN_OF_ERROR)
      higher_margin = other.duration * (1 + DURATION_MARGIN_OF_ERROR)
      duration.between?(lower_margin, higher_margin)
    end

    alias_method :eql?, :==
  end
end
