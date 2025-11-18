module Teletube
  module Resources
    class Collection
      macro parse_properties(parser, context)
        parser.on("--title TITLE", "The title of the collection.") do |value|
          context.params["title"] = JSON::Any.new(value)
        end
        parser.on("--description DESCRIPTION", "Description of a collection, the text may contain a limited set of HTML tags: p, h3, ul, ol, li, pre, blockquote, a, em, strong.
        ") do |value|
          context.params["description"] = JSON::Any.new(value)
        end
        parser.on("--viewable-by VIEWABLE_BY", "Gives permission to see the collection, note that the collection items will always have their own permissions dictated by their channel. See the form to edit collection permissions on the website to understand how permissions work. After choosing the collaborator setting you can use the createCollectionCollaborators operation to manage collaborator permissions for profiles.
        ") do |value|
          context.params["viewable_by"] = JSON::Any.new(value)
        end
      end
    end
  end
end
