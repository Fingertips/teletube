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
      when "artworks"
        @client.create_artwork
      when "browse"
        case context.command
        when "channels"
          @client.get_browsable_channels
        when "channel"
          @client.get_browsable_channel
        when "videos"
          @client.get_browsable_videos
        when "video"
          @client.get_browsable_video
        when "artwork"
          @client.get_browsable_artwork
        when "video-variants"
          @client.get_browsable_video_variants
        when "poster"
          @client.get_browsable_poster
        when "audio-variants"
          @client.get_browsable_audio_variants
        when "waveform"
          @client.get_browsable_waveform
        end
      when "config"
        @config.attributes = {
          "endpoint" => context.params["endpoint"].as_s,
          "token"    => context.params["token"].as_s,
        }
        @config.save
      when "categories"
        @client.get_categories
      when "channels"
        case context.command
        when "create"
          @client.create_channel
        when "show"
          @client.get_channel
        when "update"
          @client.update_channel
        when "destroy"
          @client.destroy_channel
        else
          @client.get_channels
        end
      when "files"
        case context.command
        when "create"
          @client.create_file
        when "upload"
          @client.upload_file
        when "download"
          @client.download_file
        else
          @client.get_files
        end
      when "languages"
        puts @client.get_languages
      when "profiles"
        case context.command
        when "show"
          @client.get_profile
        else
          @client.get_profiles_me
        end
      when "progress"
        @client.get_video_progress
      when "trash"
        @client.get_trash
      when "videos"
        case context.command
        when "create"
          @client.create_video
        when "show"
          @client.get_video
        when "update"
          @client.update_video
        when "destroy"
          @client.destroy_video
        else
          @client.get_videos
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
