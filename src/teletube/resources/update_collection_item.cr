module Teletube
  module Resources
    class UpdateCollectionItem
      macro parse_properties(parser, context)
        parser.on("--note NOTE", "Optional note which is presented with the collection item when viewing the collection. The text may contain a limited set of HTML tags: p, h3, ul, ol, li, pre, blockquote, a, em, strong.
        ") do |value|
          context.params["note"] = JSON::Any.new(value)
        end
      end
    end
  end
end
