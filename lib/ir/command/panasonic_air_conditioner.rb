require 'ir/command/base'
require 'ir/pulse_codec/panasonic'

module IR
  module Command
    class PanasonicAirConditioner < Base
      attr_accessor :power, :mode, :temperature, :wind_speed, :wind_direction, :powerful,
                    :off_timer, :off_timer_count
      alias_method :power?, :power
      alias_method :powerful?, :powerful
      alias_method :off_timer?, :off_timer
      # alias_method :air_clean?, :air_clean

      module Mode
        COOL = 3
        DRY  = 2
        HEAT = 4
      end

      TEMPERATURE_RANGE = 16..30

      def self.parse(data)
        new.tap do |command|
          command.parse(data.data_bits)
        end
      end

      def self.command_id
        fail
      end

      def self.pulse_codec
        PulseCodec::Panasonic
      end

      def parse(data_bits)
        self.power = data_bits[40, 1].to_i == 1
        self.mode = data_bits[44, 3].to_i
        self.temperature = TEMPERATURE_RANGE.begin + data_bits[49, 4].to_i
        self.wind_speed = data_bits[68, 4].to_i
        self.wind_direction = data_bits[64, 4].to_i
        self.powerful = data_bits[104, 1].to_i == 1
        self.off_timer = data_bits[42, 1].to_i == 1
        self.off_timer_count = data_bits[94, 8].to_i
      end

      def temperature=(integer)
        unless TEMPERATURE_RANGE.include?(integer)
          fail ArgumentError, "Temperature must be within #{TEMPERATURE_RANGE}."
        end
        @temperature = integer
      end

      # def wind_speed=(integer)
      #   unless WindSpeed::RANGE.include?(integer)
      #     fail ArgumentError, "Wind speed must be within #{WindSpeed::RANGE}."
      #   end
      #   @wind_speed = integer
      # end
    end
  end
end
