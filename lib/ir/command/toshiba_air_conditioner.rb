module IR
  module Command
    class ToshibaAirConditioner
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

      attr_reader :bits

      def initialize(bits)
        @bits = bits
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
        bits[start, length].to_i(2)
      end

      def pretty_bits
        bits.scan(/.{1,8}/).join(' ')
      end

      def inspect
        string = "#<#{self.class.name}:#{object_id}"

        string << " bits=<#{pretty_bits}>"

        [:mode, :temperature, :wind_speed].each do |attr|
          string << " #{attr}=#{send(attr).inspect}"
        end

        string << '>'
      end
    end
  end
end
