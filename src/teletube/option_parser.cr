require "option_parser"

module Teletube
  class OptionParser
    def self.parse(argv, context)
      ::OptionParser.parse(argv) do |parser|
        parser.banner = "Usage: teletube [options]"
        parser.separator ""
        parser.separator "Commands:"

        parser.on("config", "Configure common options.") do
          context.resource = "config"
          parser.on("--token TOKEN", "Access token used to access the web service") do |token|
            if token.empty?
              context.errors << "Please specify an access token."
            else
              context.params["token"] = JSON::Any.new(token)
            end
          end
          parser.on("--endpoint ENDPOINT", "Base endpoint to use to contact the web service") do |endpoint|
            if endpoint.empty?
              context.errors << "Please specify and endpoint."
            else
              context.params["endpoint"] = JSON::Any.new(endpoint)
            end
          end
        end

        parser.on("categories", "Interact with categories.") do
          context.resource = "categories"
          context.command = "list"
        end

        parser.on("channels", "Interact with channels.") do
          context.resource = "channels"
          context.command = "list"
          parser.separator ""
          parser.separator "Actions:"
          parser.on("list", "List all owned channels.") do
            context.command = "list"
            parser.on("--role ROLE", "The role of the authenticated profile.") do |role|
              if %w[owner contributor].includes?(role)
                context.params["role"] = JSON::Any.new(role)
              else
                context.errors << "Please specify either owner or contributor for the role."
              end
            end
          end
          channel_params = -> {
            parser.on("--name NAME", "Channel name.") do |name|
              context.params["name"] = JSON::Any.new(name)
            end
            parser.on("--description DESCRIPTION", "Channel description.") do |description|
              context.params["description"] = JSON::Any.new(description)
            end
            parser.on("--category CATEGORY", "Channel category.") do |category|
              context.params["category"] = JSON::Any.new(category)
            end
            parser.on("--language LANGUAGE", "Channel language.") do |language|
              context.params["language"] = JSON::Any.new(language)
            end
            parser.on("--viewable-by VIEWABLE_BY", "Choose: all, all-hidden, authenticated, organization, or collaborators.") do |viewable_by|
              context.params["viewable_by"] = JSON::Any.new(viewable_by)
            end
            parser.on("--open-channel", "Mark channel as Open Channel.") do
              context.params["open_channel"] = JSON::Any.new(true)
            end
            parser.on("--commentable", "Turn on comments.") do
              context.params["commentable"] = JSON::Any.new(true)
            end
            parser.on("--downloadable", "Allow video downloads.") do
              context.params["downloadable"] = JSON::Any.new(true)
            end
            parser.on("--archive", "The uploaded video files will be archived.") do
              context.params["archive_original_video_files"] = JSON::Any.new(true)
            end
            parser.on("--external-playback", "Allow external playback.") do
              context.params["external_playback"] = JSON::Any.new(true)
            end
            parser.on("--hide-owner", "Name of the channel owner will not be shown.") do
              context.params["hide_owner"] = JSON::Any.new(true)
            end
            parser.on("--podcast", "All uploaded files will be processed as a podcast and viewers will be able to subscribe to a feed.") do
              context.params["podcast"] = JSON::Any.new(true)
            end
            parser.on("--explicit", "Contains media only suited for mature audiences.") do
              context.params["explicit"] = JSON::Any.new(true)
            end
          }
          parser.on("create", "Create a new channel.") do
            context.command = "create"
            channel_params.call
          end
          parser.on("show", "Show details about a channel.") do
            context.command = "show"
            parser.on("--id ID", "The identifier of the channel to show.") do |id|
              context.params["id"] = JSON::Any.new(id)
            end
          end
          parser.on("update", "Update details for a channel.") do
            context.command = "update"
            parser.on("--id ID", "The identifier of the channel to update.") do |id|
              context.params["id"] = JSON::Any.new(id)
            end
            channel_params.call
          end
          parser.on("destroy", "Destroy a channel.") do
            context.command = "destroy"
            parser.on("--id ID", "The identifier of the channel to destroy.") do |id|
              context.params["id"] = JSON::Any.new(id)
            end
          end
        end

        parser.on("uploads", "Interact with uploads.") do
          context.resource = "uploads"
          parser.on("create", "Create a new upload.") do
            context.command = "create"
            parser.on("--channel-id ID", "The id of the channel that will contain the video.") do |channel_id|
              context.params["channel_id"] = JSON::Any.new(channel_id)
            end
          end
          parser.on("perform", "Create a new upload, perform the upload, and create a video.") do
            context.command = "perform"
            parser.on("--channel-id ID", "The id of the channel that will contain the video.") do |channel_id|
              context.params["channel_id"] = JSON::Any.new(channel_id)
            end
          end
        end

        parser.on("languages", "Interact with languages.") do
          context.resource = "languages"
          context.command = "list"
        end

        parser.on("profiles", "Interact with user profiles.") do
          context.resource = "profiles"
          context.command = "me"
        end

        parser.separator "Other options:"
        parser.on("-v", "--verbose", "Use log output to explain what's going on.") do
          context.verbose = true
        end
        parser.on("-h", "--help", "Show this help") do
          context.run = false
          puts parser
        end

        parser.missing_option {}
        parser.invalid_option {}
      end
    end
  end
end
