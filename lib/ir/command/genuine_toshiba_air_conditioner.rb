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
        RANGE = AUTO..HIGH
      end

      TEMPERATURE_RANGE = 17..30

      attr_accessor :power, :mode, :temperature, :wind_speed, :air_clean
      alias_method :power?, :power
      alias_method :air_clean?, :air_clean

      def self.command_id
        61_965
      end

      def self.pulse_codec
        PulseCodec::Toshiba
      end

      def parse(data_bits)
        fail "Invalid data bits: #{data_bits}" if Validator.valid?(data_bits)

        self.power = (data_bits[37, 1].to_i == 0)
        self.mode = data_bits[38, 2].to_i
        self.temperature = TEMPERATURE_RANGE.begin + data_bits[24, 4].to_i
        self.wind_speed = data_bits[32, 3].to_i
        self.air_clean = (data_bits[43, 1].to_i == 1)
      end

      def temperature=(integer)
        unless TEMPERATURE_RANGE.include?(integer)
          fail ArgumentError, "Temperature must be within #{TEMPERATURE_RANGE}."
        end
        @temperature = integer
      end

      def wind_speed=(integer)
        unless WindSpeed::RANGE.include?(integer)
          fail ArgumentError, "Wind speed must be within #{WindSpeed::RANGE}."
        end
        @wind_speed = integer
      end

      class Validator
        attr_reader :data_bits

        def valid?(data_bits)
          new(data_bits).valid?
        end

        def initialize(data_bits)
          @data_bits = data_bits
        end

        def valid?
          parity_match? && checksum_match?
        end

        private

        def payload_size
          data_bits[4, 4].to_i
        end

        def header_bits
          data_bits[0, 8]
        end

        def parity_bits
          data_bits[8, 8]
        end

        def parity_match?
          header_bits.to_s == parity_bits.to_s.tr('01', '10')
        end

        def checksum
          checksum_index = (3 + payload_size) * 8
          data_bits[checksum_index, 8].to_i
        end

        def checksum_match?
          target_bytes = (2..(payload_size + 2)).map do |index|
            data_bits[index * 8, 8].to_i
          end

          xor_sum = target_bytes.reduce(0) do |sum, byte|
            sum ^ byte
          end

          xor_sum == checksum
        end
      end
    end
  end
end
