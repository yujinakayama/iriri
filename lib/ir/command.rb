module IR
  module Command
    def self.require_all
      pattern = File.join(File.dirname(__FILE__), 'command', '*.rb')
      Dir.glob(pattern) do |path|
        require path
      end
    end

    def self.all
      @all ||= []
    end

    def self.for_pulse_codec(codec_class)
      all.select do |command_class|
        command_class.use_codec?(codec_class)
      end
    end
  end
end
