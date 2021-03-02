module Teletube
  module Resources
    class Channel
      macro parse_properties(parser, context)
        parser.on("--name NAME", "Display name of the channel.") do |value|
          context.params["name"] = JSON::Any.new(value)
        end
        parser.on("--description DESCRIPTION", "Description of a channel, the text may contain a limited set of HTML tags: p, h3, ul, ol, li, pre, blockquote, a, em, strong.") do |value|
          context.params["description"] = JSON::Any.new(value)
        end
        parser.on("--category CATEGORY", "Category for the channel. Mostly used by the podcast functionality to include a category in the feed. See the categories endpoint for a list of valid values.") do |value|
          context.params["category"] = JSON::Any.new(value)
        end
        parser.on("--language LANGUAGE", "Primary language of the channel in ISO 639 notation. Mostly used by the podcast functionality to include a language in the feed. See the languages endpoint for a list of valid values.") do |value|
          context.params["language"] = JSON::Any.new(value)
        end
        parser.on("--viewable-by VIEWABLE_BY", "Gives permission to see the channel and its videos to a group of users. See the create channel form on the website to understand how permissions work. When using collaborators you will have to assign roles to profiles in relation to the channel.") do |value|
          context.params["viewable_by"] = JSON::Any.new(value)
        end
        parser.on("--open-channel", "Open Channels contain teaching, learning, and research videos intended to be freely used by everyone. Requires `viewable_by` to be `all`.") do
          context.params["open_channel"] = JSON::Any.new(true)
        end
        parser.on("--no-open-channel", "Opposite of --open-channel") do
          context.params["open_channel"] = JSON::Any.new(false)
        end
        parser.on("--commentable", "Authenticated users will be able to leave comments on each video page in this channel.") do
          context.params["commentable"] = JSON::Any.new(true)
        end
        parser.on("--no-commentable", "Opposite of --commentable") do
          context.params["commentable"] = JSON::Any.new(false)
        end
        parser.on("--downloadable", "Each video page in this channel will include a “Downloadable version” link.") do
          context.params["downloadable"] = JSON::Any.new(true)
        end
        parser.on("--no-downloadable", "Opposite of --downloadable") do
          context.params["downloadable"] = JSON::Any.new(false)
        end
        parser.on("--archive-original-video-files", "The uploaded video file will be archived and will continue to be available for download to the channel admins.") do
          context.params["archive_original_video_files"] = JSON::Any.new(true)
        end
        parser.on("--no-archive-original-video-files", "Opposite of --archive-original-video-files") do
          context.params["archive_original_video_files"] = JSON::Any.new(false)
        end
        parser.on("--external-playback", "Each “Edit video” page in this channel will include a URL to load the video in an external player. Requires `viewable_by` to be `all` or `all-hidden`.") do
          context.params["external_playback"] = JSON::Any.new(true)
        end
        parser.on("--no-external-playback", "Opposite of --external-playback") do
          context.params["external_playback"] = JSON::Any.new(false)
        end
        parser.on("--hide-owner", "On the channel overview, the name of the channel owner will not be shown as a link to their profile page.") do
          context.params["hide_owner"] = JSON::Any.new(true)
        end
        parser.on("--no-hide-owner", "Opposite of --hide-owner") do
          context.params["hide_owner"] = JSON::Any.new(false)
        end
        parser.on("--podcast", "All uploaded files will be processed as a podcast and viewers will be able to subscribe to a feed. Requires `viewable_by` to be `all` or `all-hidden`.") do
          context.params["podcast"] = JSON::Any.new(true)
        end
        parser.on("--no-podcast", "Opposite of --podcast") do
          context.params["podcast"] = JSON::Any.new(false)
        end
        parser.on("--explicit", "Can be set when the channel contains media only suited for mature audiences. Mostly used by the podcast functionality to include an explicit tag in the feed.") do
          context.params["explicit"] = JSON::Any.new(true)
        end
        parser.on("--no-explicit", "Opposite of --explicit") do
          context.params["explicit"] = JSON::Any.new(false)
        end
      end
    end
  end
end
