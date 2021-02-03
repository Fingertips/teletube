require "./resources/*"

module Teletube
  class Cli
    property config : Config
    property context : Context

    def initialize
      @context = Context.new
      @config = Config.load
      @client = Teletube::Client.new(@config)
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
      when "channels"
        Teletube::Resources::Channels.new(context, @client).channels.each do |channel|
          puts "* #{channel["name"]} (##{channel["id"]})"
        end
      else
        STDERR.puts("⚠️  Unimplemented resource #{context.resource}")
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
