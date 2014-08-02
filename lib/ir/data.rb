require 'ir/bits'

module IR
  class Data < Bits
    attr_reader :codec

    def initialize(string, codec)
      super(string, codec.endian)
      @codec = codec
    end

    def custom_bits_length
      codec.custom_bits_length
    end

    def custom_code
      custom_bits.to_i
    end

    def custom_bits
      code = string[0, custom_bits_length]
      Bits.new(code, endian)
    end

    def data_bits
      code = string[custom_bits_length..-1]
      Bits.new(code, endian)
    end

    def inspect
      "#<#{self.class.name}:#{object_id} [#{pretty}] codec=#{codec}>"
    end
  end
end
