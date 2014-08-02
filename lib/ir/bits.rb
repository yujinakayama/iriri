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

      @string = string
      @endian = endian
    end

    def [](*args)
      substring = string[*args]
      self.class.new(substring, endian)
    end

    def to_s
      @string
    end

    def to_i
      if endian == :big
        string.to_i(2)
      else
        string.reverse.to_i(2)
      end
    end

    def inspect
      pretty_bits = string.scan(/.{1,8}/).join(' ')
      "#<#{self.class.name}:#{object_id} [#{pretty_bits}] endian=#{endian.inspect}>"
    end
  end
end
