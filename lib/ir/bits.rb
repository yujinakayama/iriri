module IR
  class Bits
    ENDIANS = [:big, :little]

    attr_reader :string, :endian

    def initialize(string, endian)
      if string.match(/[^10]/)
        fail ArgumentError, 'Bit string must not include character other than "1" and "0".'
      end

      unless ENDIANS.include?(endian)
        fail ArgumentError, "Bit endian must be either #{ENDIANS.join(' or ')}."
      end

      @string = string.freeze
      @endian = endian
    end

    def [](*args)
      substring = string[*args]
      self.class.new(substring, endian)
    end

    def <<(other)
      @string = (string + other.to_s).freeze
    end

    def to_s
      @string.dup
    end

    def to_i
      if endian == :big
        string.to_i(2)
      else
        string.reverse.to_i(2)
      end
    end

    def invert
      inverted_string = string.tr('01', '10')
      self.class.new(inverted_string, endian)
    end

    def pretty
      string.scan(/.{1,8}/).join(' ')
    end

    def inspect
      "#<#{self.class.name}:#{object_id} [#{pretty}] endian=#{endian.inspect}>"
    end
  end
end
