require 'ir/bits'

module IR
  describe Bits do
    describe '.new' do
      context 'when a string consists only of "1" and "0" is passed' do
        it 'returns an instance with the content' do
          bits = Bits.new('01', :big)
          expect(bits.to_s).to eq('01')
        end
      end

      context 'when a string including a character other than "1" and "0" is passed' do
        it 'raises ArgumentError' do
          expect { Bits.new('012', :big) }.to raise_error(ArgumentError)
        end
      end
    end

    describe '#[]' do
      let(:bits) { Bits.new('01000101', :big) }

      it 'returns an instance of Bits that expresses part of itself' do
        subbits = bits[2, 4]
        expect(subbits.to_s).to eq('0001')
        expect(subbits).to be_a(Bits)
      end

      describe 'the returned instance' do
        it 'inherits the endian' do
          subbits = bits[2, 4]
          expect(subbits.endian).to eq(:big)
        end
      end
    end

    describe '#string' do
      let(:bits) { Bits.new('01000101', :big) }

      it 'is frozen' do
        expect(bits.string).to be_frozen
      end
    end

    describe '#to_s' do
      let(:bits) { Bits.new('01000101', :big) }

      it 'returns duplicate of the bit string' do
        string = bits.to_s
        string[0, 2] = 'foo'
        expect(bits.string).not_to eq(string)
      end

      it 'is not frozen' do
        expect(bits.to_s).not_to be_frozen
      end
    end

    describe '#to_i' do
      let(:bits) { Bits.new('01000101', endian) }

      context 'when the bits is big-endian' do
        let(:endian) { :big }

        it 'returns an integer by interpreting the bits with big-endian' do
          expect(bits.to_i).to eq(64 + 4 + 1)
        end
      end

      context 'when the bits is little-endian' do
        let(:endian) { :little }

        it 'returns an integer by interpreting the bits with big-endian' do
          expect(bits.to_i).to eq(2 + 32 + 128)
        end
      end
    end

    describe '#invert' do
      let(:bits) { Bits.new('01000101', :big) }

      it 'returns a bit-inverted instance' do
        expect(bits.invert.to_s).to eq('10111010')
      end
    end

    describe '#pretty' do
      let(:bits) { Bits.new('0100010110111100', :big) }

      it 'returns a string with 8-bit interval whitespaces' do
        expect(bits.pretty).to eq('01000101 10111100')
      end
    end

    describe '#inspect' do
      let(:bits) { Bits.new('0100010110111100', :big) }

      it 'returns a string for debug' do
        expect(bits.inspect).to match(/#<IR::Bits:\d+ \[01000101 10111100\] endian=:big>/)
      end
    end
  end
end
