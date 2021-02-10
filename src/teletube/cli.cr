module Teletube
  class Cli
    property config : Config
    property context : Context

    def initialize
      @context = Context.new
      @config = Config.load
      @client = Teletube::Client.new(@config, @context)
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
      when "categories"
        puts @client.get_categories
      when "channels"
        case context.command
        when "show"
          puts @client.get_channel
        when "create"
          puts @client.create_channel
        else
          puts @client.get_channels
        end
      when "languages"
        puts @client.get_languages
      when "profiles"
        puts @client.get_profiles_me
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
