require 'ir/pulse_codec'
require 'ir/command'

module IR
  class Controller
    attr_reader :io_adapter

    def initialize(io_adapter)
      @io_adapter = io_adapter
    end

    def each_received_pulse(&block)
      return to_enum(__method__) unless block_given?
      io_adapter.each_received_pulse(&block)
    end

    def each_received_data
      return to_enum(__method__) unless block_given?

      io_adapter.each_received_pulse do |pulse|
        PulseCodec.all.each do |codec_class|
          data = codec_class.decode_pulse(pulse)
          yield data if data
        end
      end
    end

    def each_received_command
      return to_enum(__method__) unless block_given?

      each_received_data do |data|
        Command.for_pulse_codec(data.codec).each do |command_class|
          command = command_class.parse(data)
          yield command if command
        end
      end
    end
  end
end
