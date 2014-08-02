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

      def self.use_codec?(_codec_class)
        false
      end

      def parse(_data_bits)
        fail NotImplementedError
      end
    end
  end
end
