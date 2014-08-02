require 'ir/bits'

module IR
  class Data < Bits
    attr_reader :custom_bits_length

    def initialize(string, endian, custom_bits_length)
      super(string, endian)
      @custom_bits_length = custom_bits_length
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
  end
end
