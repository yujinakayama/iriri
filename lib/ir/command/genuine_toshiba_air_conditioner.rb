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

      def self.parse(bits)
        custom_bits = bits[0, 16]
        return nil unless custom_bits.to_i(2) == COMMAND_ID
        data_bits = bits[16..-1]
        new(data_bits)
      end

      def initialize(data_bits)
        @data_bits = data_bits
      end

      def mode
        read_integer(54, 2)
      end

      def temperature
        TEMPERATURE_BOTTOM + read_integer(40, 4)
      end

      def wind_speed
        read_integer(48, 3)
      end

      private

      def read_integer(start, length)
        data_bits[start, length].to_i(2)
      end

      def pretty_data_bits
        data_bits.scan(/.{1,8}/).join(' ')
      end

      def inspect
        string = "#<#{self.class.name}:#{object_id}"
        string << " data_bits=<#{pretty_data_bits}>"

        [:mode, :temperature, :wind_speed].each do |attr|
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
