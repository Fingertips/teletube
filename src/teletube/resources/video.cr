module Teletube
  module Resources
    class Video
      macro parse_properties(parser, context)
        parser.on("--title TITLE", "The title of the video.") do |value|
          context.params["title"] = JSON::Any.new(value)
        end
        parser.on("--abstract ABSTRACT", "A short description of the video, the text may contain a limited set of HTML tags: p, h3, ul, ol, li, pre, blockquote, a, em, strong.") do |value|
          context.params["abstract"] = JSON::Any.new(value)
        end
        parser.on("--published", "Used to set the published state for the video to either ‘published’ (true) or ‘draft’ (false). Note that a video can't be seen through the website when its published state is ‘draft’.") do
          context.params["published"] = JSON::Any.new(true)
        end
        parser.on("--no-published", "Opposite of --published") do
          context.params["published"] = JSON::Any.new(false)
        end
        parser.on("--episode EPISODE", "Allows videos to be sorted by their episode label instead of their title when they form a series.") do |value|
          context.params["episode"] = JSON::Any.new(value)
        end
        parser.on("--license-code LICENSE_CODE", "Can be used to set a specific license for use of the video. See https://creativecommons.org/licenses/ for more information about what the licenses mean.") do |value|
          context.params["license_code"] = JSON::Any.new(value)
        end
      end
    end
  end
end
