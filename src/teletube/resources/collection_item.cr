module Teletube
  module Resources
    class CollectionItem
      macro parse_properties(parser, context)
        parser.on("--collectable-type COLLECTABLE_TYPE", "The resource type of the collectable.
        ") do |value|
          context.params["collectable_type"] = JSON::Any.new(value)
        end
        parser.on("--collectable-id COLLECTABLE_ID", "The resource id of the collectable.
        ") do |value|
          context.params["collectable_id"] = JSON::Any.new(value)
        end
        parser.on("--note NOTE", "Optional note which is presented with the collection item when viewing the collection. The text may contain a limited set of HTML tags: p, h3, ul, ol, li, pre, blockquote, a, em, strong.
        ") do |value|
          context.params["note"] = JSON::Any.new(value)
        end
      end
    end
  end
end
