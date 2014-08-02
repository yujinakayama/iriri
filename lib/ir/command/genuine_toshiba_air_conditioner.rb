require 'ir/command/base'
require 'ir/pulse_codec/toshiba'

module IR
  module Command
    # 00000011 11111100 00000001 01110100 00000000 00010000 01100101
    #     ^^^^ ^^^^^^^^ ^^^^^^^^ ^^^^     ^^^  ^^^    ^     ^^^^^^^^
    #      |    parity      ?    temp      |    |     |     checksum
    # payload size                   wind speed |  air clean
    #                                       power/mode
    class GenuineToshibaAirConditioner < Base
      module Mode
        AUTO = 0
        COOL = 1
        DRY  = 2
        HEAT = 3
      end

      module WindSpeed
        AUTO   = 0 # 自動
        SILENT = 1 # しずか
        LOWER  = 2 # 微
        LOW    = 4 # 弱
        HIGH   = 6 # 強
      end

      TEMPERATURE_BOTTOM = 17

      register_inspect_attrs :power?, :mode, :temperature, :wind_speed, :air_clean?, :payload_size,
                             :valid?

      def self.command_id
        61_965
      end

      def self.use_codec?(codec_class)
        codec_class == PulseCodec::Toshiba
      end

      def power?
        data_bits[37, 1].to_i == 0
      end

      def mode
        data_bits[38, 2].to_i
      end

      def temperature
        TEMPERATURE_BOTTOM + data_bits[24, 4].to_i
      end

      def wind_speed
        data_bits[32, 3].to_i
      end

      def air_clean?
        data_bits[43, 1].to_i == 1
      end

      def valid?
        target_bytes = (2..(payload_size + 2)).map do |index|
          data_bits[index * 8, 8].to_i
        end

        xor_sum = target_bytes.reduce(0) do |sum, byte|
          sum ^ byte
        end

        xor_sum == checksum
      end

      private

      def payload_size
        data_bits[4, 4].to_i
      end

      def checksum
        checksum_index = (3 + payload_size) * 8
        data_bits[checksum_index, 8].to_i
      end
    end
  end
end
