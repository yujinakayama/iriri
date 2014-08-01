require 'ir/signal'
require 'serialport'

module IR
  module IOAdapter
    class Arduino
      DURATION_UNIT_MICROS = 10
      BAUD_RATE = 9600
      DATA_BITS = 8
      STOP_BITS = 1
      PARITY = SerialPort::NONE

      def self.find_device
        Dir.glob('/dev/cu.usbmodem*').first
      end

      attr_reader :device, :io

      def initialize(device = nil)
        @device = device || self.class.find_device
        @io = SerialPort.new(@device, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY)
      end

      def each_received_pulse
        io.each_line do |line|
          durations = line.chomp.split(',').map { |string| string.to_i * DURATION_UNIT_MICROS }

          pulse = durations.map.with_index do |duration, index|
            state = index.even?
            Signal.new(state, duration)
          end

          yield pulse
        end
      end

      def send(pulse)
        fail 'First signal of pulse must be ON state.' unless pulse.first.on?
        durations = pulse.map { |signal| signal.duration / DURATION_UNIT_MICROS }
        data = durations.join(',')
        io.puts data
      end
    end
  end
end
