require 'ir/command/base'
require 'ir/pulse_codec/toshiba'

module IR
  module Command
    class CompatibleToshibaAirConditioner < Base
      attr_accessor :temperature
      register_inspect_attrs :temperature

      def self.command_id
        45_645
      end

      def self.use_codec?(codec_class)
        codec_class == PulseCodec::Toshiba
      end

      def parse(data_bits)
        # TODO: Odd rule...
        # 10011111 01100000 00000000 11111111 16,17
        # 10011111 01100000 00010000 11101111 18
        # 10011111 01100000 00110000 11001111 19
        # 10011111 01100000 00100000 11011111 20
        # 10011111 01100000 01100000 10011111 21
        # 10011111 01100000 01110000 10001111 22
        # 10011111 01100000 01010000 10101111 23
        # 10011111 01100000 01000000 10111111 24
        # 10011111 01100000 11000000 00111111 25
        # 10011111 01100000 11010000 00101111 26
        # 10011111 01100000 10010000 01101111 27
        # 10011111 01100000 10000000 01111111 28
        # 10011111 01100000 10100000 01011111 29
        # 10011111 01100000 10110000 01001111 30
        self.temperature = data_bits[16, 4].to_i
      end
    end
  end
end
