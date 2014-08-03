require 'ir/pulse_codec'

module IR
  module PulseCodec
    class Base
      def self.inherited(subclass)
        PulseCodec.all << subclass
      end

      def self.decode_pulse(_pulse)
        fail NotImplementedError
      end

      def self.encode_data(_bits)
        fail NotImplementedError
      end

      def self.endian
        fail NotImplementedError
      end

      def self.custom_bits_length
        fail NotImplementedError
      end
    end
  end
end
