require 'ir/io_adapter/arduino'
require 'stringio'

module IR
  module IOAdapter
    describe Arduino do
      let(:serial_data) do
        '452,427,64,150,65,149,65,150,65,149,65,42,64,42,64,150,64,42,65,43,64,43,64,43,65,42,64,' \
        '150,65,150,64,42,64,150,64,40,67,42,65,41,66,41,65,42,65,42,64,150,64,150,64,150,64,150,' \
        '65,150,64,150,64,150,65,149,65,42,64,42,64,43,64,42,64,42,65,42,65,42,65,42,65,42,64,'    \
        '150,64,42,65,149,65,149,65,150,64,42,64,42,64,42,64,42,65,42,65,150,64,42,64,42,64,42,'   \
        '65,42,65,42,65,150,64,41,67,42,65,42,65,42,65,41,65,43,64,42,64,42,64,42,64,42,64,150,64' \
        ',150,64,43,64,43,64,43,64,42,65,490,451,428,64,150,64,150,65,149,65,149,65,42,64,42,64,'  \
        '150,64,42,64,42,65,42,64,43,64,43,64,150,66,150,65,42,64,150,64,43,64,43,64,42,64,42,64,' \
        '42,64,42,65,149,65,150,64,150,64,150,65,149,65,150,64,150,64,150,65,42,64,42,65,42,64,'   \
        '42,64,42,64,42,64,42,64,42,64,42,65,150,64,42,65,150,65,150,64,150,64,42,64,43,64,42,64,' \
        '42,64,42,64,150,65,42,65,42,66,41,65,42,65,42,64,150,64,42,65,42,64,42,65,41,66,41,65,'   \
        "42,65,42,64,42,65,42,64,42,64,150,65,150,64,43,64,42,64,43,64,42,65\n"
      end

      let(:io) { StringIO.new(serial_data) }

      subject(:adapter) { Arduino.new(io) }

      describe '#each_received_pulse' do
        context 'when a block is passed'  do
          it 'yields an array of signals' do
            yielded_pulse = nil

            adapter.each_received_pulse do |pulse|
              yielded_pulse = pulse
            end

            expect(yielded_pulse[0, 2]).to eq([Signal.new(true, 4520), Signal.new(false, 4270)])
          end
        end

        context 'when no block is given' do
          it 'returns an enumerator' do
            expect(adapter.each_received_pulse).to be_a(Enumerator)
          end
        end
      end
    end
  end
end
