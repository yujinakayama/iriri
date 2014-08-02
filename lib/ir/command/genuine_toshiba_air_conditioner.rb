require 'ir/command/base'
require 'ir/pulse_codec/toshiba'

module IR
  module Command
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

      register_inspect_attrs :mode, :temperature, :wind_speed, :air_clean?

      def self.command_id
        61_965
      end

      def self.use_codec?(codec_class)
        codec_class == PulseCodec::Toshiba
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
    end
  end
end
