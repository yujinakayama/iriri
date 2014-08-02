module IR
  module Command
    class Base
      attr_reader :data_bits

      def self.parse(data)
        if data.custom_code == command_id
          new(data.data_bits)
        else
          nil
        end
      end

      def self.command_id
        fail NotImplementedError
      end

      def self.register_inspect_attrs(*attrs)
        inspect_attrs.concat(attrs)
      end

      def self.inspect_attrs
        @inspect_attrs ||= [:data_bits]
      end

      def initialize(data_bits)
        @data_bits = data_bits
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