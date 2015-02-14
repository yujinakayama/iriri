require 'ir/signal'
require 'pi_piper'

module IR
  module IOAdapter
    class RaspberryPi
      class Pin < PiPiper::Pin
        def wait_for_change_with_timeout(timeout = nil)
          fd = File.open(value_file, 'r')

          File.open(edge_file, 'w') { |f| f.write('both') }

          loop do
            fd.read
            timed_out = !IO.select(nil, nil, [fd], timeout)
            break false if timed_out
            read
            next unless changed?
            next if @trigger == :rising and value == 0
            next if @trigger == :falling and value == 1
            break true
          end
        end
      end

      PULSE_END_THRESHOLD = 0.1

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

      def initialize(options)
        @input_pin_options = options[:in]
        @output_pin_options = options[:out]
      end

      def each_received_pulse
        return to_enum(__method__) unless block_given?

        pulse = []
        last_change_time = Time.now

        loop do
          changed = input_pin.wait_for_change_with_timeout(PULSE_END_THRESHOLD)

          if changed
            current_time = Time.now

            # Ignore blank time since the last pulse
            if !pulse.empty? || input_pin.on?
              duration_in_micros = (current_time - last_change_time) * 1_000_000
              pulse << Signal.new(input_pin.on?, duration_in_micros.to_i)
            end

            last_change_time = current_time
          elsif pulse.empty?
            next
          else
            yield pulse
            pulse = []
          end
        end
      end

      def send_pulse(pulse)
        fail 'First signal of pulse must be ON state.' unless pulse.first.on?

        # io.write "\r" # Clear buffer
        # io.flush
        #
        # durations = pulse.map { |signal| signal.duration / DURATION_UNIT_MICROS }
        # data = durations.join(',') + "\r"
        # data.each_char do |char|
        #   io.write char
        #   io.flush
        # end
      end

      private

      def input_pin
        @input_pin ||= begin
          at_exit do
            puts 'unexporting pin'
            File.write('/sys/class/gpio/unexport', @input_pin_options[:pin].to_s)
          end

          Pin.new(@input_pin_options.merge(direction: :in))
        end
      end

      def output_pin
        @output_pin ||= Pin.new(@output_pin_options.merge(direction: :out))
      end
    end
  end
end
