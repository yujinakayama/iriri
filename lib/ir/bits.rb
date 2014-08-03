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

      @string = string.dup.freeze
      @endian = endian
    end

    def each_bit(&block)
      return to_enum(__method__) unless block_given?
      string.each_char(&block)
    end

    def [](*args)
      substring = string[*args]
      Bits.new(substring, endian)
    end

    def <<(other)
      @string = (string + other.to_s).freeze
      self
    end

    def +(other)
      dup << other
    end

    def append_integer(integer, bit_length)
      binary = integer.to_s(2)

      if binary.length > bit_length
        fail ArgumentError, "#{integer} overflows with #{bit_length} bit length."
      end

      if endian == :big
        binary = '0' * (bit_length - binary.length) + binary
      else
        binary = binary.reverse + '0' * (bit_length - binary.length)
      end

      @string = (string + binary).freeze
    end

    def to_s
      string.dup
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
      Bits.new(inverted_string, endian)
    end

    def pretty
      string.scan(/.{1,8}/).join(' ')
    end

    def inspect
      "#<#{self.class.name}:#{object_id} [#{pretty}] endian=#{endian.inspect}>"
    end
  end
end
