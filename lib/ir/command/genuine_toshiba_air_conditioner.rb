require 'ir/command/base'
require 'ir/pulse_codec/toshiba'

module IR
  module Command
    # 00000011 11111100 00000001 01110100 00000000 00010000 01100101
    #     ^^^^ ^^^^^^^^ ^^^^^^^^ ^^^^     ^^^  ^^^    ^     ^^^^^^^^
    #      |    parity   timer?  temp      |    |     |     checksum
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

      def initialize
        self.power = false
        self.mode = Mode::AUTO
        self.temperature = (TEMPERATURE_RANGE.begin + TEMPERATURE_RANGE.end) / 2
        self.wind_speed = WindSpeed::AUTO
        self.air_clean = true
      end

      def parse(data_bits)
        fail "Invalid data bits: #{data_bits}" unless Validator.valid?(data_bits)

        self.power = (data_bits[37, 1].to_i == 0)
        self.mode = data_bits[38, 2].to_i
        self.temperature = TEMPERATURE_RANGE.begin + data_bits[24, 4].to_i
        self.wind_speed = data_bits[32, 3].to_i
        self.air_clean = (data_bits[43, 1].to_i == 1)
      end

      def to_data
        data = Data.new('', pulse_codec)
        data.append_integer(self.class.command_id, pulse_codec.custom_bits_length)
        data << generate_data_bits
        data
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

      private

      def generate_data_bits # rubocop:disable MethodLength
        bits = Bits.new('', pulse_codec.endian)
        header_bits = Bits.new('00000011', bits.endian)
        bits << (header_bits + header_bits.invert)
        bits << '00000001'
        bits.append_integer(temperature - TEMPERATURE_RANGE.begin, 4)
        bits << '0000'
        bits.append_integer(wind_speed, 3)
        bits << '00'
        bits << (power ? '0' : '1')
        bits.append_integer(mode, 2)
        bits << '000'
        bits << (air_clean ? '1' : '0')
        bits << '0000'
        checksum = Validator.compute_checksum(bits)
        bits.append_integer(checksum, 8)
        bits
      end

      class Validator
        attr_reader :data_bits

        def self.valid?(data_bits)
          new(data_bits).valid?
        end

        def self.compute_checksum(data_bits)
          target_byte_indices = 2..(payload_length(data_bits) + 2)

          target_bytes = target_byte_indices.map do |index|
            data_bits[index * 8, 8].to_i
          end

          target_bytes.reduce(0) do |sum, byte|
            sum ^ byte
          end
        end

        def self.payload_length(data_bits)
          data_bits[4, 4].to_i
        end

        def initialize(data_bits)
          @data_bits = data_bits
        end

        def valid?
          parity_match? && checksum_match?
        end

        private

        def payload_length
          self.class.payload_length(data_bits)
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
          checksum_index = (3 + payload_length) * 8
          data_bits[checksum_index, 8].to_i
        end

        def checksum_match?
          self.class.compute_checksum(data_bits) == checksum
        end
      end
    end
  end
end
