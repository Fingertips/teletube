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
        @context.filename = argv.empty? ? nil : argv.last
        run_command
      end
    end

    def run_command
      case context.resource
      when "config"
        @config.attributes = {
          "endpoint" => context.params["endpoint"].as_s,
          "token" => context.params["token"].as_s
        }
        @config.save
      when "categories"
        puts @client.get_categories
      when "channels"
        case context.command
        when "create"
          puts @client.create_channel
        when "show"
          puts @client.get_channel
        when "update"
          puts @client.update_channel
        when "destroy"
          puts @client.destroy_channel
        else
          puts @client.get_channels
        end
      when "uploads"
        case context.command
        when "create"
          puts @client.create_upload
        when "perform"
          puts @client.perform_upload
        end
      when "videos"
        case context.command
        when "show"
          puts @client.get_video
        when "update"
          puts @client.update_video
        when "destroy"
          puts @client.destroy_video
        else
          puts @client.get_videos
        end
      when "languages"
        puts @client.get_languages
      when "profiles"
        case context.command
        when "show"
          puts @client.get_profile
        else
          puts @client.get_profiles_me
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
