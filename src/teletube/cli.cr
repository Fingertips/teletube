module Teletube
  class Cli
    property config : Config
    property context : Context

    def initialize
      @config = Config.load
      @context = Context.new
    end

    def run(argv)
      OptionParser.parse(argv, context)
      if context.errors.any?
        print_errors
      elsif context.run?
        run_command
      end
    end

    def run_command
      case context.resource
      when "config"
        @config.attributes = context.params
        @config.save
      else
        exit 1
      end
    end

    def print_errors
      context.errors.each do |error|
        STDERR.puts("⚠️  #{error}")
      end
    end
  end
end
