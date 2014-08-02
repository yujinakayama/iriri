module IR
  module Command
    class GenuineToshibaAirConditioner
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

      COMMAND_ID = 61_965
      TEMPERATURE_BOTTOM = 17

      attr_reader :data_bits

      def self.parse(data)
        if data.custom_code == COMMAND_ID
          new(data.data_bits)
        else
          nil
        end
      end

      def initialize(data_bits)
        @data_bits = data_bits
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

      private

      def inspect
        string = "#<#{self.class.name}:#{object_id}"

        [:data_bits, :mode, :temperature, :wind_speed].each do |attr|
          value = begin
                    send(attr)
                  rescue => error
                    error
                  end
          string << " #{attr}=#{value.inspect}"
        end

        string << '>'
      end
    end
  end
end
