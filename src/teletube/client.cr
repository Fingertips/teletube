require "json"

module Teletube
  class Client
    def initialize(config : Teletube::Config, context : Teletube::Context)
      @config = config
      @context = context
      @http = Teletube::Http.new(@config)
    end

    def create_artwork
      handle_response(@http.post(path: "/api/v1/uploads/#{@context.params["upload_id"]}/artwork"))
    end

    def get_categories
      handle_response(@http.get(path: "/api/v1/categories"))
    end

    def get_channels
      if @context.params.empty?
        handle_response(@http.get(path: "/api/v1/channels"))
      else
        handle_response(@http.get(path: "/api/v1/channels", params: @context.params))
      end
    end

    def create_channel
      handle_response(@http.post(path: "/api/v1/channels", params: @context.params))
    end

    def get_channel
      handle_response(@http.get(path: "/api/v1/channels/#{@context.params["id"]}"))
    end

    def update_channel
      handle_response(
        @http.patch(path: "/api/v1/channels/#{@context.params["id"]}", params: @context.params)
      )
    end

    def destroy_channel
      handle_response(
        @http.delete(path: "/api/v1/channels/#{@context.params["id"]}")
      )
    end

    class Upload
      # 50 megabytes
      SEGMENT_SIZE = 52428800

      property http : Teletube::Http
      property filename : String
      property location : String

      def initialize(http, filename)
        @http = http
        @filename = filename
        @location = ""
      end

      def id
        path.split("/").last
      end

      def path
        "/" + location.split("/")[3..-1].join("/")
      end

      def perform
        create_file
        upload_file
      end

      def create_file
        headers = self.class.headers
        headers["Upload-Length"] = File.size(filename).to_s
        response = handle_response(http.post(path: "/files", headers: headers))
        if response.status_code >= 200 && response.status_code < 300
          @location = response.headers["Location"]
          STDERR.puts "📃 #{id}"
        end
        response
      end

      def get_upload_offset
        offset = -1
        while (offset < 0)
          response = handle_response(http.head(path: path, headers: self.class.headers))
          if response.status_code == 200
            offset = response.headers["Upload-Offset"].to_i
          elsif response.status_code == 423
            sleep 10
          end
        end
        offset
      end

      def upload_file
        response = nil
        offset = 0
        headers = self.class.headers
        segment = Bytes.new(SEGMENT_SIZE)
        File.open(filename, "rb") do |file|
          while (size = file.read(segment)) > 0
            headers["Content-Type"] = "application/offset+octet-stream"
            headers["Upload-Offset"] = offset.to_s
            response = handle_response(http.patch(path: path, headers: headers, body: segment[0, size]))
            if response.status_code >= 200 && response.status_code < 300
              offset += segment.size
            elsif [502, 503].includes?(response.status_code)
              @http.reset
              offset = get_upload_offset
              file.pos = offset
              STDERR.puts "🗑 resetting offset to #{offset}"
            else
              break
            end
          end
        end
        response
      end

      def handle_response(response)
        STDERR.puts "⚡️ #{response.status} (#{response.status_code})"
        puts response.body unless response.body.blank?
        response
      end

      def self.headers
        headers = HTTP::Headers.new
        headers["Tus-Resumable"] = "1.0.0"
        headers
      end
    end

    # Only creates a new file on tusd. Could technically be useful when you want to use a different
    # client to actually upload the file.
    def create_file
      return unless @context.filename

      upload = Upload.new(@http, @context.filename || "")
      upload.create_file
    end

    def upload_file
      return unless @context.filename

      upload = Upload.new(@http, @context.filename || "")
      upload.perform
      @context.params["upload_id"] = JSON::Any.new(upload.id)
    end

    def get_files
      handle_response(@http.get(path: "/api/v1/videos/#{@context.params["video_id"]}/files"))
    end

    def get_videos
      handle_response(@http.get(path: "/api/v1/channels/#{@context.params["channel_id"]}/videos"))
    end

    def create_video
      upload_file
      handle_response(@http.post(path: "/api/v1/videos", params: @context.params))
    end

    def get_video
      handle_response(@http.get(path: "/api/v1/videos/#{@context.params["id"]}"))
    end

    def update_video
      handle_response(
        @http.patch(path: "/api/v1/videos/#{@context.params["id"]}", params: @context.params)
      )
    end

    def destroy_video
      handle_response(
        @http.delete(path: "/api/v1/videos/#{@context.params["id"]}")
      )
    end

    def get_languages
      handle_response(@http.get(path: "/api/v1/languages"))
    end

    def get_profile
      handle_response(@http.get(path: "/api/v1/profiles/#{@context.params["id"]}"))
    end

    def get_profiles_me
      handle_response(@http.get(path: "/api/v1/profiles/me"))
    end

    def get_video_progress
      handle_response(@http.get(path: "/api/v1/videos/#{@context.params["video_id"]}/progress"))
    end

    def get_browsable_channels
      handle_response(@http.get(path: "/api/v1/browse/channels"))
    end

    def get_browsable_channel
      handle_response(@http.get(path: "/api/v1/browse/channels/#{@context.params["id"]}"))
    end

    def get_browsable_videos
      handle_response(@http.get(path: "/api/v1/browse/channels/#{@context.params["channel_id"]}/videos"))
    end

    def get_browsable_video
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["id"]}"))
    end

    def get_browsable_artwork
      handle_response(@http.get(path: "/api/v1/browse/channels/#{@context.params["channel_id"]}/artwork"))
    end

    def get_browsable_video_variants
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/video_variants"))
    end

    def get_browsable_poster
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/poster"))
    end

    def get_browsable_audio_variants
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/audio_variants"))
    end

    def get_browsable_waveform
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/waveform"))
    end

    def handle_response(response)
      STDERR.puts "⚡️ #{response.status} (#{response.status_code})"
      puts response.body unless response.body.blank?
      response
    end
  end
end
