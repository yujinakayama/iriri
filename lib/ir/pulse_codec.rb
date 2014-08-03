module IR
  module PulseCodec
    def self.require_all
      pattern = File.join(File.dirname(__FILE__), 'pulse_codec', '*.rb')
      Dir.glob(pattern) do |path|
        require path
      end
    end

    def self.all
      @all ||= []
    end
  end
end
