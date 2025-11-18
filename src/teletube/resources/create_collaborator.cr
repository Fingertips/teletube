module Teletube
  module Resources
    class CreateCollaborator
      macro parse_properties(parser, context)
        parser.on("--profile-id PROFILE_ID", "Numeric identifier for the profile.") do |value|
          context.params["profile_id"] = JSON::Any.new(value)
        end
        parser.on("--permission PERMISSION", "String that indicates the permissions the profile will have. The permission names should speak for themselves and are incremental, meaning that manage-channel also gives upload and viewing permission.
        ") do |value|
          context.params["permission"] = JSON::Any.new(value)
        end
      end
    end
  end
end
