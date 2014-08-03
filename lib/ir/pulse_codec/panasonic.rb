require 'ir/pulse_codec/base'
require 'ir/signal'
require 'ir/data'

module IR
  module PulseCodec
    class Panasonic < Base
      LEADER_CODE = [Signal.new(true, 3600), Signal.new(false, 1620)]
      BIT_0_CODE = [Signal.new(true,  540), Signal.new(false, 320)]
      BIT_1_CODE = [Signal.new(true,  540), Signal.new(false, 1190)]
      PARITY_CODE = [Signal.new(true, 540), Signal.new(false, 9860)]
      END_CODE = [Signal.new(true, 540)]

      def self.decode_pulse(pulse)
        decoder = Decoder.new(pulse)
        decoder.decode
      end

      def self.endian
        :little
      end

      def self.custom_bits_length
        64
      end

      class Decoder
        attr_reader :pulse

        def initialize(pulse)
          @pulse = pulse
        end

        def decode
          return nil unless read_and_match?(LEADER_CODE)
          bits = read_bits
          return nil unless read_and_match?(PARITY_CODE)
          return nil unless read_and_match?(LEADER_CODE)
          bits << read_bits
          return nil unless read_and_match?(END_CODE)
          return nil unless pulse.empty?
          Data.new(bits, Panasonic)
        end

        def read_and_match?(signals)
          pulse.shift(signals.size) == signals
        end

        def read_bits
          bits = ''

          read_size = 2

          loop do
            signal_pair = pulse[0, read_size]

            case signal_pair
            when BIT_1_CODE
              bits << '1'
            when BIT_0_CODE
              bits << '0'
            else
              break
            end

            pulse.shift(read_size)
          end

          bits
        end
      end
    end
  end
end
