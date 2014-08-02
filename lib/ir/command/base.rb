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

      def self.register_inspect_attrs(*attrs)
        inspect_attrs.concat(attrs)
      end

      def self.inspect_attrs
        @inspect_attrs ||= [:data_bits]
      end

      def parse(_data_bits)
        fail NotImplementedError
      end

      def inspect
        string = "#<#{self.class.name}:#{object_id}"

        self.class.inspect_attrs.each do |attr|
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
