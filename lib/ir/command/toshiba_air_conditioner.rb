module IR
  module Command
    class ToshibaAirConditioner
      TEMPERATURE_BOTTOM = 17

      attr_reader :bits

      def initialize(bits)
        @bits = bits
      end

      def temperature
        TEMPERATURE_BOTTOM + read_integer(40, 4)
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

        [:temperature].each do |attr|
          string << " #{attr}=#{send(attr).inspect}"
        end

        string << '>'
      end
    end
  end
end
