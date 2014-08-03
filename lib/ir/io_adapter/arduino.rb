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

      def self.from_found_device
        device = find_device
        fail 'No Arduino device file is found.' unless device
        from_device(device)
      end

      def self.from_device(device)
        io = SerialPort.new(device, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY)
        new(io)
      end

      def self.find_device
        Dir.glob('/dev/cu.usbmodem*').first
      end

      attr_reader :io

      def initialize(io)
        @io = io
      end

      def each_received_pulse
        return to_enum(__method__) unless block_given?

        io.each_line do |line|
          durations = line.chomp.split(',').map { |string| string.to_i * DURATION_UNIT_MICROS }

          pulse = durations.map.with_index do |duration, index|
            state = index.even?
            Signal.new(state, duration)
          end

          yield pulse
        end
      end

      def send_pulse(pulse)
        fail 'First signal of pulse must be ON state.' unless pulse.first.on?
        io.write "\r" # Clear buffer
        durations = pulse.map { |signal| signal.duration / DURATION_UNIT_MICROS }
        data = durations.join(',') + "\r"
        io.write data
      end
    end
  end
end
