require 'ir/command'

module IR
  module Command
    class Base
      attr_reader :data_bits

      def self.inherited(subclass)
        Command.all << subclass
      end

      def self.parse(data)
        if data.custom_code == command_id
          new.tap do |command|
            command.parse(data.data_bits)
          end
        else
          nil
        end
      end

      def self.command_id
        fail NotImplementedError
      end

      def self.pulse_codec
        fail NotImplementedError
      end

      def parse(_data_bits)
        fail NotImplementedError
      end

      def to_data
        fail NotImplementedError
      end

      def pulse_codec
        self.class.pulse_codec
      end
    end
  end
end
