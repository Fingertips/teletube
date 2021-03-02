require "option_parser"
require "./resources"

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
          parser.on("create", "Create a new channel.") do
            context.command = "create"
            Teletube::Resources::Channel.parse_properties(parser, context)
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
            Teletube::Resources::Channel.parse_properties(parser, context)
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
