module Teletube
  module Resources
    class CreateCollaboratorInvitation
      macro parse_properties(parser, context)
        parser.on("--email EMAIL", "The e-mail address used to send the invitation. The recipient will be able to click a link to accept the invitation. If the e-mail address matches their Switch Tube profile they will also be able to accept the invitation on their profile page.") do |value|
          context.params["email"] = JSON::Any.new(value)
        end
        parser.on("--permission PERMISSION", "Holds a single string that describes the access permission of the collaborator to the channel or collection. See the permissions form for a channel or collection on the website for a longer description of the permissions.") do |value|
          context.params["permission"] = JSON::Any.new(value)
        end
      end
    end
  end
end
