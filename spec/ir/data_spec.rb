require 'ir/data'

module IR
  describe Data do
    let(:codec_class) do
      Class.new do
        def self.endian
          :big
        end

        def self.custom_bits_length
          4
        end
      end
    end

    describe '#custom_code' do
      let(:data) { Data.new('01010101', codec_class) }

      it 'returns an integer by interpreting the custom bits' do
        expect(data.custom_code).to eq(5)
      end
    end

    describe '#custom_bits' do
      let(:data) { Data.new('01000101', codec_class) }

      context 'when the custom bits length is 4' do
        it 'returns the first 4 bits' do
          expect(data.custom_bits.to_s).to eq('0100')
        end

        it 'returns an instance of Bits, not Data' do
          expect(data.custom_bits).to be_an_instance_of(Bits)
          expect(data.custom_bits).not_to be_an_instance_of(Data)
        end

        describe 'the returned instance' do
          it 'inherits the endian' do
            expect(data.custom_bits.endian).to eq(:big)
          end
        end
      end
    end

    describe '#data_bits' do
      let(:data) { Data.new('0100010101110010', codec_class) }

      context 'when the custom bits length is 4' do
        it 'returns bits after the first 4 bits' do
          expect(data.data_bits.to_s).to eq('010101110010')
        end

        it 'returns an instance of Bits, not Data' do
          expect(data.data_bits).to be_an_instance_of(Bits)
          expect(data.data_bits).not_to be_an_instance_of(Data)
        end

        describe 'the returned instance' do
          it 'inherits the endian' do
            expect(data.custom_bits.endian).to eq(:big)
          end
        end
      end
    end
  end
end
