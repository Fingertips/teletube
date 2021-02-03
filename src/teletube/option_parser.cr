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
              context.params["token"] = token
            end
          end
          parser.on("--endpoint ENDPOINT", "Base endpoint to use to contact the web service") do |endpoint|
            if endpoint.empty?
              context.errors << "Please specify and endpoint."
            else
              context.params["endpoint"] = endpoint
            end
          end
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
                context.params["role"] = role
              else
                context.errors << "Please specify either owner or contributor for the role."
              end
            end
          end
          parser.on("show", "Show details about a channel.") do
            context.command = "show"
            parser.on("--id ID", "The identifier of the channel to show.") do |id|
              context.params["id"] = id
            end
          end
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
